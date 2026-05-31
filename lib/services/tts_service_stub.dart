import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts? _tts;

  Future<void> speak(String text, {String language = 'en'}) async {
    try {
      _tts ??= FlutterTts();
      await _tts!.setLanguage(language);
      await _tts!.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    await _tts?.stop();
  }
}
