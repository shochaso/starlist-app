import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/data_integration/models/youtube_video.dart';
import '../features/data_integration/repositories/youtube_repository.dart';

/// YouTubeデータを提供するプロバイダー
final youtubeRepositoryProvider = Provider<YouTubeRepository>((ref) {
  throw UnimplementedError('YouTubeRepositoryを初期化する必要があります');
});

/// 検索クエリの状態を管理するプロバイダー
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 検索結果を提供するプロバイダー
final searchResultsProvider = FutureProvider<List<YouTubeVideo>>((ref) async {
  final repository = ref.watch(youtubeRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  
  if (query.isEmpty) {
    return [];
  }
  
  return await repository.searchVideos(query);
});

/// チャンネル動画を提供するプロバイダー
final channelVideosProvider = FutureProvider.family<List<YouTubeVideo>, String>((ref, channelId) async {
  final repository = ref.watch(youtubeRepositoryProvider);
  return await repository.getChannelVideos(channelId);
});

/// YouTube検索画面
class YouTubeSearchScreen extends ConsumerStatefulWidget {
  const YouTubeSearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<YouTubeSearchScreen> createState() => _YouTubeSearchScreenState();
}

class _YouTubeSearchScreenState extends ConsumerState<YouTubeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

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
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          
          // 検索結果
          Expanded(
            child: searchResults.when(
              data: (videos) {
                if (videos.isEmpty && ref.watch(searchQueryProvider).isNotEmpty) {
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
                          video.thumbnailUrl,
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
