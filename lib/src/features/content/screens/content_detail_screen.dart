import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/content_bloc.dart';
import '../models/content_model.dart';
import '../../../core/components/loading/loading_indicator.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({
    super.key,
    required this.contentId,
  });

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadContentDetail();
  }

  void _loadContentDetail() {
    context.read<ContentBloc>().add(FetchContentDetailEvent(widget.contentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コンテンツ詳細'),
        actions: [
          BlocBuilder<ContentBloc, ContentState>(
            builder: (context, state) {
              if (state is ContentDetailLoaded) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareContent(state.content),
                    ),
                    if (state.content.authorId == 'current_user_id') // TODO: 現在のユーザーIDを使用する
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editContent(state.content),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ContentBloc, ContentState>(
        listener: (context, state) {
          if (state is ContentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ContentDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('コンテンツが削除されました')),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is ContentLoading) {
            return const Center(child: LoadingIndicator(size: 32.0));
          } else if (state is ContentDetailLoaded) {
            return _buildContentDetail(context, state.content);
          } else if (state is ContentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadContentDetail,
                    child: const Text('再読み込み'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: LoadingIndicator(size: 32.0));
        },
      ),
    );
  }

  Widget _buildContentDetail(BuildContext context, ContentModel content) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    IconData typeIcon;
    Color typeColor;
    
    switch (content.type) {
      case ContentTypeModel.video:
        typeIcon = Icons.movie;
        typeColor = Colors.red;
        break;
      case ContentTypeModel.image:
        typeIcon = Icons.image;
        typeColor = Colors.green;
        break;
      case ContentTypeModel.text:
        typeIcon = Icons.article;
        typeColor = Colors.blue;
        break;
      case ContentTypeModel.link:
        typeIcon = Icons.link;
        typeColor = Colors.purple;
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分
          Row(
            children: [
              CircleAvatar(
                backgroundColor: typeColor.withOpacity(0.2),
                radius: 24,
                child: Icon(typeIcon, color: typeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          content.authorName,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(content.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // コンテンツ本体
          if (content.type == ContentTypeModel.video && content.url.isNotEmpty)
            _buildVideoPreview(size),
          
          if (content.type == ContentTypeModel.image && content.url.isNotEmpty)
            _buildImagePreview(content.url),
          
          if (content.type == ContentTypeModel.link && content.url.isNotEmpty)
            _buildLinkPreview(content.url),
          
          const SizedBox(height: 16),
          
          // 説明文
          if (content.description.isNotEmpty) ...[
            Text(
              '説明',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              content.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
          
          // メタデータ
          if (content.metadata.isNotEmpty) ...[
            Text(
              'メタデータ',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...content.metadata.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          
          // インタラクションバー
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInteractionButton(
                  icon: Icons.favorite_border,
                  label: content.likes.toString(),
                  onTap: () => _likeContent(content),
                ),
                _buildInteractionButton(
                  icon: Icons.comment_outlined,
                  label: content.comments.toString(),
                  onTap: () => _commentContent(content),
                ),
                _buildInteractionButton(
                  icon: Icons.share_outlined,
                  label: content.shares.toString(),
                  onTap: () => _shareContent(content),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 削除ボタン (コンテンツ作成者のみ表示)
          if (content.authorId == 'current_user_id') // TODO: 現在のユーザーIDを使用する
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('コンテンツを削除'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => _confirmDeleteContent(content),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(Size size) {
    // TODO: YouTube Player Widgetなどを使って実装
    return Container(
      width: size.width,
      height: 200,
      color: Colors.black,
      child: const Center(
        child: Icon(
          Icons.play_circle_fill,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImagePreview(String url) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 64,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinkPreview(String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.link, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                url,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.open_in_new),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URLを開けませんでした: $url')),
        );
      }
    }
  }

  void _likeContent(ContentModel content) {
    // TODO: いいね機能の実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('いいねしました')),
    );
  }

  void _commentContent(ContentModel content) {
    // TODO: コメント機能の実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('コメント機能は準備中です')),
    );
  }

  void _shareContent(ContentModel content) {
    Share.share(
      'Check out this content: ${content.title}\n\n${content.url}',
      subject: content.title,
    );
  }

  void _editContent(ContentModel content) {
    context.push('/contents/edit/${content.id}');
  }

  void _confirmDeleteContent(ContentModel content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('コンテンツを削除'),
          content: const Text('このコンテンツを削除しますか？\nこの操作は元に戻せません。'),
          actions: [
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ContentBloc>().add(DeleteContentEvent(content.id));
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
} 