import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/ai_service.dart';
import '../services/example_cache_service.dart';
import '../services/settings_service.dart';

class AIProvider extends ChangeNotifier {
  final ExampleCacheService _cache = ExampleCacheService();
  final SettingsService _settingsService = SettingsService();

  AIService? _ai;
  bool _initialized = false;
  bool _generating = false;
  String _generatingWord = '';
  final Map<String, String> _examples = {};
  bool _testing = false;
  String? _testResult;
  bool _preGenerating = false;
  int _preGenerateTotal = 0;
  int _preGenerateCurrent = 0;

  bool get generating => _generating;
  String get generatingWord => _generatingWord;
  bool get initialized => _initialized;
  bool get testing => _testing;
  String? get testResult => _testResult;
  bool get preGenerating => _preGenerating;
  int get preGenerateCurrent => _preGenerateCurrent;
  int get preGenerateTotal => _preGenerateTotal;

  String? exampleFor(String word) => _examples[word];
  bool hasExampleFor(String word) => _examples.containsKey(word);

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _cache.init();
    final settings = await _settingsService.load();
    _ai = AIService(
      apiKey: settings.aiApiKey,
      baseUrl: settings.aiCustomUrl.isNotEmpty
          ? settings.aiCustomUrl
          : 'https://api.openai.com',
      model: settings.aiCustomModel.isNotEmpty
          ? settings.aiCustomModel
          : 'gpt-4o-mini',
      difficulty: settings.aiDifficulty,
      maxTokens: settings.aiMaxTokens,
      reasoningEffort: settings.aiReasoningEffort,
    );
    _initialized = true;
  }

  bool get enabled {
    if (_ai == null) return false;
    return _ai!.enabled;
  }

  Future<String?> getCachedExample(String word, String difficulty) async {
    await _ensureInitialized();
    return _cache.get(word, difficulty);
  }

  Future<String?> generateExample(
      String word, String meaning, String difficulty) async {
    await _ensureInitialized();
    if (_ai == null || !_ai!.enabled) return null;

    if (_examples.containsKey(word)) return _examples[word];

    final cached = await _cache.get(word, difficulty);
    if (cached != null) {
      _examples[word] = cached;
      return cached;
    }

    _generating = true;
    _generatingWord = word;
    notifyListeners();

    final result = await _ai!.generateExample(word, meaning);

    if (result != null) {
      await _cache.set(word, difficulty, result);
      _examples[word] = result;
    }

    _generating = false;
    _generatingWord = '';
    notifyListeners();
    return result;
  }

  void refreshSettings() {
    _initialized = false;
    _testResult = null;
    notifyListeners();
  }

  Future<void> testConnection() async {
    _testing = true;
    _testResult = null;
    notifyListeners();

    await _ensureInitialized();

    if (_ai == null || !_ai!.enabled) {
      _testResult = 'API Key 未设置';
      _testing = false;
      notifyListeners();
      return;
    }

    _testResult = await _ai!.test();

    _testing = false;
    notifyListeners();
  }

  Future<void> preGenerateExamples(List<Word> words, String difficulty) async {
    await _ensureInitialized();
    if (_ai == null || !_ai!.enabled) return;

    _preGenerating = true;
    _preGenerateTotal = words.length;
    _preGenerateCurrent = 0;
    notifyListeners();

    for (final w in words) {
      if (_examples.containsKey(w.word)) {
        _preGenerateCurrent++;
        notifyListeners();
        continue;
      }

      final cached = await _cache.get(w.word, difficulty);
      if (cached != null) {
        _examples[w.word] = cached;
        _preGenerateCurrent++;
        notifyListeners();
        continue;
      }

      final result = await _ai!.generateExample(w.word, w.meaning);
      if (result != null) {
        await _cache.set(w.word, difficulty, result);
        _examples[w.word] = result;
      }

      _preGenerateCurrent++;
      notifyListeners();
    }

    _preGenerating = false;
    notifyListeners();
  }
}
