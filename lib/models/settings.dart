class AppSettings {
  final int dailyWords;
  final bool shuffle;
  final double fontSize;
  final bool showProgressBar;
  final String themeMode;
  final String? vocabFilePath;

  // AI (reserved)
  final bool aiEnabled;
  final String aiProvider;
  final String aiApiKey;
  final String aiDifficulty;
  final String aiCustomUrl;
  final String aiCustomModel;

  // TTS (reserved)
  final bool ttsEnabled;
  final String ttsProvider;
  final bool ttsAutoSpeak;

  const AppSettings({
    this.dailyWords = 20,
    this.shuffle = true,
    this.fontSize = 16.0,
    this.showProgressBar = true,
    this.themeMode = 'light',
    this.vocabFilePath,
    this.aiEnabled = false,
    this.aiProvider = '',
    this.aiApiKey = '',
    this.aiDifficulty = 'junior',
    this.aiCustomUrl = '',
    this.aiCustomModel = '',
    this.aiAutoGenerate = false,
    this.aiPrefer = false,
    this.aiPreGenerate = false,
    this.aiMaxTokens = 300,
    this.aiReasoningEffort = 'disabled',
    this.ttsEnabled = false,
    this.ttsProvider = '',
    this.ttsAutoSpeak = false,
  });

  final bool aiAutoGenerate;
  final bool aiPrefer;
  final bool aiPreGenerate;
  final int aiMaxTokens;
  final String aiReasoningEffort;

  AppSettings copyWith({
    int? dailyWords,
    bool? shuffle,
    double? fontSize,
    bool? showProgressBar,
    String? themeMode,
    String? vocabFilePath,
    bool? aiEnabled,
    String? aiProvider,
    String? aiApiKey,
    String? aiDifficulty,
    String? aiCustomUrl,
    String? aiCustomModel,
    bool? aiAutoGenerate,
    bool? aiPrefer,
    bool? aiPreGenerate,
    int? aiMaxTokens,
    String? aiReasoningEffort,
    bool? ttsEnabled,
    String? ttsProvider,
    bool? ttsAutoSpeak,
  }) {
    return AppSettings(
      dailyWords: dailyWords ?? this.dailyWords,
      shuffle: shuffle ?? this.shuffle,
      fontSize: fontSize ?? this.fontSize,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      themeMode: themeMode ?? this.themeMode,
      vocabFilePath: vocabFilePath ?? this.vocabFilePath,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiProvider: aiProvider ?? this.aiProvider,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      aiCustomUrl: aiCustomUrl ?? this.aiCustomUrl,
      aiCustomModel: aiCustomModel ?? this.aiCustomModel,
      aiAutoGenerate: aiAutoGenerate ?? this.aiAutoGenerate,
      aiPrefer: aiPrefer ?? this.aiPrefer,
      aiPreGenerate: aiPreGenerate ?? this.aiPreGenerate,
      aiMaxTokens: aiMaxTokens ?? this.aiMaxTokens,
      aiReasoningEffort: aiReasoningEffort ?? this.aiReasoningEffort,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      ttsProvider: ttsProvider ?? this.ttsProvider,
      ttsAutoSpeak: ttsAutoSpeak ?? this.ttsAutoSpeak,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyWords': dailyWords,
    'shuffle': shuffle,
    'fontSize': fontSize,
    'showProgressBar': showProgressBar,
    'themeMode': themeMode,
    'vocabFilePath': vocabFilePath,
    'aiEnabled': aiEnabled,
    'aiProvider': aiProvider,
    'aiApiKey': aiApiKey,
    'aiDifficulty': aiDifficulty,
    'aiCustomUrl': aiCustomUrl,
    'aiCustomModel': aiCustomModel,
    'aiAutoGenerate': aiAutoGenerate,
    'aiPrefer': aiPrefer,
    'aiPreGenerate': aiPreGenerate,
    'aiMaxTokens': aiMaxTokens,
    'aiReasoningEffort': aiReasoningEffort,
    'ttsEnabled': ttsEnabled,
    'ttsProvider': ttsProvider,
    'ttsAutoSpeak': ttsAutoSpeak,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    dailyWords: (json['dailyWords'] as num?)?.toInt() ?? 20,
    shuffle: (json['shuffle'] as bool?) ?? true,
    fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
    showProgressBar: (json['showProgressBar'] as bool?) ?? true,
    themeMode: (json['themeMode'] as String?) ?? 'light',
    vocabFilePath: json['vocabFilePath'] as String?,
    aiEnabled: (json['aiEnabled'] as bool?) ?? false,
    aiProvider: (json['aiProvider'] as String?) ?? '',
    aiApiKey: (json['aiApiKey'] as String?) ?? '',
    aiDifficulty: (json['aiDifficulty'] as String?) ?? 'junior',
    aiCustomUrl: (json['aiCustomUrl'] as String?) ?? '',
    aiCustomModel: (json['aiCustomModel'] as String?) ?? '',
    aiAutoGenerate: (json['aiAutoGenerate'] as bool?) ?? false,
    aiPrefer: (json['aiPrefer'] as bool?) ?? false,
    aiPreGenerate: (json['aiPreGenerate'] as bool?) ?? false,
    aiMaxTokens: (json['aiMaxTokens'] as num?)?.toInt() ?? 300,
    aiReasoningEffort: (json['aiReasoningEffort'] as String?) ?? 'disabled',
    ttsEnabled: (json['ttsEnabled'] as bool?) ?? false,
    ttsProvider: (json['ttsProvider'] as String?) ?? '',
    ttsAutoSpeak: (json['ttsAutoSpeak'] as bool?) ?? false,
  );
}
