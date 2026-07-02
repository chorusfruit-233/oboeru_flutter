import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static StorageService? _instance;
  late Directory _appDir;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> init() async {
    _appDir = await getApplicationDocumentsDirectory();
  }

  Directory get appDir => _appDir;
  String get vocabDirPath => '${_appDir.path}/vocabulary';
  String get progressPath => '${_appDir.path}/progress.json';
  String get favoritesPath => '${_appDir.path}/favorites.json';
  String get srsPath => '${_appDir.path}/srs_state.json';

  Future<Directory> getVocabDir() async {
    final dir = Directory(vocabDirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> writeJson(String path, dynamic data) async {
    final file = File(path);
    await file.writeAsString(jsonEncode(data));
  }

  Future<dynamic> readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    if (content.isEmpty) return null;
    return jsonDecode(content);
  }

  Future<List<String>> readVocabFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    return content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();
  }

  Future<String> copyVocabToAppDir(String sourcePath) async {
    final source = File(sourcePath);
    final name = source.uri.pathSegments.last;
    final destDir = await getVocabDir();
    final dest = File('${destDir.path}/$name');
    await source.copy(dest.path);
    return dest.path;
  }

  Future<String> saveVocabContent(String name, Uint8List bytes) async {
    final destDir = await getVocabDir();
    final dest = File('${destDir.path}/$name');
    await dest.writeAsBytes(bytes);
    return dest.path;
  }
}
