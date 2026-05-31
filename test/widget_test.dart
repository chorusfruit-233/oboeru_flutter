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

Widget _wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => VocabularyProvider()),
      ChangeNotifierProvider(create: (_) => LearningProvider()),
      ChangeNotifierProvider(create: (_) => QuizProvider()),
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => AIProvider()),
      ChangeNotifierProvider(create: (_) => TTSProvider()),
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
}
