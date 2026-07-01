import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts? _tts;
  bool _flutterTtsInitialized = false;

  Future<bool> speak(String text, {String language = 'en'}) async {
    try {
      await _initFlutterTts();
      await _tts!.setLanguage(language);
      final result = await _tts!.speak(text);
      return result == 1 || result == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    await _tts?.stop();
  }

  Future<void> _initFlutterTts() async {
    _tts ??= FlutterTts();
    if (_flutterTtsInitialized) return;

    await _tts!.awaitSpeakCompletion(true);
    _tts!.setCompletionHandler(() {});
    _tts!.setErrorHandler((_) {});
    _tts!.setCancelHandler(() {});
    _flutterTtsInitialized = true;
  }
}
