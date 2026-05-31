import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/tts_provider.dart';
import 'services/storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VocabularyProvider()..autoLoad()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..load()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => TTSProvider()),
      ],
      child: const OboeruApp(),
    ),
  );
}
