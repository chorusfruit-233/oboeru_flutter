import 'package:flutter/foundation.dart';
import '../services/tts_service.dart';

class TTSProvider extends ChangeNotifier {
  TTSProvider({TTSService? tts}) : _tts = tts ?? TTSService();

  final TTSService _tts;
  bool _speaking = false;
  String? _lastError;

  bool get speaking => _speaking;
  String? get lastError => _lastError;

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    _speaking = true;
    _lastError = null;
    notifyListeners();
    try {
      final ok = await _tts.speak(text);
      if (!ok) {
        _lastError = '语音朗读失败，请确认系统 TTS 引擎已安装并启用。';
      }
    } finally {
      _speaking = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _speaking = false;
    _lastError = null;
    notifyListeners();
  }
}
