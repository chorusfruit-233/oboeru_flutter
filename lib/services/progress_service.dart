import '../models/user_progress.dart';
import 'storage_service.dart';

class ProgressService {
  final StorageService _storage = StorageService.instance;

  Future<UserProgress?> loadToday() async {
    final data = await _storage.readJson(_storage.progressPath);
    if (data == null) return null;
    final progress = UserProgress.fromJson(data as Map<String, dynamic>);
    final today = DateTime.now();
    if (progress.date.year == today.year &&
        progress.date.month == today.month &&
        progress.date.day == today.day) {
      return progress;
    }
    return null;
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _storage.writeJson(_storage.progressPath, progress.toJson());
  }

  Future<void> addRecord(TestRecord record) async {
    final progress = await loadToday() ?? UserProgress(date: DateTime.now());
    final updated = progress.copyWith(
      wordsLearned: progress.wordsLearned + 1,
      records: [...progress.records, record],
    );
    await saveProgress(updated);
  }
}
