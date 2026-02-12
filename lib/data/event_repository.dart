import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/asset_service.dart';

class EventRepository {
  static final EventRepository _instance = EventRepository._internal();
  factory EventRepository() => _instance;
  EventRepository._internal();

  final AssetService _assetService = AssetService();
  final Map<String, LifeEventConfig> _byId = {};
  final Map<String, List<LifeEventConfig>> _tables = {};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await _loadAll();
    _loaded = true;
  }

  List<LifeEventConfig> table(String name) => _tables[name] ?? const [];

  LifeEventConfig? byId(String id) => _byId[id];

  List<LifeEventConfig> tableAge0to3() => table('age_0_3');
  List<LifeEventConfig> tableAge4to6() => table('age_4_6');
  List<LifeEventConfig> tableAge7to12() => table('age_7_12');
  List<LifeEventConfig> tableAge13to18() => table('age_13_18');
  List<LifeEventConfig> tableClanChance() => table('clan_chance');
  List<LifeEventConfig> tableSectChance() => table('sect_chance');
  List<LifeEventConfig> tableWorldDaily(World world) {
    switch (world) {
      case World.mortal:
        return table('mortal_daily');
      case World.immortal:
        return table('immortal_daily');
      case World.nether:
        return table('nether_daily');
    }
  }

  Future<void> _loadAll() async {
    try {
      final manifest = await _assetService.getManifest();
      final eventFiles = manifest.where((p) => p.startsWith('assets/events/')).toList();

      if (eventFiles.isEmpty) {
        debugPrint('[EventRepository] No asset events found. Loading built-in fallbacks.');
        _loadBuiltInFallbacks();
        return;
      }

      // First pass: Load all raw configs
      final rawConfigs = <String, Map<String, dynamic>>{};
      _tables.clear();
      
      for (final path in eventFiles) {
        final content = await _assetService.loadFile(path);
        final tableName = path.split('/').last.split('.').first;
        
        if (content is List) {
          for (var item in content) {
            if (item is Map) {
              final id = item['id']?.toString() ?? '';
              if (id.isNotEmpty) {
                final data = Map<String, dynamic>.from(item);
                rawConfigs[id] = data;
                // Temporary add to table to keep track of associations
                _tables.putIfAbsent(tableName, () => []).add(LifeEventConfig.fromJson(data));
              }
            }
          }
        }
      }

      // Second pass: Process templates and finalize configs
      _byId.clear();
      for (final id in rawConfigs.keys) {
        _byId[id] = _resolveConfig(id, rawConfigs);
      }

      // Update tables with resolved configs
      for (final tableName in _tables.keys) {
        _tables[tableName] = _tables[tableName]!
            .map((e) => _byId[e.id] ?? e)
            .toList();
      }

      debugPrint('[EventRepository] loaded ${_byId.length} events from assets');
    } catch (e) {
      debugPrint('[EventRepository] load failed: $e');
      _loadBuiltInFallbacks();
    }
  }

  void _loadBuiltInFallbacks() {
    // Basic survival events to ensure game runs even without assets
    final fallbackEvents = [
      LifeEventConfig(
        id: 'mortal_daily_fallback',
        title: '平淡的一年',
        description: '这一年风调雨顺，无事发生。',
        worlds: [World.mortal],
        effects: const {'age': 1},
        weight: 100,
      ),
      LifeEventConfig(
        id: 'immortal_daily_fallback',
        title: '闭关苦修',
        description: '山中无甲子，寒尽不知年。',
        worlds: [World.immortal],
        effects: const {'age': 1, 'exp': 10},
        weight: 100,
      ),
    ];
    
    _byId.clear();
    _tables.clear();
    for (final e in fallbackEvents) {
      _byId[e.id] = e;
      _tables.putIfAbsent('mortal_daily', () => []).add(e);
      _tables.putIfAbsent('immortal_daily', () => []).add(e);
    }
    debugPrint('[EventRepository] Loaded ${fallbackEvents.length} builtin fallback events.');
  }

  LifeEventConfig _resolveConfig(String id, Map<String, Map<String, dynamic>> rawConfigs) {
    final raw = rawConfigs[id]!;
    final templateId = raw['templateId']?.toString();
    
    if (templateId != null && rawConfigs.containsKey(templateId)) {
      final template = _resolveConfig(templateId, rawConfigs);
      return _merge(template, LifeEventConfig.fromJson(raw));
    }
    
    return LifeEventConfig.fromJson(raw);
  }

  LifeEventConfig _merge(LifeEventConfig template, LifeEventConfig override) {
    // Check if worlds was explicitly provided in JSON
    final hasWorlds = override.toJson()['worlds'] != null;

    return template.copyWith(
      id: override.id,
      title: override.title.isEmpty ? template.title : override.title,
      description: override.description.isEmpty ? template.description : override.description,
      worlds: hasWorlds ? override.worlds : template.worlds,
      regions: override.regions ?? template.regions,
      minAge: override.minAge ?? template.minAge,
      maxAge: override.maxAge ?? template.maxAge,
      mapIds: override.mapIds ?? template.mapIds,
      familyTiers: override.familyTiers ?? template.familyTiers,
      conditions: {...template.conditions, ...override.conditions},
      prerequisites: {...template.prerequisites, ...override.prerequisites}.toList(),
      effects: {...template.effects, ...override.effects},
      choices: override.choices.isEmpty ? template.choices : override.choices,
      weight: (override.toJson()['weight'] != null) ? override.weight : template.weight,
      duration: override.duration ?? template.duration,
    );
  }

}
