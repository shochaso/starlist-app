import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/services/image_url_builder.dart';

import 'youtube_provider.dart';

/// YouTube検索画面
class YouTubeSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const YouTubeSearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<YouTubeSearchScreen> createState() => _YouTubeSearchScreenState();
}

class _YouTubeSearchScreenState extends ConsumerState<YouTubeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // 初期検索キーワードがある場合は設定する
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      
      // 少し遅延させて検索を実行（ビルド完了後）
      Future.microtask(() {
        ref.read(youtubeSearchQueryProvider.notifier).state = widget.initialQuery!;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(youtubeSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube検索'),
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'YouTubeを検索...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(youtubeSearchQueryProvider.notifier).state = '';
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (value) {
                ref.read(youtubeSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          
          // 検索結果
          Expanded(
            child: searchResults.when(
              data: (videos) {
                if (videos.isEmpty && ref.watch(youtubeSearchQueryProvider).isNotEmpty) {
                  return const Center(
                    child: Text('検索結果が見つかりませんでした'),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        leading: Image.network(
                          ImageUrlBuilder.thumbnail(
                            video.thumbnailUrl,
                            width: 320,
                          ),
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                        title: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          // 動画詳細画面に遷移するなどの処理
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('選択された動画: ${video.title}')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('エラーが発生しました: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
