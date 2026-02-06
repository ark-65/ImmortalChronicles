import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_state.dart';

class StorageService {
  static const _key = 'life_save_v1';

  Future<PlayerState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return PlayerState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(PlayerState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
