import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/services/image_url_builder.dart';
import '../models/affiliate_product.dart';
import '../services/affiliate_service.dart';

/// アフィリエイトサービスのプロバイダー
final affiliateServiceProvider = Provider<AffiliateService>((ref) {
  return AffiliateService();
});

/// スターのおすすめ商品を提供するプロバイダー
final starRecommendedProductsProvider = FutureProvider.family<List<AffiliateProduct>, String>((ref, starId) async {
  final affiliateService = ref.watch(affiliateServiceProvider);
  return await affiliateService.getStarRecommendedProducts(starId);
});

/// ユーザーのパーソナライズされたレコメンデーションを提供するプロバイダー
final personalizedRecommendationsProvider = FutureProvider.family<List<AffiliateProduct>, String>((ref, userId) async {
  final affiliateService = ref.watch(affiliateServiceProvider);
  return await affiliateService.getPersonalizedRecommendations(userId);
});

/// カテゴリ別商品リストを提供するプロバイダー
final productsByCategoryProvider = FutureProvider.family<List<AffiliateProduct>, String>((ref, category) async {
  final affiliateService = ref.watch(affiliateServiceProvider);
  return await affiliateService.getProductsByCategory(category);
});

/// アフィリエイト商品カードウィジェット
class AffiliateProductCard extends ConsumerWidget {
  final AffiliateProduct product;
  final VoidCallback? onTap;
  final bool showStarInfo;

  const AffiliateProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showStarInfo = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap ?? () => _launchAffiliateUrl(product.affiliateUrl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品画像
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: Image.network(
                    ImageUrlBuilder.thumbnail(product.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40),
                        ),
                      );
                    },
                  ),
                ),
                // おすすめバッジ
                if (product.isRecommended)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Text(
                        'おすすめ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // 商品情報
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品名
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // 価格
                  Text(
                    '¥${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // 説明
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (showStarInfo && product.starId.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    // スター情報（スターIDから名前を取得する実装が必要）
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16.0,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'スターのおすすめ商品',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // アフィリエイトURLを開く処理
  void _launchAffiliateUrl(String url) {
    // URLを開く処理（実際の実装ではurl_launcherなどを使用）
    print('Opening affiliate URL: $url');
    // 実際のアプリではここでアフィリエイトリンクのクリックを記録する処理も追加
  }
}

/// アフィリエイト商品リストウィジェット
class AffiliateProductList extends ConsumerWidget {
  final List<AffiliateProduct> products;
  final bool isLoading;
  final String? emptyMessage;
  final Function(AffiliateProduct)? onProductTap;
  final ScrollController? scrollController;
  final bool showStarInfo;

  const AffiliateProductList({
    super.key,
    required this.products,
    this.isLoading = false,
    this.emptyMessage,
    this.onProductTap,
    this.scrollController,
    this.showStarInfo = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ローディング中の場合はスケルトンローダーを表示
    if (isLoading) {
      return _buildSkeletonLoader();
    }

    // 商品がない場合はメッセージを表示
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? '商品がありません',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // 商品リストをグリッド表示
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return AffiliateProductCard(
          product: product,
          onTap: onProductTap != null ? () => onProductTap!(product) : null,
          showStarInfo: showStarInfo,
        );
      },
    );
  }

  /// ローディング中に表示するスケルトンローダー
  Widget _buildSkeletonLoader() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6, // スケルトンアイテムの数
      itemBuilder: (context, index) {
        return _buildSkeletonItem();
      },
    );
  }

  /// スケルトンアイテム（ローディングプレースホルダー）
  Widget _buildSkeletonItem() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 画像プレースホルダー
          AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              color: Colors.grey[300],
            ),
          ),
          // 情報プレースホルダー
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品名プレースホルダー
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                // 価格プレースホルダー
                Container(
                  width: 80,
                  height: 18,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                // 説明プレースホルダー
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 4),
                Container(
                  width: 150,
                  height: 14,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// スターのおすすめ商品セクションウィジェット
class StarRecommendedProductsSection extends ConsumerWidget {
  final String starId;
  final String title;
  final int maxProducts;
  final Function(AffiliateProduct)? onProductTap;
  final VoidCallback? onSeeAllTap;

  const StarRecommendedProductsSection({
    super.key,
    required this.starId,
    this.title = 'スターのおすすめ',
    this.maxProducts = 4,
    this.onProductTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(starRecommendedProductsProvider(starId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションヘッダー
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: const Text('すべて見る'),
                ),
            ],
          ),
        ),
        
        // 商品リスト
        SizedBox(
          height: 280, // カードの高さに合わせて調整
          child: productsAsync.when(
            data: (products) {
              final displayProducts = products.take(maxProducts).toList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: displayProducts.length,
                itemBuilder: (context, index) {
                  final product = displayProducts[index];
                  return SizedBox(
                    width: 180, // カードの幅
                    child: AffiliateProductCard(
                      product: product,
                      onTap: onProductTap != null ? () => onProductTap!(product) : null,
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: 3,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 180,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: Container(color: Colors.grey[300]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 16,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 80,
                                height: 18,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            error: (error, stackTrace) => Center(
              child: Text('エラーが発生しました: $error'),
            ),
          ),
        ),
      ],
    );
  }
}

/// パーソナライズされたレコメンデーションセクションウィジェット
class PersonalizedRecommendationsSection extends ConsumerWidget {
  final String userId;
  final String title;
  final int maxProducts;
  final Function(AffiliateProduct)? onProductTap;
  final VoidCallback? onSeeAllTap;

  const PersonalizedRecommendationsSection({
    super.key,
    required this.userId,
    this.title = 'あなたにおすすめ',
    this.maxProducts = 4,
    this.onProductTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(personalizedRecommendationsProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションヘッダー
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: const Text('すべて見る'),
                ),
            ],
          ),
        ),
        
        // 商品リスト
        SizedBox(
          height: 280, // カードの高さに合わせて調整
          child: productsAsync.when(
            data: (products) {
              final displayProducts = products.take(maxProducts).toList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: displayProducts.length,
                itemBuilder: (context, index) {
                  final pr<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>
