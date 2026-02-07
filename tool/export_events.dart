import 'dart:convert';
import 'dart:io';

import 'package:immortal_chronicles/data/sample_events.dart';
import 'package:immortal_chronicles/models/enums.dart';
import 'package:immortal_chronicles/models/life_event_config.dart';

void main() {
  final dir = Directory('assets/events');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  String toYaml(dynamic value, {int indent = 0}) {
    final space = ' ' * indent;
    if (value is Map) {
      final buffer = StringBuffer();
      value.forEach((key, v) {
        final rendered = toYaml(v, indent: indent + 2);
        final isMultiline = v is Map || v is List || rendered.contains('\n');
        if (isMultiline) {
          buffer.writeln('$space$key:');
          buffer.write('$rendered\n');
        } else {
          buffer.writeln('$space$key: $rendered');
        }
      });
      return buffer.toString().trimRight();
    } else if (value is List) {
      final buffer = StringBuffer();
      for (final item in value) {
        final rendered = toYaml(item, indent: indent + 2);
        if (rendered.contains('\n')) {
          buffer.writeln('$space-');
          buffer.write('$rendered\n');
        } else {
          buffer.writeln('$space- $rendered');
        }
      }
      return buffer.toString().trimRight();
    } else if (value is String) {
      // 使用 JSON 转义以防特殊字符，再用双引号保持安全
      return jsonEncode(value);
    } else if (value == null) {
      return 'null';
    } else {
      return value.toString();
    }
  }

  void writeTable(String name, List<LifeEventConfig> list) {
    final path = '${dir.path}/$name.yaml';
    final data = list.map((e) => e.toJson()).toList();
    final yaml = toYaml(data);
    File(path).writeAsStringSync('$yaml\n');
    stdout.writeln('写入 $path，${list.length} 条');
  }

  List<LifeEventConfig> byAge(int min, int max) => sampleEvents
      .where((e) => (e.minAge ?? 0) <= max && (e.maxAge ?? 2000) >= min)
      .toList();

  writeTable('age_0_3', byAge(0, 3));
  writeTable('age_4_6', byAge(4, 6));
  writeTable('age_7_12', byAge(7, 12));
  writeTable('age_13_18', byAge(13, 18));

  writeTable('clan_chance',
      sampleEvents.where((e) => e.id.startsWith('clan_')).toList());
  writeTable('sect_chance',
      sampleEvents.where((e) => e.id.startsWith('sect_')).toList());

  writeTable('mortal_daily',
      sampleEvents.where((e) => e.id.startsWith('mortal_daily_')).toList());
  writeTable('immortal_daily',
      sampleEvents.where((e) => e.id.startsWith('immortal_daily_')).toList());
  writeTable('nether_daily',
      sampleEvents.where((e) => e.id.startsWith('nether_daily_')).toList());

  // 主表备份（可选）
  writeTable('all_events', sampleEvents);

  // 确保各世界兜底事件存在，方便加载器 fallback
  for (final world in World.values) {
    final id = '${world.name}_fallback';
    final ev = sampleEvents.firstWhere((e) => e.id == id,
        orElse: () => LifeEventConfig(
              id: id,
              title: '平平无奇的一年',
              description: '什么都没发生。',
              worlds: [world],
              effects: const {'age': 1},
            ));
    writeTable('${world.name}_fallback', [ev]);
  }

  stdout.writeln('导出完成。');
}
