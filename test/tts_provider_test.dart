import 'package:flutter_test/flutter_test.dart';
import 'package:oboeru_flutter/providers/tts_provider.dart';
import 'package:oboeru_flutter/services/tts_service.dart';

class _FakeTTSService extends TTSService {
  _FakeTTSService({this.speakResult = true});

  final bool speakResult;
  int speakCalls = 0;
  int stopCalls = 0;

  @override
  Future<bool> speak(String text, {String language = 'en'}) async {
    speakCalls += 1;
    return speakResult;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }
}

void main() {
  test('speak with empty text does not enter speaking state', () async {
    final service = _FakeTTSService();
    final provider = TTSProvider(tts: service);

    await provider.speak('');

    expect(provider.speaking, isFalse);
    expect(provider.lastError, isNull);
    expect(service.speakCalls, 0);
  });

  test('speak failure resets speaking and sets lastError', () async {
    final provider = TTSProvider(
      tts: _FakeTTSService(speakResult: false),
    );

    await provider.speak('hello');

    expect(provider.speaking, isFalse);
    expect(provider.lastError, isNotNull);
  });

  test('stop resets speaking and clears lastError', () async {
    final service = _FakeTTSService(speakResult: false);
    final provider = TTSProvider(tts: service);
    await provider.speak('hello');

    await provider.stop();

    expect(provider.speaking, isFalse);
    expect(provider.lastError, isNull);
    expect(service.stopCalls, 1);
  });
}
