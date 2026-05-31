class AiExample {
  final String sentence;
  final String translation;

  const AiExample({required this.sentence, required this.translation});

  String toCache() => jsonEncode({'sentence': sentence, 'translation': translation});

  factory AiExample.fromCache(String data) {
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return AiExample(
        sentence: (map['sentence'] as String?) ?? '',
        translation: (map['translation'] as String?) ?? '',
      );
    } catch (_) {
      final parts = data.split('|||');
      return AiExample(sentence: parts[0], translation: parts.length > 1 ? parts[1] : '');
    }
  }
}

import 'dart:convert';
