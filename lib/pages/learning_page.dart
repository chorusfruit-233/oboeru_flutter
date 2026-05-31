import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../models/settings.dart';
import '../providers/learning_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/tts_provider.dart';
import '../widgets/word_card.dart';
import '../widgets/progress_bar_widget.dart';
import 'quiz_page.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final learningProv = context.watch<LearningProvider>();
    final favoritesProv = context.watch<FavoritesProvider>();
    final vocabProv = context.watch<VocabularyProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final aiProv = context.watch<AIProvider>();
    final fontSize = settings.fontSize;
    final showProgress = settings.showProgressBar;

    if (learningProv.isComplete) {
      return _buildComplete(context, learningProv, vocabProv, fontSize);
    }

    final word = learningProv.currentWord!;
    final isFav = favoritesProv.isFavorite(word.word);
    final aiExample = aiProv.exampleFor(word.word);
    final preferAi = settings.aiEnabled && settings.aiPrefer;

    final String? displayExample;
    final String? exampleSource;

    if (preferAi && aiExample != null) {
      displayExample = aiExample;
      exampleSource = 'ai';
    } else if (word.example.isNotEmpty) {
      displayExample = word.example;
      exampleSource = 'builtin';
    } else if (aiExample != null) {
      displayExample = aiExample;
      exampleSource = 'ai';
    } else {
      displayExample = null;
      exampleSource = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('学习'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${learningProv.currentIndex + 1}/${learningProv.totalCount}',
              style: TextStyle(fontSize: fontSize * 0.85),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (showProgress) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: ProgressBarWidget(
                current: learningProv.currentIndex + 1,
                total: learningProv.totalCount,
                showLabel: false,
              ),
            ),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: WordCard(
                word: word,
                isFlipped: learningProv.isFlipped,
                fontSize: fontSize,
                onTap: () {
                  final wasFlipped = learningProv.isFlipped;
                  learningProv.flip();
                  if (!wasFlipped) {
                    _onFlip(context, word, settings, aiProv);
                  }
                },
                example: displayExample,
                exampleSource: exampleSource,
                aiGenerating: aiProv.generating && aiProv.generatingWord == word.word,
                onGenerateExample: settings.aiEnabled
                    ? () => aiProv.generateExample(
                          word.word,
                          word.meaning,
                          settings.aiDifficulty,
                        )
                    : null,
                onSpeak: settings.ttsEnabled
                    ? () => context.read<TTSProvider>().speak(word.word)
                    : null,
                onSpeakExample: settings.ttsEnabled && displayExample != null
                    ? () {
                        final en = displayExample!.contains('||')
                            ? displayExample!.split('||').first.trim()
                            : displayExample!;
                        context.read<TTSProvider>().speak(en);
                      }
                    : null,
              ),
            ),
          ),
          if (showProgress)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildActionButtons(context, learningProv, isFav, fontSize),
            ),
          _buildNavBar(context, learningProv, vocabProv, fontSize),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    LearningProvider prov,
    bool isFav,
    double fontSize,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            final word = prov.currentWord;
            if (word != null) {
              context.read<FavoritesProvider>().toggle(word);
            }
          },
          icon: Icon(
            isFav ? Icons.star : Icons.star_border,
            color: isFav ? Colors.amber : null,
          ),
          tooltip: isFav ? '取消收藏' : '收藏',
        ),
        const SizedBox(width: 16),
        FilledButton.tonalIcon(
          onPressed: () {
            prov.markLearned();
            prov.next();
          },
          icon: const Icon(Icons.check),
          label: Text('已掌握', style: TextStyle(fontSize: fontSize)),
        ),
      ],
    );
  }

  Widget _buildNavBar(
    BuildContext context,
    LearningProvider prov,
    VocabularyProvider vocabProv,
    double fontSize,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: prov.hasPrevious ? () => prov.previous() : null,
              icon: const Icon(Icons.arrow_back_ios),
            ),
            TextButton(
              onPressed: () {
                prov.goToEnd();
              },
              child: Text('跳过学习 →', style: TextStyle(fontSize: fontSize)),
            ),
            IconButton(
              onPressed: prov.hasNext ? () => prov.next() : null,
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }

  void _onFlip(BuildContext context, Word word, AppSettings settings, AIProvider aiProv) {
    if (settings.aiAutoGenerate && settings.aiEnabled) {
      if (settings.aiPrefer || word.example.isEmpty) {
        if (!aiProv.hasExampleFor(word.word)) {
          aiProv.generateExample(word.word, word.meaning, settings.aiDifficulty);
        }
      }
    }
    if (settings.ttsAutoSpeak && settings.ttsEnabled) {
      context.read<TTSProvider>().speak(word.word);
    }
  }

  Widget _buildComplete(
    BuildContext context,
    LearningProvider prov,
    VocabularyProvider vocabProv,
    double fontSize,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习完成'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '预习完成！',
                style: TextStyle(
                  fontSize: fontSize * 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '共浏览了 ${prov.totalCount} 个单词',
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuizPage(
                          words: prov.todaysWords,
                          allWords: vocabProv.allWords,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz),
                  label: Text(
                    '开始测试',
                    style: TextStyle(fontSize: fontSize * 1.1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  prov.reset();
                  Navigator.of(context).pop();
                },
                child: Text(
                  '返回首页',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
