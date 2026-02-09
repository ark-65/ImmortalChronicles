import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/asset_service.dart';

class ReferenceRepository {
  static final ReferenceRepository _instance = ReferenceRepository._internal();
  factory ReferenceRepository() => _instance;
  ReferenceRepository._internal();

  final AssetService _assetService = AssetService();
  bool _loaded = false;

  List<FamilyTemplate> families = const [];
  List<SectTemplate> sects = const [];
  List<WeaponType> weapons = const [];
  List<MapZone> maps = const [];
  List<Medicine> medicines = const [];
  List<Technique> techniques = const [];
  List<GrowthStage> stages = const [];
  List<ElementCategory> elementCategories = const [];
  Map<String, List<int>> realmLayers = const {};
  Map<String, int> realmLifespan = const {};

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      families = await _loadCategory('assets/families/', (e) => FamilyTemplate.fromJson(e), families);
      sects = await _loadCategory('assets/sects/', (e) => SectTemplate.fromJson(e), sects);
      weapons = await _loadCategory('assets/weapons/', (e) => WeaponType.fromJson(e), weapons);
      maps = await _loadCategory('assets/maps/', (e) => MapZone.fromJson(e), maps);
      medicines = await _loadCategory('assets/medicines/', (e) => Medicine.fromJson(e), medicines);
      techniques = await _loadCategory('assets/techniques/', (e) => Technique.fromJson(e), techniques);
      
      await _loadMetaRealms();
      await _loadMetaStages();
      await _loadMetaElements();
      
      debugPrint('[ReferenceRepository] assets loaded successfully');
    } catch (e) {
      debugPrint('[ReferenceRepository] asset load failed: $e');
    } finally {
      _loaded = true;
    }
  }

  FamilyTemplate? familyById(String? id) =>
      families.isEmpty ? null : families.firstWhere((f) => f.id == id, orElse: () => families.first);
      
  SectTemplate? sectById(String? id) =>
      sects.isEmpty ? null : sects.firstWhere((s) => s.id == id, orElse: () => sects.first);

  Technique? techniqueById(String? id) =>
      techniques.firstWhere((t) => t.id == id, orElse: () => techniques.first);

  MapZone? mapById(String? id) =>
      maps.isEmpty ? null : maps.firstWhere((m) => m.id == id, orElse: () => maps.first);

  MapZone defaultMapFor(World world) {
    final list = maps.where((m) => m.world == world).toList();
    if (list.isNotEmpty) return list.first;
    if (maps.isNotEmpty) return maps.first;
    
    // Emergency Fallback
    return MapZone(
      id: 'fallback_map',
      name: '边缘荒地',
      world: world,
      region: Region.ren,
      tier: '人',
      description: '游离于六界之外的未知区域（数据加载失败保护）。',
    );
  }

  GrowthStage currentStage(int age) {
    if (stages.isEmpty) {
      return GrowthStage(id: 'default', minAge: 0, maxAge: 9999);
    }
    return stages.firstWhere(
      (s) => age >= s.minAge && age <= s.maxAge,
      orElse: () => stages.last,
    );
  }

  Future<List<T>> _loadCategory<T>(String prefix, T Function(Map<String, dynamic>) parser, List<T> fallback) async {
    final data = await _assetService.loadDirectory(prefix);
    if (data.isEmpty) return fallback;
    
    return data.map((e) => parser(e)).toList();
  }

  Future<void> _loadMetaRealms() async {
    final manifest = await _assetService.getManifest();
    final targets = manifest.where((p) => p.startsWith('assets/meta/realms')).toList();
    if (targets.isEmpty) return;

    final layers = <String, List<int>>{};
    final lifespans = <String, int>{};

    for (final path in targets) {
      try {
        final content = await _assetService.loadFile(path);
        final Iterable entries;
        if (content is Map && content['realms'] != null) {
          entries = (content['realms'] as List);
        } else if (content is Map) {
          entries = [content];
        } else if (content is List) {
          entries = content;
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

    if (layers.isNotEmpty) realmLayers = layers;
    if (lifespans.isNotEmpty) realmLifespan = lifespans;
  }

  Future<void> _loadMetaStages() async {
    try {
      final content = await _assetService.loadFile('assets/meta/stages.yaml');
      if (content is Map && content['stages'] != null) {
        stages = (content['stages'] as List).map((e) => GrowthStage.fromJson(e)).toList();
      }
    } catch (e) {
       debugPrint('[ReferenceRepository] load stages failed: $e');
    }
  }

  Future<void> _loadMetaElements() async {
    try {
      final content = await _assetService.loadFile('assets/meta/elements.yaml');
      if (content is Map && content['categories'] != null) {
        elementCategories = (content['categories'] as List).map((e) => ElementCategory.fromJson(e)).toList();
      }
    } catch (e) {
       debugPrint('[ReferenceRepository] load elements failed: $e');
    }
  }

  (String, List<int>, int)? _parseRealmEntry(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString() ?? '';
    if (id.isEmpty) return null;
    
    final lifespan = (m['lifespan'] as num?)?.toInt() ?? 60;
    final ls = <int>[];
    for (final layer in (m['layers'] as List? ?? const [])) {
      if (layer is Map && layer['expRequired'] != null) {
        ls.add((layer['expRequired'] as num).toInt());
      }
    }
    return (id, ls, lifespan);
  }
}
