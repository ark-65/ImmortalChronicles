import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';

/// A centralized service for managing game assets, supporting lazy loading
/// and unified parsing for JSON and YAML files.
class AssetService {
  static final AssetService _instance = AssetService._internal();
  factory AssetService() => _instance;
  AssetService._internal();

  Set<String>? _cachedManifest;

  /// Loads the asset manifest and returns the set of available asset paths.
  Future<Set<String>> getManifest() async {
    if (_cachedManifest != null) return _cachedManifest!;
    
    try {
      // Try legacy JSON manifest
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      _cachedManifest = manifestMap.keys.toSet();
      return _cachedManifest!;
    } catch (e) {
      debugPrint('[AssetService] Failed to load AssetManifest.json: $e');
      debugPrint('[AssetService] Using hardcoded fallback manifest.');
      _cachedManifest = _hardcodedFallbackManifest();
      return _cachedManifest!;
    }
  }

  Set<String> _hardcodedFallbackManifest() {
    return {
      'assets/events/age/age_0_3.yaml',
      'assets/events/age/age_4_6.yaml',
      'assets/events/age/age_7_12.yaml',
      'assets/events/age/age_13_18.yaml',
      'assets/events/age/age_mandatory.yaml',
      'assets/events/daily/mortal_daily.yaml',
      'assets/events/daily/immortal_daily.yaml',
      'assets/events/daily/mortal_events.yaml',
      'assets/events/daily/immortal_events.yaml',
      'assets/events/common/infancy.yaml',
      'assets/events/common/childhood.yaml',
      'assets/events/common/youth.yaml',
      'assets/events/career/sect_opportunity.yaml',
      'assets/events/family/clan_opportunity.yaml',
      'assets/events/family/commoner.yaml',
      'assets/events/family/noble.yaml',
      'assets/events/spatial/sect_grounds.yaml',
      'assets/events/templates/basics.yaml',
      'assets/families/families.yaml',
      'assets/sects/sects.yaml',
      'assets/weapons/weapons.yaml',
      'assets/medicines/medicines.yaml',
      'assets/techniques/cultivation.yaml',
      'assets/maps/six_realms.yaml',
      'assets/meta/stages.yaml',
      'assets/meta/realms/immortal.yaml',
      'assets/meta/elements.yaml',
    };
  }

  /// Loads and parses a list of assets from a directory or matching a prefix.
  Future<List<Map<String, dynamic>>> loadDirectory(String prefix) async {
    final manifest = await getManifest();
    final files = manifest.where((path) => path.startsWith(prefix)).toList();
    debugPrint('[AssetService] loadDirectory("$prefix") found ${files.length} files.');
    if (files.isEmpty) {
       debugPrint('[AssetService] Available keys snippet: ${manifest.take(10).join(', ')}');
    }
    
    final results = <Map<String, dynamic>>[];
    for (final path in files) {
      final data = await loadFile(path);
      if (data is List) {
        results.addAll(data.map((e) => Map<String, dynamic>.from(e)));
      } else if (data is Map) {
        results.add(Map<String, dynamic>.from(data));
      }
    }
    return results;
  }

  /// Loads and parses a single asset file (JSON or YAML).
  Future<dynamic> loadFile(String path) async {
    final raw = await rootBundle.loadString(path);
    if (path.endsWith('.yaml') || path.endsWith('.yml')) {
      final doc = loadYaml(raw);
      return _yamlToMap(doc);
    } else {
      return json.decode(raw);
    }
  }

  /// Recursively converts Yaml nodes to standard Dart Map/List.
  dynamic _yamlToMap(dynamic node) {
    if (node is YamlMap) {
      return node.map((k, v) => MapEntry(k.toString(), _yamlToMap(v)));
    } else if (node is YamlList) {
      return node.map((e) => _yamlToMap(e)).toList();
    }
    return node;
  }
}
