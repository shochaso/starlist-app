import 'package:flutter/material.dart';

/// データのリストを表示する汎用的なリストビューコンポーネント
/// 
/// ジェネリック型 `T` はリストで表示するデータの型です。
/// リストアイテムの表示にはビルダーパターンを使用します。
class ItemListView<T> extends StatelessWidget {
  /// 表示するデータのリスト
  final List<T> items;
  
  /// 各アイテムのウィジェットをビルドするコールバック
  final Widget Function(BuildContext, T, int) itemBuilder;
  
  /// データが空の場合に表示するウィジェット
  final Widget? emptyWidget;
  
  /// ロード中に表示するウィジェット
  final Widget? loadingWidget;
  
  /// エラー発生時に表示するウィジェット
  final Widget? errorWidget;
  
  /// リストビューのスクロール方向
  final Axis scrollDirection;
  
  /// リストがロード中かどうか
  final bool isLoading;
  
  /// エラーが発生したかどうか
  final bool hasError;
  
  /// エラーメッセージ
  final String? errorMessage;
  
  /// リストビューの内部余白
  final EdgeInsetsGeometry padding;
  
  /// リストアイテム間のスペース
  final double itemSpacing;
  
  /// リストビューをリフレッシュするためのコールバック
  final Future<void> Function()? onRefresh;
  
  /// スクロールコントローラー
  final ScrollController? controller;
  
  /// リストの末尾に到達したときのコールバック
  final Function()? onEndReached;
  
  /// 末尾到達判定の閾値
  final double endReachedThreshold;

  const ItemListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.scrollDirection = Axis.vertical,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.padding = const EdgeInsets.all(8.0),
    this.itemSpacing = 8.0,
    this.onRefresh,
    this.controller,
    this.onEndReached,
    this.endReachedThreshold = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    // エラーがある場合はエラーウィジェットを表示
    if (hasError) {
      return _buildErrorView(context);
    }
    
    // データ取得中の場合はローディングウィジェットを表示
    if (isLoading && items.isEmpty) {
      return _buildLoadingView();
    }
    
    // データが空の場合は空の状態ウィジェットを表示
    if (items.isEmpty) {
      return _buildEmptyView();
    }
    
    // リストを表示
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: _buildListView(),
      );
    }
    
    return _buildListView();
  }

  /// リストビューを構築
  Widget _buildListView() {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView.builder(
        controller: controller,
        scrollDirection: scrollDirection,
        padding: padding,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == items.length - 1 ? 0 : itemSpacing,
            ),
            child: itemBuilder(context, item, index),
          );
        },
      ),
    );
  }

  /// ロード中のビューを構築
  Widget _buildLoadingView() {
    return loadingWidget ?? 
      const Center(
        child: CircularProgressIndicator(),
      );
  }

  /// エラービューを構築
  Widget _buildErrorView(BuildContext context) {
    return errorWidget ?? 
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'データの読み込み中にエラーが発生しました',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRefresh != null)
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('再読み込み'),
              ),
          ],
        ),
      );
  }

  /// 空のビューを構築
  Widget _buildEmptyView() {
    return emptyWidget ?? 
      const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              color: Colors.grey,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              'データがありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
  }

  /// スクロール通知を処理
  bool _handleScrollNotification(ScrollNotification notification) {
    if (onEndReached != null &&
        notification is ScrollUpdateNotification &&
        notification.metrics.pixels + endReachedThreshold >= notification.metrics.maxScrollExtent) {
      onEndReached!();
    }
    return false;
  }
}

/// リストビューヘッダー付きのセクション
class ItemListSection<T> extends StatelessWidget {
  /// セクションのタイトル
  final String title;
  
  /// セクションのサブタイトル（オプション）
  final String? subtitle;
  
  /// 表示するアイテムのリスト
  final List<T> items;
  
  /// 各アイテムのウィジェットをビルドするコールバック
  final Widget Function(BuildContext, T, int) itemBuilder;
  
  /// すべて表示ボタンを押したときのコールバック
  final VoidCallback? onViewAll;
  
  /// セクションの余白
  final EdgeInsetsGeometry padding;
  
  /// アイテム間のスペース
  final double itemSpacing;
  
  /// 水平スクロールかどうか
  final bool isHorizontal;
  
  /// データロード中かどうか
  final bool isLoading;
  
  /// 最大表示数（水平スクロールの場合は無視）
  final int? maxItems;

  const ItemListSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    required this.itemBuilder,
    this.onViewAll,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
    this.itemSpacing = 12.0,
    this.isHorizontal = false,
    this.isLoading = false,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayItems = maxItems != null && !isHorizontal
        ? items.take(maxItems!).toList()
        : items;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('すべて表示'),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 12.0),
          
          // アイテムリスト
          if (isLoading) ...[
            const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (isHorizontal) ...[
            // 水平スクロールリスト
            SizedBox(
              height: 180.0, // 適切な高さに調整
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == items.length - 1 ? 0 : itemSpacing,
                    ),
                    child: SizedBox(
                      width: 150.0, // 適切な幅に調整
                      child: itemBuilder(context, items[index], index),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            // 垂直リスト
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == displayItems.length - 1 ? 0 : itemSpacing,
                  ),
                  child: itemBuilder(context, displayItems[index], index),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
} 