import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:starlist/src/features/feed/widgets/virtualized_content_feed.dart';

// モックの生成
@GenerateMocks([ScrollController])
void main() {
  group('VirtualizedContentFeed Tests', () {
    testWidgets('コンテンツが正しく表示されること', (WidgetTester tester) async {
      // テストデータ
      final testContents = List.generate(
        10,
        (index) => {'id': 'item$index', 'title': 'Item $index'},
      );
      
      bool loadMoreCalled = false;
      
      // ウィジェットのビルド
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedContentFeed(
              contents: testContents,
              onLoadMore: () async {
                loadMoreCalled = true;
              },
              itemBuilder: (context, item, index) {
                return ListTile(
                  key: Key('item_$index'),
                  title: Text(item['title']),
                );
              },
              isLoading: false,
              hasMore: true,
            ),
          ),
        ),
      );
      
      // 全てのアイテムが表示されていることを確認
      for (int i = 0; i < testContents.length; i++) {
        expect(find.text('Item $i'), findsOneWidget);
      }
      
      // ローディングインジケーターが表示されていることを確認
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // スクロールして追加読み込みをトリガー
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pump();
      
      // onLoadMoreが呼ばれたことを確認
      expect(loadMoreCalled, isTrue);
    });
    
    testWidgets('コンテンツがない場合は空のリストが表示されること', (WidgetTester tester) async {
      // ウィジェットのビルド
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedContentFeed(
              contents: const [],
              onLoadMore: () async {},
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item['title']),
                );
              },
              isLoading: false,
              hasMore: false,
            ),
          ),
        ),
      );
      
      // リストが空であることを確認
      expect(find.byType(ListTile), findsNothing);
      
      // ローディングインジケーターが表示されていないことを確認
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    
    testWidgets('読み込み中の場合はローディングインジケーターが表示されること', (WidgetTester tester) async {
      // ウィジェットのビルド
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedContentFeed(
              contents: const [],
              onLoadMore: () async {},
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item['title']),
                );
              },
              isLoading: true,
              hasMore: false,
            ),
          ),
        ),
      );
      
      // ローディングインジケーターが表示されていることを確認
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
