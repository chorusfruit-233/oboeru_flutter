import 'dart:math';
import '../models/word.dart';
import '../models/srs_card.dart';
import 'srs_algorithm.dart';
import 'storage_service.dart';

class SrsStats {
  final int due;
  final int fresh;
  final int learned;
  final int total;

  const SrsStats({
    this.due = 0,
    this.fresh = 0,
    this.learned = 0,
    this.total = 0,
  });

  int get reviewQueue => due;
}

class SrsService {
  final StorageService _storage = StorageService.instance;
  final Map<String, SrsCard> _cards = {};

  Map<String, SrsCard> get cards => _cards;

  Future<void> load() async {
    final data = await _storage.readJson(_storage.srsPath);
    _cards.clear();
    if (data == null) return;
    final list = data as List<dynamic>;
    for (final e in list) {
      final card = SrsCard.fromJson(e as Map<String, dynamic>);
      _cards[card.word] = card;
    }
  }

  Future<void> save() async {
    await _storage.writeJson(
      _storage.srsPath,
      _cards.values.map((c) => c.toJson()).toList(),
    );
  }

  SrsCard? getCard(String word) => _cards[word];

  List<SrsCard> getDueCards({int limit = 0, DateTime? now}) {
    final t = now ?? DateTime.now();
    final due = _cards.values
        .where((c) => !c.isNew && c.isDueAt(t))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (limit > 0 && due.length > limit) return due.sublist(0, limit);
    return due;
  }

  List<String> getNewWordKeys(List<Word> allWords, int limit) {
    final fresh = allWords.where((w) => !_cards.containsKey(w.word)).toList();
    fresh.shuffle(Random());
    return fresh.take(limit).map((w) => w.word).toList();
  }

  Future<SrsCard> recordReview(String word, Quality quality, {DateTime? now}) async {
    final existing = _cards[word];
    final card = existing ?? SrsAlgorithm.newCard(word, now: now);
    final updated = SrsAlgorithm.apply(card, quality, now: now);
    _cards[word] = updated;
    await save();
    return updated;
  }

  SrsStats getStats(List<Word> allWords, {DateTime? now}) {
    final t = now ?? DateTime.now();
    int due = 0;
    int learned = 0;
    for (final c in _cards.values) {
      if (!c.isNew) {
        if (c.isDueAt(t)) due++;
        if (c.repetition > 0) learned++;
      }
    }
    final fresh = allWords.where((w) => !_cards.containsKey(w.word)).length;
    return SrsStats(
      due: due,
      fresh: fresh,
      learned: learned,
      total: _cards.length,
    );
  }
}
