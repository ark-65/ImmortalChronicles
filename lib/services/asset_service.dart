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
      rethrow;
    }
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
