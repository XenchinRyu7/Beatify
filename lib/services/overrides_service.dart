import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OverridesService {
  static final OverridesService instance = OverridesService._();
  OverridesService._();

  static const String _artistKey = 'artist_override_v1';
  static const String _titleKey = 'title_override_v1';

  Future<void> setArtistOverride(String songId, String artist) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_artistKey);
    final map = raw == null ? <String, String>{} : Map<String, String>.from(jsonDecode(raw));
    map[songId] = artist;
    await prefs.setString(_artistKey, jsonEncode(map));
  }

  Future<String?> getArtistOverride(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_artistKey);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(jsonDecode(raw));
    final val = map[songId];
    return val is String ? val : null;
  }

  Future<void> setTitleOverride(String songId, String title) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_titleKey);
    final map = raw == null ? <String, String>{} : Map<String, String>.from(jsonDecode(raw));
    map[songId] = title;
    await prefs.setString(_titleKey, jsonEncode(map));
  }

  Future<String?> getTitleOverride(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_titleKey);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(jsonDecode(raw));
    final val = map[songId];
    return val is String ? val : null;
  }
}


