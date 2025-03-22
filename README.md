# Starlist Improved

Starlistアプリの改善版ランキング機能を実装したパッケージです。

## 概要

このパッケージは、Starlistアプリのランキング機能を改善し、運用コストを削減するための実装を提供します。特に以下の3つのコスト圧迫ポイントに対する改善を含んでいます：

1. トレンドコンテンツ機能
2. 全プラットフォームからのコンテンツ消費データ統合
3. 人気スター検索・フィルタリング機能

## 主な改善点

### キャッシュ戦略の実装

- インメモリキャッシュによるデータの再利用
- キャッシュの有効期限管理
- 差分同期によるデータ転送量の削減

### 効率的なデータ取得

- ページネーションの最適化
- 必要最小限のデータのみを取得
- バッチ処理による負荷分散

### スケーラブルなアーキテクチャ

- クリーンアーキテクチャに基づいた設計
- 責務の明確な分離
- テスト可能なコード構造

## 使用方法

### インストール

`pubspec.yaml`に依存関係を追加します：

```yaml
dependencies:
  starlist_improved: ^1.0.0
```

### 基本的な使用例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_improved/src/features/ranking/presentation/viewmodels/ranking_view_model.dart';
import 'package:starlist_improved/src/features/ranking/models/ranking_model.dart';

class RankingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingState = ref.watch(rankingViewModelProvider);
    final rankingViewModel = ref.read(rankingViewModelProvider.notifier);
    
    // 初回読み込み
    useEffect(() {
      rankingViewModel.loadTrendingContent();
      return null;
    }, const []);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('トレンドランキング'),
      ),
      body: rankingState.isLoadingTrending
          ? Center(child: CircularProgressIndicator())
          : rankingState.trendingError != null
              ? Center(child: Text('エラー: ${rankingState.trendingError}'))
              : ListView.builder(
                  itemCount: rankingState.trendingRanking?.items.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = rankingState.trendingRanking!.items[index];
                    return ListTile(
                      leading: Text('#${item.rank}'),
                      title: Text(item.title),
                      subtitle: Text('スコア: ${item.score}'),
                    );
                  },
                ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: RankingPeriod.values.map((period) {
            return TextButton(
              onPressed: () => rankingViewModel.changePeriod(period),
              child: Text(
                rankingViewModel.getPeriodDisplayName(period),
                style: TextStyle(
                  fontWeight: rankingState.selectedPeriod == period
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
```

## アーキテクチャ

このパッケージは以下のレイヤーで構成されています：

1. **モデル層** - データモデルの定義
2. **リポジトリ層** - データの取得と保存を担当
3. **サービス層** - ビジネスロジックを担当
4. **プレゼンテーション層** - UIロジックを担当

## ライセンス

MIT License
