import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/content_bloc.dart';
import '../models/content_model.dart';
import '../../../core/components/loading/loading_indicator.dart';

class ContentListScreen extends StatefulWidget {
  final String? authorId;
  final ContentTypeModel? contentType;
  final String title;

  const ContentListScreen({
    super.key,
    this.authorId,
    this.contentType,
    this.title = 'コンテンツ一覧',
  });

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  final _scrollController = ScrollController();
  final List<ContentModel> _contents = [];
  bool _hasMore = true;
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadContents();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadContents() {
    if (!_isLoading && _hasMore) {
      context.read<ContentBloc>().add(FetchContentsEvent(
            authorId: widget.authorId,
            type: widget.contentType,
            limit: _pageSize,
            offset: _currentPage * _pageSize,
          ));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadContents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: BlocConsumer<ContentBloc, ContentState>(
        listener: (context, state) {
          if (state is ContentsLoaded) {
            setState(() {
              if (_currentPage == 0) {
                _contents.clear();
              }
              _contents.addAll(state.contents);
              _hasMore = state.hasMore;
              _currentPage++;
              _isLoading = false;
            });
          } else if (state is ContentLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ContentError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (_contents.isEmpty) {
            if (state is ContentLoading) {
              return const Center(child: LoadingIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.content_paste_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('コンテンツがありません'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadContents(),
                    child: const Text('再読み込み'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _currentPage = 0;
              });
              _loadContents();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _contents.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _contents.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: LoadingIndicator()),
                  );
                }

                final content = _contents[index];
                return ContentListItem(
                  content: content,
                  onTap: () {
                    context.push('/contents/${content.id}');
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/contents/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('動画'),
              onTap: () {
                Navigator.pop(context);
                _filterByType(ContentTypeModel.video);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('画像'),
              onTap: () {
                Navigator.pop(context);
                _filterByType(ContentTypeModel.image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('テキスト'),
              onTap: () {
                Navigator.pop(context);
                _filterByType(ContentTypeModel.text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('リンク'),
              onTap: () {
                Navigator.pop(context);
                _filterByType(ContentTypeModel.link);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('フィルタをクリア'),
              onTap: () {
                Navigator.pop(context);
                _clearFilter();
              },
            ),
          ],
        );
      },
    );
  }

  void _filterByType(ContentTypeModel type) {
    setState(() {
      _currentPage = 0;
      _contents.clear();
    });
    
    if (mounted) {
      context.read<ContentBloc>().add(FetchContentsEvent(
            authorId: widget.authorId,
            type: type,
            limit: _pageSize,
            offset: 0,
          ));
    }
  }

  void _clearFilter() {
    setState(() {
      _currentPage = 0;
      _contents.clear();
    });
    
    if (mounted) {
      context.read<ContentBloc>().add(FetchContentsEvent(
            authorId: widget.authorId,
            type: null,
            limit: _pageSize,
            offset: 0,
          ));
    }
  }
}

class ContentListItem extends StatelessWidget {
  final ContentModel content;
  final VoidCallback onTap;

  const ContentListItem({
    super.key,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: typeColor.withOpacity(0.2),
                    child: Icon(typeIcon, color: typeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content.authorName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (content.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  content.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(content.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(content.likes.toString()),
                      const SizedBox(width: 12),
                      Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(content.comments.toString()),
                      const SizedBox(width: 12),
                      Icon(Icons.share, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(content.shares.toString()),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return '今';
    }
  }
} 