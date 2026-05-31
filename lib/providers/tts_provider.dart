import 'package:flutter/foundation.dart';
import '../services/tts_service.dart';

class TTSProvider extends ChangeNotifier {
  final TTSService _tts = TTSService();
  bool _speaking = false;

  bool get speaking => _speaking;

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    _speaking = true;
    notifyListeners();
    await _tts.speak(text);
    _speaking = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await _tts.stop();
    _speaking = false;
    notifyListeners();
  }
}
