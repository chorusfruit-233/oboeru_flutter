import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'pages/app_shell.dart';

class OboeruApp extends StatelessWidget {
  const OboeruApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;

    return MaterialApp(
      title: 'Oboeru',
      debugShowCheckedModeBanner: false,
      theme: settings.themeMode == 'dark' ? _darkTheme(settings) : _lightTheme(settings),
      home: const AppShell(),
    );
  }

  ThemeData _lightTheme(dynamic settings) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: Brightness.light,
    );
  }

  ThemeData _darkTheme(dynamic settings) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: Brightness.dark,
    );
  }
}
