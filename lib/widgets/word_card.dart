import 'package:flutter/material.dart';
import '../models/word.dart';

class WordCard extends StatelessWidget {
  final Word word;
  final bool isFlipped;
  final VoidCallback onTap;
  final double fontSize;
  final String? example;
  final String? exampleSource;
  final bool aiGenerating;
  final VoidCallback? onGenerateExample;
  final VoidCallback? onSpeak;
  final VoidCallback? onSpeakExample;

  const WordCard({
    super.key,
    required this.word,
    required this.isFlipped,
    required this.onTap,
    this.fontSize = 16.0,
    this.example,
    this.exampleSource,
    this.aiGenerating = false,
    this.onGenerateExample,
    this.onSpeak,
    this.onSpeakExample,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isFlipped ? _buildBack(context) : _buildFront(context),
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return Card(
      key: const ValueKey('front'),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onSpeak != null)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: onSpeak,
                  tooltip: '朗读',
                ),
              ),
            Text(
              word.word,
              style: TextStyle(
                fontSize: fontSize * 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (word.pronunciation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                word.pronunciation,
                style: TextStyle(
                  fontSize: fontSize * 0.85,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              word.pos.isNotEmpty ? '/${word.pos}/' : '',
              style: TextStyle(
                fontSize: fontSize * 0.85,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '点击查看释义',
              style: TextStyle(
                fontSize: fontSize * 0.75,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Card(
      key: const ValueKey('back'),
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onSpeak != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: onSpeak,
                    tooltip: '朗读',
                  ),
              ],
            ),
            Text(
              word.word,
              style: TextStyle(
                fontSize: fontSize * 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (word.pronunciation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                word.pronunciation,
                style: TextStyle(fontSize: fontSize * 0.85),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              word.pos.isNotEmpty ? '/${word.pos}/' : '',
              style: TextStyle(fontSize: fontSize * 0.85),
            ),
            const SizedBox(height: 20),
            Text(
              word.meaning,
              style: TextStyle(
                fontSize: fontSize * 1.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (example != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(60),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          exampleSource == 'ai'
                              ? Icons.auto_awesome
                              : Icons.bookmark_border,
                          size: fontSize * 0.85,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exampleSource == 'ai' ? 'AI 例句' : '词库例句',
                          style: TextStyle(
                              fontSize: fontSize * 0.75, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (exampleSource == 'ai') ...[
                      _buildAiExampleText(example!, fontSize),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              example!,
                              style: TextStyle(
                                  fontSize: fontSize,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          if (onSpeakExample != null)
                            IconButton(
                              icon: const Icon(Icons.volume_up, size: 18),
                              onPressed: onSpeakExample,
                              tooltip: '朗读例句',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.only(left: 8),
                            ),
                        ],
                      ),
                      if (word.exampleMeaning.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          word.exampleMeaning,
                          style: TextStyle(
                              fontSize: fontSize * 0.85, color: Colors.black54),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
            if (aiGenerating) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                '正在生成例句...',
                style:
                    TextStyle(fontSize: fontSize * 0.75, color: Colors.black54),
              ),
            ],
            if (onGenerateExample != null &&
                example == null &&
                !aiGenerating) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onGenerateExample,
                  icon: Icon(Icons.auto_awesome, size: fontSize),
                  label: Text(
                    'AI 生成例句',
                    style: TextStyle(fontSize: fontSize * 0.85),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              '点击翻转',
              style: TextStyle(
                fontSize: fontSize * 0.75,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiExampleText(String text, double fontSize) {
    final parts = text.split('||');
    final en = parts.isNotEmpty ? parts[0].trim() : text;
    final zh = parts.length > 1 ? parts.sublist(1).join('||').trim() : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                en,
                style:
                    TextStyle(fontSize: fontSize, fontStyle: FontStyle.italic),
              ),
            ),
            if (onSpeakExample != null)
              IconButton(
                icon: const Icon(Icons.volume_up, size: 18),
                onPressed: onSpeakExample,
                tooltip: '朗读例句',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(left: 8),
              ),
          ],
        ),
        if (zh.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            zh,
            style: TextStyle(fontSize: fontSize * 0.85, color: Colors.black54),
          ),
        ],
      ],
    );
  }
}
