import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LibraryDirsService {
  static const String _key = 'library_dirs_paths_v1';

  Future<List<String>> getDirectories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final List<dynamic> json = jsonDecode(raw);
    return json.cast<String>();
  }

  Future<void> addDirectory(String path) async {
    final dirs = await getDirectories();
    if (!dirs.contains(path)) {
      final updated = [...dirs, path];
      await _save(updated);
    }
  }

  Future<void> removeDirectory(String path) async {
    final dirs = await getDirectories();
    final updated = dirs.where((e) => e != path).toList();
    await _save(updated);
  }

  Future<void> clear() async {
    await _save(const []);
  }

  Future<void> _save(List<String> dirs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(dirs));
  }
}


