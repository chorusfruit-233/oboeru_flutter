import '../models/word.dart';
import 'storage_service.dart';

class FavoritesService {
  final StorageService _storage = StorageService.instance;

  Future<List<Word>> loadFavorites() async {
    final data = await _storage.readJson(_storage.favoritesPath);
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((e) => Word.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<Word> favorites) async {
    await _storage.writeJson(
      _storage.favoritesPath,
      favorites.map((w) => w.toJson()).toList(),
    );
  }
}
