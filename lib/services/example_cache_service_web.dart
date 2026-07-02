import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExampleCacheService {
  static const _key = 'example_cache';
  Map<String, String>? _cache;
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final content = _prefs.getString(_key);
    if (content == null || content.isEmpty) {
      _cache = {};
      return;
    }
    _cache = (jsonDecode(content) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as String));
  }

  Future<void> _save() async {
    if (_cache == null) return;
    await _prefs.setString(_key, jsonEncode(_cache));
  }

  String? get(String word, String difficulty) {
    return _cache?['$word|$difficulty'];
  }

  Future<void> set(String word, String difficulty, String example) async {
    _cache?['$word|$difficulty'] = example;
    await _save();
  }
}
