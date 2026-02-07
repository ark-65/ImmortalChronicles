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
}
