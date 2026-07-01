import 'dart:convert';
import 'dart:io' show Platform, Process;
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts? _tts;
  bool _flutterTtsInitialized = false;

  Future<bool> speak(String text, {String language = 'en'}) async {
    try {
      if (Platform.isLinux) {
        return _speakLinux(text, language);
      } else if (Platform.isMacOS) {
        return _speakMacOs(text);
      } else if (Platform.isWindows) {
        return _speakWindows(text);
      } else {
        return _speakFlutterTts(text, language);
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    await _tts?.stop();
  }

  Future<bool> _speakLinux(String text, String lang) async {
    final result =
        await Process.run('espeak', ['-v', lang, '-s', '140', '--', text]);
    return result.exitCode == 0;
  }

  Future<bool> _speakMacOs(String text) async {
    final result = await Process.run('say', ['-v', 'Samantha', text]);
    return result.exitCode == 0;
  }

  Future<bool> _speakWindows(String text) async {
    final encodedText = jsonEncode(text).replaceAll("'", "''");
    final result = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      'Add-Type -AssemblyName System.Speech; '
          '\$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; '
          "\$text = ConvertFrom-Json '$encodedText'; "
          '\$speak.Speak(\$text)',
    ]);
    return result.exitCode == 0;
  }

  Future<bool> _speakFlutterTts(String text, String lang) async {
    await _initFlutterTts();
    await _tts!.setLanguage(lang);
    final result = Platform.isAndroid
        ? await _tts!.speak(text, focus: true)
        : await _tts!.speak(text);
    return result == 1 || result == true;
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
