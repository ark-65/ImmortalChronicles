import 'dart:convert';
import 'dart:io';

import 'package:immortal_chronicles/data/family_templates.dart';
import 'package:immortal_chronicles/data/maps_fallback.dart';
import 'package:immortal_chronicles/data/medicine_fallback.dart';
import 'package:immortal_chronicles/data/realms.dart';
import 'package:immortal_chronicles/data/sect_templates.dart';
import 'package:immortal_chronicles/data/stages.dart';
import 'package:immortal_chronicles/data/technique_pool.dart';
import 'package:immortal_chronicles/data/weapons.dart';

/// Export Dart fallback constants into YAML assets for runtime loading.
///
/// - Default：仅输出 YAML
/// - 传入 `--json`：额外输出 JSON 便于调试或对比
Future<void> main(List<String> args) async {
  final writeJson = args.contains('--json');

  await _exportData(
    base: 'assets/families/fallback',
    data: familyTemplatesFallback.map((f) => f.toJson()).toList(),
    writeJson: writeJson,
  );

  await _exportData(
    base: 'assets/sects/fallback',
    data: sectTemplatesFallback.map((s) => s.toJson()).toList(),
    writeJson: writeJson,
  );

  await _exportData(
    base: 'assets/weapons/fallback',
    data: weaponTypesFallback.map((w) => w.toJson()).toList(),
    writeJson: writeJson,
  );

  await _exportData(
    base: 'assets/medicines/fallback',
    data: medicineListFallback.map((m) => m.toJson()).toList(),
    writeJson: writeJson,
  );

  await _exportData(
    base: 'assets/techniques/fallback',
    data: allTechPool().map((t) => t.toJson()).toList(),
    writeJson: writeJson,
  );

  await _exportData(
    base: 'assets/maps/six_realms',
    data: mapZonesFallback.map((m) => m.toJson()).toList(),
    writeJson: writeJson,
  );

  await _exportData(
    base: 'assets/meta/realms',
    data: _buildRealmMeta(),
    writeJson: writeJson,
  );

  await _exportData(
    base: 'assets/meta/stages',
    data: {
      'version': 1,
      'stages': stageConfigs.map((s) => s.toJson()).toList(),
      'generatedAt': DateTime.now().toIso8601String(),
    },
    writeJson: writeJson,
  );

  stdout.writeln('[export_fallbacks] Done.');
}

Future<void> _exportData({
  required String base,
  required Object data,
  required bool writeJson,
}) async {
  await _writeYaml('$base.yaml', data);
  if (writeJson) {
    await _writeJson('$base.json', data);
  } else {
    // 如果之前存在 json 输出，清理掉，保证格式统一
    final jsonFile = File('$base.json');
    if (await jsonFile.exists()) {
      await jsonFile.delete();
      stdout.writeln('[export_fallbacks] removed legacy ${jsonFile.path}');
    }
  }
}

Future<void> _writeYaml(String path, Object data) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  final yaml = _toYaml(data);
  await file.writeAsString('$yaml\n');
  stdout.writeln('[export_fallbacks] wrote $path');
}

Future<void> _writeJson(String path, Object data) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  final encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(data)}\n');
  stdout.writeln('[export_fallbacks] wrote $path');
}

String _toYaml(Object? data, {int indent = 0}) {
  final space = ' ' * indent;
  final buffer = StringBuffer();

  if (data is Map) {
    data.forEach((key, value) {
      final k = key.toString();
      if (value is Map || value is List) {
        buffer.writeln('$space$k:');
        buffer.write(_toYaml(value, indent: indent + 2));
        buffer.writeln();
      } else {
        buffer.writeln('$space$k: ${_scalar(value)}');
      }
    });
  } else if (data is List) {
    for (final value in data) {
      if (value is Map || value is List) {
        buffer.writeln('$space-');
        buffer.write(_toYaml(value, indent: indent + 2));
        buffer.writeln();
      } else {
        buffer.writeln('$space- ${_scalar(value)}');
      }
    }
  } else {
    buffer.writeln('$space${_scalar(data)}');
  }
  return buffer.toString().trimRight();
}

String _scalar(Object? value) {
  if (value == null) return 'null';
  if (value is num || value is bool) return value.toString();
  // use JSON string for proper escaping
  return jsonEncode(value.toString());
}

Map<String, dynamic> _buildRealmMeta() {
  final realms = <Map<String, dynamic>>[];
  for (int i = 0; i < realmSequence.length; i++) {
    final name = realmSequence[i];
    final lifespan = realmLifespan[name] ?? 60;
    final layers =
        _generateLayers(base: 100 * (i + 1), growth: 1.15, count: 10);
    realms.add({
      'id': name,
      'lifespan': lifespan,
      'layers': layers
          .asMap()
          .entries
          .map((e) => {'level': e.key + 1, 'expRequired': e.value})
          .toList(),
    });
  }
  return {
    'version': 1,
    'realms': realms,
    'generatedAt': DateTime.now().toIso8601String(),
  };
}

List<int> _generateLayers(
    {required int base, required double growth, required int count}) {
  final list = <int>[];
  double current = base.toDouble();
  for (int i = 0; i < count; i++) {
    list.add(current.round());
    current *= growth;
  }
  return list;
}
