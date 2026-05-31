class Word {
  final String word;
  final String pos;
  final String meaning;
  final List<String> wrongOptions;
  final String pronunciation;
  final String example;
  final String exampleMeaning;
  final String tag;
  final int difficulty;

  const Word({
    required this.word,
    required this.pos,
    required this.meaning,
    this.wrongOptions = const [],
    this.pronunciation = '',
    this.example = '',
    this.exampleMeaning = '',
    this.tag = '',
    this.difficulty = 1,
  });

  factory Word.fromLine(String line) {
    final parts = line.split('\t');
    final word = parts[0].trim();
    final pos = parts.length > 1 ? parts[1].trim() : '';
    final meaning = parts.length > 2 ? parts[2].trim() : '';
    final List<String> wrongOptions = parts.length > 3
        ? parts[3].split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : [];
    return Word(word: word, pos: pos, meaning: meaning, wrongOptions: wrongOptions);
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'pos': pos,
    'meaning': meaning,
    'wrongOptions': wrongOptions,
    'pronunciation': pronunciation,
    'example': example,
    'exampleMeaning': exampleMeaning,
    'tag': tag,
    'difficulty': difficulty,
  };

  factory Word.fromJson(Map<String, dynamic> json) => Word(
    word: json['word'] as String,
    pos: (json['pos'] as String?) ?? '',
    meaning: (json['meaning'] as String?) ?? '',
    wrongOptions: ((json['wrongOptions'] as List<dynamic>?) ?? []).cast<String>(),
    pronunciation: (json['pronunciation'] as String?) ?? '',
    example: (json['example'] as String?) ?? '',
    exampleMeaning: (json['exampleMeaning'] as String?) ?? '',
    tag: (json['tag'] as String?) ?? '',
    difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Word && word == other.word;

  @override
  int get hashCode => word.hashCode;
}
