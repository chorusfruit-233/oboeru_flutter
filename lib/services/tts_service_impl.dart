import 'dart:io' show Platform, Process;
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts? _tts;

  Future<void> speak(String text, {String language = 'en'}) async {
    if (Platform.isLinux) {
      await _speakLinux(text, language);
    } else if (Platform.isMacOS) {
      await _speakMacOs(text);
    } else if (Platform.isWindows) {
      await _speakWindows(text);
    } else {
      await _speakFlutterTts(text, language);
    }
  }

  Future<void> stop() async {
    await _tts?.stop();
  }

  Future<void> _speakLinux(String text, String lang) async {
    try {
      await Process.run('espeak', ['-v', lang, '-s', '140', '--', text]);
    } catch (_) {}
  }

  Future<void> _speakMacOs(String text) async {
    try {
      await Process.run('say', ['-v', 'Samantha', text]);
    } catch (_) {}
  }

  Future<void> _speakWindows(String text) async {
    try {
      await Process.run('powershell', [
        '-Command',
        'Add-Type -AssemblyName System.Speech; '
        '\$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; '
        '\$speak.Speak("$text")',
      ]);
    } catch (_) {}
  }

  Future<void> _speakFlutterTts(String text, String lang) async {
    try {
      _tts ??= FlutterTts();
      await _tts!.setLanguage(lang);
      await _tts!.speak(text);
    } catch (_) {}
  }
}
