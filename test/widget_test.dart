import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:oboeru_flutter/app.dart';
import 'package:oboeru_flutter/providers/vocabulary_provider.dart';
import 'package:oboeru_flutter/providers/learning_provider.dart';
import 'package:oboeru_flutter/providers/quiz_provider.dart';
import 'package:oboeru_flutter/providers/favorites_provider.dart';
import 'package:oboeru_flutter/providers/settings_provider.dart';
import 'package:oboeru_flutter/providers/ai_provider.dart';
import 'package:oboeru_flutter/providers/tts_provider.dart';
import 'package:oboeru_flutter/providers/srs_provider.dart';
import 'package:oboeru_flutter/models/settings.dart';
import 'package:oboeru_flutter/models/word.dart';
import 'package:oboeru_flutter/pages/quiz_page.dart';

class _TestSettingsProvider extends SettingsProvider {
  _TestSettingsProvider(this._settings);

  final AppSettings _settings;

  @override
  AppSettings get settings => _settings;
}

Widget _wrapWithProviders(
  Widget child, {
  SettingsProvider? settingsProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => VocabularyProvider()),
      ChangeNotifierProvider(create: (_) => LearningProvider()),
      ChangeNotifierProvider(create: (_) => QuizProvider()),
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ChangeNotifierProvider(
        create: (_) => settingsProvider ?? SettingsProvider(),
      ),
      ChangeNotifierProvider(create: (_) => AIProvider()),
      ChangeNotifierProvider(create: (_) => TTSProvider()),
      ChangeNotifierProvider(create: (_) => SrsProvider()),
    ],
    child: child,
  );
}

void main() {
  testWidgets('App loads without error', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithProviders(const OboeruApp()));
    await tester.pump();
    expect(find.text('Oboeru'), findsWidgets);
  });

  testWidgets(
      'Quiz results hide review button when there are no incorrect words',
      (WidgetTester tester) async {
    final words = [
      Word(word: 'apple', pos: 'n', meaning: '苹果'),
    ];
    final settingsProvider = _TestSettingsProvider(
      const AppSettings(srsEnabled: false),
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        MaterialApp(home: QuizPage(words: words, allWords: words)),
        settingsProvider: settingsProvider,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('苹果'));
    await tester.pump();
    await tester.tap(find.text('查看结果'));
    await tester.pump();

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('复习错词 (0)'), findsNothing);
  });

  testWidgets('Quiz results show review button when there are incorrect words',
      (WidgetTester tester) async {
    final words = [
      Word(word: 'apple', pos: 'n', meaning: '苹果'),
      Word(word: 'book', pos: 'n', meaning: '书'),
    ];
    final settingsProvider = _TestSettingsProvider(
      const AppSettings(srsEnabled: false),
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        MaterialApp(home: QuizPage(words: [words.first], allWords: words)),
        settingsProvider: settingsProvider,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('书'));
    await tester.pump();
    await tester.tap(find.text('查看结果'));
    await tester.pump();

    expect(find.text('0%'), findsOneWidget);
    expect(find.text('复习错词 (1)'), findsOneWidget);
  });
}
