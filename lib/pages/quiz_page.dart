import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../models/settings.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/learning_provider.dart';
import '../providers/tts_provider.dart';
import '../providers/srs_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/option_button.dart';
import '../widgets/progress_bar_widget.dart';
import 'review_page.dart';

class QuizPage extends StatefulWidget {
  final List<Word> words;
  final List<Word> allWords;

  const QuizPage({
    super.key,
    required this.words,
    required this.allWords,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _srsRecorded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(widget.words, widget.allWords);
    });
  }

  Future<void> _recordToSrs(QuizProvider quizProv) async {
    if (_srsRecorded) return;
    _srsRecorded = true;
    final srsProv = context.read<SrsProvider>();
    final vocabProv = context.read<VocabularyProvider>();
    for (final q in quizProv.questions) {
      if (q.isAnswered) {
        await srsProv.recordQuizResult(q.word.word, q.isCorrect);
      }
    }
    srsProv.refreshStats(vocabProv.allWords);
  }

  @override
  Widget build(BuildContext context) {
    final quizProv = context.watch<QuizProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final fontSize = settings.fontSize;
    final ttsEnabled = settings.ttsEnabled;

    if (quizProv.finished) {
      if (settings.srsEnabled) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _recordToSrs(quizProv));
      }
      return _buildResults(context, quizProv, settings, fontSize);
    }

    final question = quizProv.currentQuestion;
    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('测试')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('测试'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${quizProv.currentIndex + 1}/${quizProv.totalCount}',
              style: TextStyle(fontSize: fontSize * 0.85),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: ProgressBarWidget(
              current: quizProv.answeredCount,
              total: quizProv.totalCount,
              showLabel: false,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '请选择正确的中文释义',
                    style: TextStyle(
                      fontSize: fontSize * 0.85,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                question.word.word,
                                style: TextStyle(
                                  fontSize: fontSize * 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (ttsEnabled) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () => context
                                      .read<TTSProvider>()
                                      .speak(question.word.word),
                                  tooltip: '朗读',
                                ),
                              ],
                            ],
                          ),
                          if (question.word.pronunciation.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              question.word.pronunciation,
                              style: TextStyle(
                                fontSize: fontSize * 0.85,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.word.pos.isNotEmpty
                        ? '/${question.word.pos}/'
                        : '',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: question.options.map((option) {
                final isSelected = question.selectedAnswer == option;
                final isCorrectOption = option == question.correctAnswer;
                final showResult =
                    question.isAnswered && (isSelected || isCorrectOption);

                return OptionButton(
                  label: option,
                  isSelected: isSelected,
                  isCorrect: showResult
                      ? (isSelected ? question.isCorrect : true)
                      : null,
                  fontSize: fontSize,
                  onTap: question.isAnswered
                      ? null
                      : () => quizProv.selectAnswer(option),
                );
              }).toList(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: quizProv.isAnswered ? () => quizProv.next() : null,
                  child: Text(
                    quizProv.hasNext ? '下一题' : '查看结果',
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, QuizProvider prov,
      AppSettings settings, double fontSize) {
    final total = prov.totalCount;
    final correct = prov.correctCount;
    final accuracy =
        total > 0 ? (correct / total * 100).toStringAsFixed(0) : '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('测试结果'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$accuracy%',
                style: TextStyle(
                  fontSize: fontSize * 4,
                  fontWeight: FontWeight.bold,
                  color: accuracy == '100'
                      ? Colors.green
                      : accuracy.compareTo('80') >= 0
                          ? Colors.blue
                          : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '正确率',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('正确', correct.toString(), Colors.green, fontSize),
                  _buildStat('错误', prov.incorrectCount.toString(), Colors.red,
                      fontSize),
                  _buildStat('总题', total.toString(), Colors.blue, fontSize),
                ],
              ),
              if (settings.srsEnabled) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timeline,
                        size: fontSize * 0.9, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      '已按答题结果更新复习进度',
                      style: TextStyle(
                          fontSize: fontSize * 0.8, color: Colors.green),
                    ),
                  ],
                ),
              ],
              if (prov.incorrectWords.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '以下单词需要复习:',
                  style:
                      TextStyle(fontSize: fontSize * 0.85, color: Colors.red),
                ),
                const SizedBox(height: 8),
                ...prov.incorrectWords.map((w) => Text(
                      '${w.word} - ${w.meaning}',
                      style: TextStyle(fontSize: fontSize * 0.85),
                    )),
              ],
              if (prov.incorrectWords.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewPage(
                            words: prov.incorrectWords,
                            title: '复习错词',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay),
                    label: Text(
                      '复习错词 (${prov.incorrectWords.length})',
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    if (settings.srsEnabled) {
                      context.read<SrsProvider>().reset();
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    } else {
                      Navigator.of(context).pop();
                      context.read<LearningProvider>().reset();
                    }
                  },
                  icon: const Icon(Icons.home),
                  label: Text(
                    '返回首页',
                    style: TextStyle(fontSize: fontSize * 1.1),
                  ),
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
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: fontSize * 1.5,
              fontWeight: FontWeight.bold,
              color: color),
        ),
        Text(label, style: TextStyle(fontSize: fontSize * 0.85)),
      ],
    );
  }
}
