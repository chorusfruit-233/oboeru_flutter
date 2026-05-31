import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavoritesProvider>();
    final fontSize = context.watch<SettingsProvider>().settings.fontSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏'),
        centerTitle: true,
        actions: [
          PopupMenuButton<FavoriteSortMode>(
            icon: const Icon(Icons.sort),
            onSelected: favProv.setSortMode,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: FavoriteSortMode.timeAdded,
                child: Text(
                  '按收藏时间',
                  style: TextStyle(
                    fontWeight: favProv.sortMode == FavoriteSortMode.timeAdded
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              PopupMenuItem(
                value: FavoriteSortMode.alphabetical,
                child: Text(
                  '按字母顺序',
                  style: TextStyle(
                    fontWeight: favProv.sortMode == FavoriteSortMode.alphabetical
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: favProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favProv.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无收藏单词',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '在学习中添加收藏',
                        style: TextStyle(
                          fontSize: fontSize * 0.85,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: favProv.favorites.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final word = favProv.favorites[index];
                    return Dismissible(
                      key: ValueKey(word.word),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.shade100,
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      onDismissed: (_) => favProv.remove(word),
                      child: ListTile(
                        title: Text(
                          word.word,
                          style: TextStyle(
                            fontSize: fontSize * 1.1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${word.pos.isNotEmpty ? '/${word.pos}/ ' : ''}${word.meaning}',
                          style: TextStyle(fontSize: fontSize * 0.85),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.star, color: Colors.amber),
                          onPressed: () => favProv.remove(word),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
