
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/content_consumption_model.dart';
import 'providers/content_provider.dart';
import '../auth/providers/user_provider.dart';

/// スターの日常データを表示するウィジェット
class ConsumptionDataWidget extends ConsumerWidget {
  final String userId;
  final bool showHeader;
  
  const ConsumptionDataWidget({
    super.key,
    required this.userId,
    this.showHeader = true,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider(userId));
    
    return userProfileAsync.when(
      data: (userProfile) {
        if (userProfile == null) {
          return const Center(child: Text('ユーザープロフィールが見つかりません'));
        }
        
        final displayName = userProfile.displayName ?? 'ユーザー';
        return _buildTabView(context, ref, displayName);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
    );
  }
  
  Widget _buildTabView(BuildContext context, WidgetRef ref, String displayName) {
    return DefaultTabController(
      length: ContentCategory.values.length,
      child: Column(
        children: [
          if (showHeader)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '$displayNameの消費履歴',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          TabBar(
            isScrollable: true,
            tabs: ContentCategory.values.map((category) {
              return Tab(
                text: _getCategoryLabel(category),
                icon: Icon(_getCategoryIcon(category)),
              );
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: ContentCategory.values.map((category) {
                return _buildCategoryContent(ref, category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryContent(WidgetRef ref, ContentCategory category) {
    final params = UserContentParams(
      userId: userId,
      category: category,
    );
    
    final contentsAsync = ref.watch(userContentConsumptionsProvider(params));
    
    return contentsAsync.when(
      data: (contents) {
        if (contents.isEmpty) {
          return Center(
            child: Text('${_getCategoryLabel(category)}の消費データがありません'),
          );
        }
        
        return ListView.builder(
          itemCount: contents.length,
          itemBuilder: (context, index) {
            final content = contents[index];
            return _buildContentItem(context, content);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
    );
  }
  
  Widget _buildContentItem(BuildContext context, ContentConsumption content) {
    switch (content.category) {
      case ContentCategory.youtube:
        return _buildYouTubeItem(context, content);
      case ContentCategory.book:
        return _buildBookItem(context, content);
      case ContentCategory.purchase:
        return _buildPurchaseItem(context, content);
      case ContentCategory.food:
        return _buildFoodItem(context, content);
      case ContentCategory.location:
        return _buildLocationItem(context, content);
      case ContentCategory.music:
        return _buildMusicItem(context, content);
      case ContentCategory.other:
      default:
        return _buildDefaultItem(context, content);
    }
  }
  
  Widget _buildYouTubeItem(BuildContext context, ContentConsumption content) {
    final videoId = content.contentData['video_id'] as String?;
    final thumbnailUrl = content.contentData['thumbnail_url'] as String?;
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thumbnailUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (content.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      content.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${content.viewCount}'),
                    const SizedBox(width: 16),
                    Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${content.likeCount}'),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(_formatDate(content.createdAt)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookItem(BuildContext context, ContentConsumption content) {
    return ListTile(
      title: Text(content.title),
      subtitle: content.description != null ? Text(content.description!) : null,
      leading: const Icon(Icons.book),
      trailing: Text(_formatDate(content.createdAt)),
    );
  }
  
  Widget _buildPurchaseItem(BuildContext context, ContentConsumption content) {
    return ListTile(
      title: Text(content.title),
      subtitle: content.price != null 
          ? Text('${content.price}円 - ${content.description ?? ""}')
          : (content.description != null ? Text(content.description!) : null),
      leading: const Icon(Icons.shopping_bag),
      trailing: Text(_formatDate(content.createdAt)),
    );
  }
  
  Widget _buildFoodItem(BuildContext context, ContentConsumption content) {
    return ListTile(
      title: Text(content.title),
      subtitle: content.description != null ? Text(content.description!) : null,
      leading: const Icon(Icons.restaurant),
      trailing: Text(_formatDate(content.createdAt)),
    );
  }
  
  Widget _buildLocationItem(BuildContext context, ContentConsumption content) {
    final location = content.location;
    String locationText = '';
    
    if (location != null) {
      locationText = location.placeName ?? location.address ?? '${location.latitude}, ${location.longitude}';
    }
    
    return ListTile(
      title: Text(content.title),
      subtitle: Text(locationText),
      leading: const Icon(Icons.location_on),
      trailing: Text(_formatDate(content.createdAt)),
    );
  }
  
  Widget _buildMusicItem(BuildContext context, ContentConsumption content) {
    return ListTile(
      title: Text(content.title),
      subtitle: content.description != null ? Text(content.description!) : null,
      leading: const Icon(Icons.music_note),
      trailing: Text(_formatDate(content.createdAt)),
    );
  }
  
  Widget _buildDefaultItem(BuildContext context, ContentConsumption content) {
    return ListTile(
      title: Text(content.title),
      subtitle: content.description != null ? Text(content.description!) : null,
      leading: const Icon(Icons.star),
      trailing: Text(_formatDate(content.createdAt)),
    );
  }
  
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
  }
  
  String _getCategoryLabel(ContentCategory category) {
    switch (category) {
      case ContentCategory.youtube:
        return 'YouTube';
      case ContentCategory.book:
        return '本';
      case ContentCategory.purchase:
        return '購入';
      case ContentCategory.food:
        return '食事';
      case ContentCategory.location:
        return '場所';
      case ContentCategory.music:
        return '音楽';
      case ContentCategory.other:
        return 'その他';
    }
  }
  
  IconData _getCategoryIcon(ContentCategory category) {
    switch (category) {
      case ContentCategory.youtube:
        return Icons.video_library;
      case ContentCategory.book:
        return Icons.book;
      case ContentCategory.purchase:
        return Icons.shopping_bag;
      case ContentCategory.food:
        return Icons.restaurant;
      case ContentCategory.location:
        return Icons.location_on;
      case ContentCategory.music:
        return Icons.music_note;
      case ContentCategory.other:
        return Icons.star;
    }
  }
}
