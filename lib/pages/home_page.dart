import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/learning_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/quiz_provider.dart';
import '../services/vocabulary_service.dart';
import '../widgets/progress_bar_widget.dart';
import 'learning_page.dart';
import 'review_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vocabProv = context.watch<VocabularyProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final aiProv = context.watch<AIProvider>();
    final quizProv = context.watch<QuizProvider>();
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
              Card(
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
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: vocabProv.hasWords
                      ? () => _startLearning(context, vocabProv, settings, aiProv)
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

  Future<void> _startLearning(
    BuildContext context,
    VocabularyProvider vocabProv,
    AppSettings settings,
    AIProvider aiProv,
  ) async {
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
