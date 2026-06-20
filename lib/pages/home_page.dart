import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/learning_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/srs_provider.dart';
import '../services/vocabulary_service.dart';
import '../widgets/progress_bar_widget.dart';
import 'learning_page.dart';
import 'review_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  VocabularyProvider? _vocabProv;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vocabProv = context.read<VocabularyProvider>();
      final srsProv = context.read<SrsProvider>();
      srsProv.refreshStats(vocabProv.allWords);
      vocabProv.addListener(_onVocabChanged);
      _vocabProv = vocabProv;
    });
  }

  @override
  void dispose() {
    _vocabProv?.removeListener(_onVocabChanged);
    super.dispose();
  }

  void _onVocabChanged() {
    if (!mounted) return;
    final vocabProv = context.read<VocabularyProvider>();
    context.read<SrsProvider>().refreshStats(vocabProv.allWords);
  }

  @override
  Widget build(BuildContext context) {
    final vocabProv = context.watch<VocabularyProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final aiProv = context.watch<AIProvider>();
    final quizProv = context.watch<QuizProvider>();
    final srsProv = context.watch<SrsProvider>();
    final settings = settingsProv.settings;
    final fontSize = settings.fontSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oboeru'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(flex: 1),
            Icon(
              Icons.auto_stories,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Oboeru',
              style: TextStyle(
                fontSize: fontSize * 2.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '智能背单词',
              style: TextStyle(
                fontSize: fontSize,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(flex: 1),

            if (vocabProv.isLoading)
              const CircularProgressIndicator()
            else if (vocabProv.error != null)
              Text(
                vocabProv.error!,
                style: TextStyle(color: Colors.red, fontSize: fontSize),
              )
            else ...[
              if (settings.srsEnabled && vocabProv.hasWords)
                _buildSrsStatsCard(context, srsProv, settings, fontSize)
              else
                _buildVocabCard(vocabProv, settings, fontSize),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: vocabProv.hasWords
                      ? () => _startLearning(context, vocabProv, settings, aiProv, srsProv)
                      : null,
                  icon: aiProv.preGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    aiProv.preGenerating ? '正在预生成例句...' : '开始学习',
                    style: TextStyle(fontSize: fontSize * 1.1),
                  ),
                ),
              ),
            ],

            if (quizProv.reviewWords.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReviewPage(
                          words: quizProv.reviewWords,
                          title: '复习错词',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.replay),
                  label: Text(
                    '复习错词 (${quizProv.reviewWords.length})',
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ),
            ],

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabCard(
    VocabularyProvider vocabProv,
    AppSettings settings,
    double fontSize,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              vocabProv.hasWords
                  ? '词库已加载 (${vocabProv.allWords.length} 个单词)'
                  : '请先导入词库',
              style: TextStyle(fontSize: fontSize),
            ),
            if (settings.showProgressBar) ...[
              const SizedBox(height: 16),
              ProgressBarWidget(
                current: 0,
                total: settings.dailyWords,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSrsStatsCard(
    BuildContext context,
    SrsProvider srsProv,
    AppSettings settings,
    double fontSize,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '词库已加载 (${srsProv.stats.total + srsProv.freshCount} 个单词)',
              style: TextStyle(fontSize: fontSize),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(
                  '待复习',
                  srsProv.dueCount.toString(),
                  Colors.orange,
                  fontSize,
                ),
                _buildStat(
                  '新词',
                  srsProv.freshCount.toString(),
                  Colors.blue,
                  fontSize,
                ),
                _buildStat(
                  '已掌握',
                  srsProv.learnedCount.toString(),
                  Colors.green,
                  fontSize,
                ),
              ],
            ),
            if (settings.showProgressBar) ...[
              const SizedBox(height: 16),
              ProgressBarWidget(
                current: srsProv.learnedCount,
                total: srsProv.stats.total + srsProv.freshCount,
              ),
            ],
          ],
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
            fontSize: fontSize * 1.4,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: fontSize * 0.8)),
      ],
    );
  }

  Future<void> _startLearning(
    BuildContext context,
    VocabularyProvider vocabProv,
    AppSettings settings,
    AIProvider aiProv,
    SrsProvider srsProv,
  ) async {
    if (settings.srsEnabled) {
      await srsProv.startSession(
        vocabProv.allWords,
        dailyWords: settings.dailyWords,
        newCardsPerDay: settings.newCardsPerDay,
        maxReviewsPerDay: settings.maxReviewsPerDay,
        shuffle: settings.shuffle,
      );
      if (srsProv.sessionQueue.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('今日暂无待复习或新词')),
        );
        return;
      }
      final sessionWords = srsProv.sessionQueue;
      if (settings.aiEnabled && settings.aiPreGenerate && sessionWords.isNotEmpty) {
        await aiProv.preGenerateExamples(sessionWords, settings.aiDifficulty);
      }
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LearningPage()),
      );
      return;
    }

    final vocabService = VocabularyService();
    final dailyWords = vocabService.pickDailyWords(
      vocabProv.allWords,
      settings.dailyWords,
      settings.shuffle,
    );

    if (settings.aiEnabled && settings.aiPreGenerate && dailyWords.isNotEmpty) {
      await aiProv.preGenerateExamples(dailyWords, settings.aiDifficulty);
    }

    if (!context.mounted) return;
    context.read<LearningProvider>().startLearning(dailyWords);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LearningPage()),
    );
  }
}
