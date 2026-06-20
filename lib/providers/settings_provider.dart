import 'package:flutter/foundation.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service = SettingsService();
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _settings = await _service.load();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> update(AppSettings newSettings) async {
    _settings = newSettings;
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateDailyWords(int count) async {
    _settings = _settings.copyWith(dailyWords: count);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateShuffle(bool value) async {
    _settings = _settings.copyWith(shuffle: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateFontSize(double size) async {
    _settings = _settings.copyWith(fontSize: size);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateShowProgressBar(bool value) async {
    _settings = _settings.copyWith(showProgressBar: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateThemeMode(String mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateVocabFilePath(String? path) async {
    _settings = _settings.copyWith(vocabFilePath: path);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiEnabled(bool value) async {
    _settings = _settings.copyWith(aiEnabled: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiApiKey(String value) async {
    _settings = _settings.copyWith(aiApiKey: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiCustomUrl(String value) async {
    _settings = _settings.copyWith(aiCustomUrl: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiCustomModel(String value) async {
    _settings = _settings.copyWith(aiCustomModel: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiDifficulty(String value) async {
    _settings = _settings.copyWith(aiDifficulty: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiAutoGenerate(bool value) async {
    _settings = _settings.copyWith(aiAutoGenerate: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiPrefer(bool value) async {
    _settings = _settings.copyWith(aiPrefer: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiMaxTokens(int value) async {
    _settings = _settings.copyWith(aiMaxTokens: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiReasoningEffort(String value) async {
    _settings = _settings.copyWith(aiReasoningEffort: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateAiPreGenerate(bool value) async {
    _settings = _settings.copyWith(aiPreGenerate: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateTtsEnabled(bool value) async {
    _settings = _settings.copyWith(ttsEnabled: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateTtsAutoSpeak(bool value) async {
    _settings = _settings.copyWith(ttsAutoSpeak: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateSrsEnabled(bool value) async {
    _settings = _settings.copyWith(srsEnabled: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateNewCardsPerDay(int value) async {
    _settings = _settings.copyWith(newCardsPerDay: value);
    await _service.save(_settings);
    notifyListeners();
  }

  Future<void> updateMaxReviewsPerDay(int value) async {
    _settings = _settings.copyWith(maxReviewsPerDay: value);
    await _service.save(_settings);
    notifyListeners();
  }
}
