import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExampleCacheService {
  Map<String, String>? _cache;
  late String _cachePath;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _cachePath = '${dir.path}/example_cache.json';
    await _load();
  }

  Future<void> _load() async {
    final file = File(_cachePath);
    if (!await file.exists()) {
      _cache = {};
      return;
    }
    final content = await file.readAsString();
    if (content.isEmpty) {
      _cache = {};
      return;
    }
    _cache = (jsonDecode(content) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as String));
  }

  Future<void> _save() async {
    if (_cache == null) return;
    final file = File(_cachePath);
    await file.writeAsString(jsonEncode(_cache));
  }

  String? get(String word, String difficulty) {
    return _cache?['$word|$difficulty'];
  }

  Future<void> set(String word, String difficulty, String example) async {
    _cache?['$word|$difficulty'] = example;
    await _save();
  }
}
