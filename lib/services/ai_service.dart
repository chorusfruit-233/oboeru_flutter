import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String apiKey;
  final String baseUrl;
  final String model;
  final String difficulty;
  final int maxTokens;
  final String reasoningEffort;

  const AIService({
    this.apiKey = '',
    this.baseUrl = 'https://api.openai.com',
    this.model = 'gpt-4o-mini',
    this.difficulty = 'junior',
    this.maxTokens = 300,
    this.reasoningEffort = 'disabled',
  });

  bool get enabled => apiKey.isNotEmpty;

  String get _chatUrl {
    var url = baseUrl;
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.endsWith('/chat/completions')) {
      url = url.substring(0, url.length - '/chat/completions'.length);
    }
    if (url.endsWith('/v1')) {
      return '$url/chat/completions';
    }
    return '$url/v1/chat/completions';
  }

  Map<String, dynamic> _buildBody(Map<String, dynamic> extra) {
    final body = <String, dynamic>{
      'model': model,
      ...extra,
    };
    if (reasoningEffort != 'disabled') {
      body['reasoning_effort'] = reasoningEffort;
    }
    return body;
  }

  Future<String?> generateExample(String word, String meaning) async {
    if (!enabled) return null;

    final url = _chatUrl;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(_buildBody({
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt(),
            },
            {
              'role': 'user',
              'content':
                  'Generate an example sentence for the word "$word" (${meaning}). '
                  'Return the sentence followed by "||" followed by its Chinese translation. No other text.',
            },
          ],
          'temperature': 0.7,
          'max_tokens': maxTokens,
        })),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['choices']?[0]?['message']?['content'] as String?;
        return content?.trim();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> test() async {
    if (!enabled) return 'API Key 未设置';

    final url = _chatUrl;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(_buildBody({
          'messages': [
            {'role': 'user', 'content': 'Say "Connection successful" in English, then "||", then its Chinese translation.'},
          ],
          'temperature': 0,
          'max_tokens': maxTokens,
        })),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) {
          return '连接异常: choices 为空 - 响应: ${response.body}';
        }
        final message = (choices[0] as Map<String, dynamic>?) ?? {};
        final msgContent = message['message'] ?? message['text'] ?? message['delta'];
        String? content;
        if (msgContent is Map) {
          content = (msgContent['content'] as String?)?.trim();
          content ??= (msgContent['reasoning'] as String?)?.trim();
        } else if (msgContent is String) {
          content = msgContent.trim();
        }
        if (content != null && content.isNotEmpty) return '连接成功: $content';
        return '连接成功 (响应格式非预期): ${response.body}';
      }

      final errorBody = response.body;
      if (errorBody.isNotEmpty) {
        try {
          final errData = jsonDecode(errorBody);
          final msg = errData['error']?['message'] ?? errData.toString();
          return '[${response.statusCode}] $msg';
        } catch (_) {
          return '[${response.statusCode}] $errorBody';
        }
      }
      return 'HTTP ${response.statusCode}';
    } catch (e) {
      return '网络错误: $e';
    }
  }

  String _systemPrompt() {
    final level = switch (difficulty) {
      'junior' => 'simple and easy for beginners',
      'intermediate' => 'everyday, natural English',
      'senior' => 'academic or professional English',
      _ => 'simple and easy for beginners',
    };
    return 'You are an English tutor. Generate one $level example sentence '
        'using the given word in context. Use the word naturally. '
        'Return the sentence followed by "||" followed by its Chinese translation. '
        'No other text, no labels.';
  }
}
