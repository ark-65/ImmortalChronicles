import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import '../models/models.dart';
import 'sample_events.dart';

class EventRepository {
  static final EventRepository _instance = EventRepository._internal();
  factory EventRepository() => _instance;
  EventRepository._internal();

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
    int loadedCount = 0;
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final assets = (json.decode(manifest) as Map<String, dynamic>).keys;
      final eventFiles = assets.where((p) => p.startsWith('assets/events/'));

      for (final path in eventFiles) {
        final name =
            path.split('/').last.replaceAll('.yaml', '').replaceAll('.json', '');
        final raw = await rootBundle.loadString(path);
        final List<dynamic> list = path.endsWith('.yaml')
            ? (loadYaml(raw) as YamlList).toList()
            : (json.decode(raw) as List<dynamic>);
        final configs = list
            .map((e) => LifeEventConfig.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _tables[name] = configs;
        for (final c in configs) {
          _byId[c.id] = c;
        }
        loadedCount += configs.length;
      }
    } catch (_) {
      // ignore and fall back
    }

    // 若未找到资产文件或加载失败，则回落到现有 Dart 常量表，避免运行期无事件
    if (loadedCount == 0) {
      _loadFromConstSample();
    }
  }

  void _loadFromConstSample() {
    // 直接使用原有的 sampleEvents 列表进行分表，保证兼容
    List<LifeEventConfig> filter(int min, int max) => sampleEvents
        .where((e) => (e.minAge ?? 0) <= max && (e.maxAge ?? 2000) >= min)
        .toList();

    _tables['age_0_3'] = filter(0, 3);
    _tables['age_4_6'] = filter(4, 6);
    _tables['age_7_12'] = filter(7, 12);
    _tables['age_13_18'] = filter(13, 18);
    _tables['clan_chance'] =
        sampleEvents.where((e) => e.id.startsWith('clan_')).toList();
    _tables['sect_chance'] =
        sampleEvents.where((e) => e.id.startsWith('sect_')).toList();
    _tables['mortal_daily'] =
        sampleEvents.where((e) => e.id.startsWith('mortal_daily_')).toList();
    _tables['immortal_daily'] =
        sampleEvents.where((e) => e.id.startsWith('immortal_daily_')).toList();
    _tables['nether_daily'] =
        sampleEvents.where((e) => e.id.startsWith('nether_daily_')).toList();

    for (final c in sampleEvents) {
      _byId[c.id] = c;
    }
  }
}
