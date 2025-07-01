import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorite_provider.dart';
import 'favorite_item_card.dart';

/// お気に入りリストを表示するウィジェット
class FavoriteList extends ConsumerWidget {
  final String userId;
  final bool showEmptyMessage;

  const FavoriteList({
    Key? key,
    required this.userId,
    this.showEmptyMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsyncValue = ref.watch(userFavoritesByIdProvider(userId));
    
    return favoritesAsyncValue.when(
      data: (favorites) {
        if (favorites.isEmpty) {
          if (showEmptyMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'お気に入りがありません',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // 検索タブに移動する処理
                      // （必要に応じて実装）
                    },
                    child: const Text('コンテンツを探す'),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            return FavoriteItemCard(item: favorite);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userFavoritesByIdProvider(userId));
                },
                child: const Text('再読み込み'),
              ),
            ],
          ),
        );
      },
    );
  }
} 