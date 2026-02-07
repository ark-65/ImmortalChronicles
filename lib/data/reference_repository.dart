import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import '../models/models.dart';
import 'family_templates.dart';
import 'sect_templates.dart';
import 'weapons.dart';
import 'maps_fallback.dart';
import 'medicine_fallback.dart';
import 'technique_pool.dart';
import 'realms.dart' as realm_table;

class ReferenceRepository {
  static final ReferenceRepository _instance = ReferenceRepository._internal();
  factory ReferenceRepository() => _instance;
  ReferenceRepository._internal();

  bool _loaded = false;

  List<FamilyTemplate> families = familyTemplatesFallback;
  List<SectTemplate> sects = sectTemplatesFallback;
  List<WeaponType> weapons = weaponTypesFallback;
  List<MapZone> maps = mapZonesFallback;
  List<Medicine> medicines = medicineListFallback;
  List<Technique> techniques = allTechPool(); // fallback generator
  Map<String, List<int>> realmLayers = realm_table.realmLayers;
  Map<String, int> realmLifespan = realm_table.realmLifespan;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final assets = (json.decode(manifest) as Map<String, dynamic>).keys;

      await _loadCategory<FamilyTemplate>(
        assets,
        prefix: 'assets/families/',
        parser: (e) => FamilyTemplate.fromJson(e),
        setter: (list) => families = list,
      );
      await _loadCategory<SectTemplate>(
        assets,
        prefix: 'assets/sects/',
        parser: (e) => SectTemplate.fromJson(e),
        setter: (list) => sects = list,
      );
      await _loadCategory<WeaponType>(
        assets,
        prefix: 'assets/weapons/',
        parser: (e) => WeaponType.fromJson(e),
        setter: (list) => weapons = list,
      );
      await _loadCategory<MapZone>(
        assets,
        prefix: 'assets/maps/',
        parser: (e) => MapZone.fromJson(e),
        setter: (list) => maps = list,
      );
      await _loadCategory<Medicine>(
        assets,
        prefix: 'assets/medicines/',
        parser: (e) => Medicine.fromJson(e),
        setter: (list) => medicines = list,
      );
      await _loadCategory<Technique>(
        assets,
        prefix: 'assets/techniques/',
        parser: (e) => Technique.fromJson(e),
        setter: (list) => techniques = list,
      );
      await _loadMetaRealms(assets);
      debugPrint('[ReferenceRepository] assets loaded successfully');
    } catch (_) {
      // 忽略，保持回退数据
      debugPrint(
          '[ReferenceRepository] asset load failed，using fallback constants');
    } finally {
      _loaded = true;
    }
  }

  FamilyTemplate? familyById(String? id) =>
      families.firstWhere((f) => f.id == id, orElse: () => families.first);
  SectTemplate? sectById(String? id) => sects.firstWhere(
        (s) => s.id == id,
        orElse: () =>
            sects.isNotEmpty ? sects.first : sectTemplatesFallback.first,
      );
  MapZone? mapById(String? id) => maps.firstWhere(
        (m) => m.id == id,
        orElse: () => maps.isNotEmpty ? maps.first : mapZonesFallback.first,
      );

  MapZone defaultMapFor(World world) {
    final list = maps.where((m) => m.world == world).toList();
    if (list.isNotEmpty) return list.first;
    return mapZonesFallback.first;
  }

  Future<int> _loadCategory<T>(
    Iterable<String> assets, {
    required String prefix,
    required T Function(Map<String, dynamic>) parser,
    required void Function(List<T>) setter,
  }) async {
    final files = assets.where((p) => p.startsWith(prefix));
    if (files.isEmpty) {
      debugPrint(
          '[ReferenceRepository] no assets under $prefix, keep fallback');
      return 0;
    }
    final buffer = <T>[];
    for (final path in files) {
      final raw = await rootBundle.loadString(path);
      final bool isYaml = path.endsWith('.yaml') || path.endsWith('.yml');
      final List<dynamic> list = isYaml
          ? (loadYaml(raw) as YamlList).toList()
          : (json.decode(raw) as List<dynamic>);
      buffer.addAll(list
          .map((e) => parser(Map<String, dynamic>.from(e)))
          .where((e) => e != null));
    }
    if (buffer.isNotEmpty) {
      setter(buffer);
      debugPrint(
          '[ReferenceRepository] loaded ${buffer.length} entries from $prefix');
    } else {
      debugPrint(
          '[ReferenceRepository] parsed zero entries from $prefix, keep fallback');
    }
    return buffer.length;
  }

  Future<void> _loadMetaRealms(Iterable<String> assets) async {
    // 优先加载分片：assets/meta/realms/<realm>.yaml；若不存在再读单文件 assets/meta/realms.yaml
    final shardFiles = assets
        .where((p) =>
            p.startsWith('assets/meta/realms/') &&
            (p.endsWith('.yaml') || p.endsWith('.yml')))
        .toList();
    final singleFile = assets.firstWhere(
      (p) => p == 'assets/meta/realms.yaml',
      orElse: () => '',
    );
    final targets = shardFiles.isNotEmpty
        ? shardFiles
        : (singleFile.isNotEmpty ? [singleFile] : []);
    if (targets.isEmpty) {
      debugPrint('[ReferenceRepository] no meta realms asset, keep fallback');
      return;
    }

    final layers = <String, List<int>>{};
    final lifespans = <String, int>{};

    for (final path in targets) {
      try {
        final raw = await rootBundle.loadString(path);
        final doc = loadYaml(raw);
        final Iterable entries;
        if (doc is YamlMap && doc['realms'] != null) {
          entries = (doc['realms'] as YamlList);
        } else if (doc is YamlMap) {
          entries = [doc];
        } else if (doc is YamlList) {
          entries = doc;
        } else {
          continue;
        }
        for (final e in entries) {
          final parsed = _parseRealmEntry(e);
          if (parsed == null) continue;
          layers[parsed.$1] = parsed.$2;
          lifespans[parsed.$1] = parsed.$3;
        }
      } catch (e) {
        debugPrint('[ReferenceRepository] parse $path failed: $e');
      }
    }

    if (layers.isNotEmpty) {
      realmLayers = layers;
      debugPrint(
          '[ReferenceRepository] loaded realm layers from ${targets.length} file(s)');
    }
    if (lifespans.isNotEmpty) {
      realmLifespan = lifespans;
    }
  }

  /// returns (id, layers, lifespan)
  (String, List<int>, int)? _parseRealmEntry(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString() ?? '';
    if (id.isEmpty) return null;
    final lifespan =
        (m['lifespan'] as num?)?.toInt() ?? realm_table.realmLifespan[id] ?? 60;
    final ls = <int>[];
    for (final layer in (m['layers'] as List? ?? const [])) {
      if (layer is Map && layer['expRequired'] != null) {
        ls.add((layer['expRequired'] as num).toInt());
      }
    }
    if (ls.isEmpty && realm_table.realmLayers[id] != null) {
      ls.addAll(realm_table.realmLayers[id]!);
    }
    return (id, ls, lifespan);
  }
}
