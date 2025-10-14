import 'package:flutter/material.dart';

/// 仮想スクロールウィジェット
class VirtualizedContentFeed extends StatefulWidget {
  /// コンテンツリスト
  final List<dynamic> contents;
  
  /// 追加データ読み込み関数
  final Future<void> Function() onLoadMore;
  
  /// アイテムビルダー
  final Widget Function(BuildContext, dynamic, int) itemBuilder;
  
  /// 読み込み中かどうか
  final bool isLoading;
  
  /// さらにコンテンツがあるかどうか
  final bool hasMore;
  
  /// コンストラクタ
  const VirtualizedContentFeed({
    super.key,
    required this.contents,
    required this.onLoadMore,
    required this.itemBuilder,
    required this.isLoading,
    required this.hasMore,
  });
  
  @override
  _VirtualizedContentFeedState createState() => _VirtualizedContentFeedState();
}

class _VirtualizedContentFeedState extends State<VirtualizedContentFeed> {
  /// スクロールコントローラー
  final ScrollController _scrollController = ScrollController();
  
  /// 読み込み中かどうか
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  /// スクロールリスナー
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      _loadMoreItems();
    }
  }
  
  /// 追加データを読み込む
  Future<void> _loadMoreItems() async {
    if (!_isLoadingMore && !widget.isLoading && widget.hasMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      await widget.onLoadMore();
      
      setState(() {
        _isLoadingMore = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.contents.length + (widget.isLoading || widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.contents.length) {
          return widget.itemBuilder(context, widget.contents[index], index);
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
