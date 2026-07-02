import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static const _vocabPrefix = 'web_vocab:';
  late SharedPreferences _prefs;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get vocabDirPath => 'web://vocabulary';
  String get progressPath => 'web://progress.json';
  String get favoritesPath => 'web://favorites.json';
  String get srsPath => 'web://srs_state.json';

  Future<void> writeJson(String path, dynamic data) async {
    await _prefs.setString(path, jsonEncode(data));
  }

  Future<dynamic> readJson(String path) async {
    final content = _prefs.getString(path);
    if (content == null || content.isEmpty) return null;
    return jsonDecode(content);
  }

  Future<List<String>> readVocabFile(String filePath) async {
    final content = await _readText(filePath);
    if (content == null || content.isEmpty) return [];
    return content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();
  }

  Future<String> copyVocabToAppDir(String sourcePath) async {
    final content = await _readText(sourcePath);
    if (content == null) {
      throw UnsupportedError('Web import requires in-memory file content');
    }

    final name = sourcePath.split('/').last;
    final savedPath = '$vocabDirPath/$name';
    await _prefs.setString('$_vocabPrefix$savedPath', content);
    return savedPath;
  }

  Future<String> saveVocabContent(
    String name,
    Uint8List bytes, {
    Encoding encoding = utf8,
  }) async {
    final savedPath = '$vocabDirPath/$name';
    await _prefs.setString('$_vocabPrefix$savedPath', encoding.decode(bytes));
    return savedPath;
  }

  Future<String?> _readText(String path) async {
    if (path.startsWith(vocabDirPath)) {
      return _prefs.getString('$_vocabPrefix$path');
    }
    if (path.startsWith('assets/')) {
      return rootBundle.loadString(path);
    }
    return _prefs.getString('$_vocabPrefix$path');
  }
}
