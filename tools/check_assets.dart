import 'dart:io';

import 'package:yaml/yaml.dart';

/// Simple asset schema sanity check for CI/debug.
/// Usage: dart tools/check_assets.dart
void main() async {
  final requiredTables = [
    'assets/events/family/clan_chance.yaml',
    'assets/events/career/sect_chance.yaml',
    'assets/events/career/sect_trials.yaml',
    'assets/events/career/sect_daily.yaml',
  ];

  final requiredRefs = [
    'assets/sects/sects.yaml',
    'assets/families/families.yaml',
    'assets/techniques/cultivation.yaml',
    'assets/techniques/martial_arts.yaml',
    'assets/meta/realms.yaml',
    'assets/meta/stages.yaml',
    'assets/meta/elements.yaml',
  ];

  final missing = <String>[];

  for (final path in [...requiredTables, ...requiredRefs]) {
    if (!File(path).existsSync()) missing.add(path);
  }

  if (missing.isNotEmpty) {
    stderr.writeln('Missing asset files:\n - ${missing.join('\n - ')}');
    exit(1);
  }

  // Basic YAML validity check
  for (final path in [...requiredTables, ...requiredRefs]) {
    try {
      final text = await File(path).readAsString();
      loadYaml(text);
    } catch (e) {
      stderr.writeln('YAML parse error in $path: $e');
      exit(1);
    }
  }

  stdout.writeln('Asset check passed.');
}
