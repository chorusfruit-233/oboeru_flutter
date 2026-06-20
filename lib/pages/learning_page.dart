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
import '../providers/srs_provider.dart';
import '../services/srs_algorithm.dart';
import '../widgets/word_card.dart';
import '../widgets/progress_bar_widget.dart';
import 'quiz_page.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final srsProv = context.watch<SrsProvider>();
    final useSrs = settings.srsEnabled && srsProv.hasSession;

    if (useSrs) {
      return _buildSrsView(context, srsProv, settings);
    }
    return _buildLegacyView(context, settings);
  }

  // ============================ SRS view ============================

  Widget _buildSrsView(
    BuildContext context,
    SrsProvider prov,
    AppSettings settings,
  ) {
    final fontSize = settings.fontSize;
    final showProgress = settings.showProgressBar;

    if (prov.sessionComplete || prov.sessionQueue.isEmpty) {
      return _buildSrsComplete(context, prov, fontSize);
    }

    final word = prov.currentWord!;
    final aiProv = context.watch<AIProvider>();
    final favoritesProv = context.watch<FavoritesProvider>();
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

    final stateLabel = prov.cardStateLabel(word.word);

    return Scaffold(
      appBar: AppBar(
        title: const Text('学习'),
        centerTitle: true,
        actions: [
          if (stateLabel != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  stateLabel,
                  style: TextStyle(
                    fontSize: fontSize * 0.8,
                    color: stateLabel == '新词'
                        ? Colors.blue
                        : stateLabel == '重学'
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '${prov.currentIndex + 1}/${prov.sessionTotal}',
                style: TextStyle(fontSize: fontSize * 0.85),
              ),
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
                current: prov.currentIndex + 1,
                total: prov.sessionTotal,
                showLabel: false,
              ),
            ),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: WordCard(
                word: word,
                isFlipped: prov.isFlipped,
                fontSize: fontSize,
                onTap: () {
                  final wasFlipped = prov.isFlipped;
                  prov.flip();
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
                        final ex = displayExample!;
                        final en = ex.contains('||')
                            ? ex.split('||').first.trim()
                            : ex;
                        context.read<TTSProvider>().speak(en);
                      }
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final w = prov.currentWord;
                    if (w != null) {
                      context.read<FavoritesProvider>().toggle(w);
                    }
                  },
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : null,
                  ),
                  tooltip: isFav ? '取消收藏' : '收藏',
                ),
              ],
            ),
          ),
          _buildSrsRatingBar(context, prov, word.word, fontSize),
        ],
      ),
    );
  }

  Widget _buildSrsRatingBar(
    BuildContext context,
    SrsProvider prov,
    String word,
    double fontSize,
  ) {
    if (!prov.isFlipped) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Text(
            '翻转卡片后给出评分',
            style: TextStyle(
              fontSize: fontSize * 0.85,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    String fmt(int days) => days <= 0 ? '1天' : '$days天';

    final configs = [
      _RatingConfig(Quality.again, '忘', Colors.red, Icons.close),
      _RatingConfig(Quality.hard, '难', Colors.deepOrange, Icons.remove),
      _RatingConfig(Quality.good, '良', Colors.blue, Icons.check),
      _RatingConfig(Quality.easy, '易', Colors.green, Icons.double_arrow),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        child: Row(
          children: configs.map((c) {
            final days = prov.previewInterval(word, c.quality);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilledButton.tonal(
                  onPressed: () => prov.rate(c.quality),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      c.color.withAlpha(40),
                    ),
                    foregroundColor: WidgetStatePropertyAll(c.color),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.label, style: TextStyle(fontSize: fontSize)),
                        Text(
                          fmt(days),
                          style: TextStyle(fontSize: fontSize * 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSrsComplete(
    BuildContext context,
    SrsProvider prov,
    double fontSize,
  ) {
    final reviewed = prov.sessionReviewed;
    final again = prov.sessionAgain;
    final good = reviewed - again;

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
                '本次学习完成！',
                style: TextStyle(
                  fontSize: fontSize * 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '共复习 $reviewed 个单词',
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('已掌握', good.toString(), Colors.green, fontSize),
                  _buildStat('需重学', again.toString(), Colors.red, fontSize),
                  _buildStat('总计', reviewed.toString(), Colors.blue, fontSize),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizPage(
                          words: prov.sessionQueue,
                          allWords: context.read<VocabularyProvider>().allWords,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz),
                  label: Text(
                    '测试本组',
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

  Widget _buildStat(String label, String value, Color color, double fontSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize * 1.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: fontSize * 0.85)),
      ],
    );
  }

  // ============================ Legacy view ============================

  Widget _buildLegacyView(BuildContext context, AppSettings settings) {
    final learningProv = context.watch<LearningProvider>();
    final vocabProv = context.watch<VocabularyProvider>();
    final fontSize = settings.fontSize;
    final showProgress = settings.showProgressBar;

    if (learningProv.isComplete) {
      return _buildLegacyComplete(context, learningProv, vocabProv, fontSize);
    }

    final word = learningProv.currentWord!;
    final favoritesProv = context.watch<FavoritesProvider>();
    final aiProv = context.watch<AIProvider>();
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
                        final ex = displayExample!;
                        final en = ex.contains('||')
                            ? ex.split('||').first.trim()
                            : ex;
                        context.read<TTSProvider>().speak(en);
                      }
                    : null,
              ),
            ),
          ),
          if (showProgress)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildLegacyActionButtons(context, learningProv, isFav, fontSize),
            ),
          _buildLegacyNavBar(context, learningProv, vocabProv, fontSize),
        ],
      ),
    );
  }

  Widget _buildLegacyActionButtons(
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

  Widget _buildLegacyNavBar(
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

  Widget _buildLegacyComplete(
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

class _RatingConfig {
  final Quality quality;
  final String label;
  final Color color;
  final IconData icon;
  const _RatingConfig(this.quality, this.label, this.color, this.icon);
}
