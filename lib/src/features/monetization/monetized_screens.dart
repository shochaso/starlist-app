import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/monetization/models/ad_model.dart';
import '../features/monetization/models/affiliate_product.dart';
import '../features/monetization/services/ad_service.dart';
import '../features/monetization/services/affiliate_service.dart';
import '../features/monetization/widgets/affiliate_product_widgets.dart';
import '../features/monetization/widgets/affiliate_revenue_widgets.dart';
import '../features/monetization/widgets/free_user_ad_widgets.dart';
import '../features/monetization/widgets/standard_member_ad_widgets.dart';

/// 収益化機能を統合したホーム画面
class MonetizedHomeScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userType;
  final int sessionDurationMinutes;

  const MonetizedHomeScreen({
    Key? key,
    required this.userId,
    required this.userType,
    this.sessionDurationMinutes = 0,
  }) : super(key: key);

  @override
  ConsumerState<MonetizedHomeScreen> createState() => _MonetizedHomeScreenState();
}

class _MonetizedHomeScreenState extends ConsumerState<MonetizedHomeScreen> {
  @override
  void initState() {
    super.initState();
    
    // 画面表示時にインタースティシャル広告を表示するかチェック
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdWidgetFactory.showInterstitialAdIfNeeded(
        context: context,
        userId: widget.userId,
        userType: widget.userType,
        sessionDurationMinutes: widget.sessionDurationMinutes,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 仮のスターID（実際のアプリでは適切なスターIDを使用）
    const starId = 'star123';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starlist'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上部広告バナー（ユーザータイプに応じて表示）
            AdWidgetFactory.createAdBanner(
              userId: widget.userId,
              userType: widget.userType,
              screenName: 'home_screen',
            ),
            
            // スターのおすすめ商品セクション
            StarRecommendedProductsSection(
              starId: starId,
              title: 'スターのおすすめ商品',
              maxProducts: 4,
              onSeeAllTap: () {
                // すべての商品を表示する画面に遷移
                print('See all recommended products');
              },
            ),
            
            // 中間広告バナー（ユーザータイプに応じて表示）
            AdWidgetFactory.createAdBanner(
              userId: widget.userId,
              userType: widget.userType,
              screenName: 'home_screen',
              adType: AdType.native,
            ),
            
            // パーソナライズされたレコメンデーションセクション
            PersonalizedRecommendationsSection(
              userId: widget.userId,
              title: 'あなたにおすすめ',
              maxProducts: 4,
              onSeeAllTap: () {
                // すべてのレコメンデーションを表示する画面に遷移
                print('See all personalized recommendations');
              },
            ),
            
            // 下部広告バナー（ユーザータイプに応じて表示）
            AdWidgetFactory.createAdBanner(
              userId: widget.userId,
              userType: widget.userType,
              screenName: 'home_screen',
              adType: AdType.banner,
            ),
            
            // スペース
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// 収益化機能を統合したスタープロフィール画面
class MonetizedStarProfileScreen extends ConsumerWidget {
  final String starId;
  final String userId;
  final String userType;

  const MonetizedStarProfileScreen({
    Key? key,
    required this.starId,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スタープロフィール'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // スタープロフィールヘッダー
            _buildStarProfileHeader(),
            
            // スターの場合のみ収益ダッシュボードを表示
            if (userType == UserType.star)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AffiliateRevenueDashboard(starId: starId),
              ),
            
            // スターのおすすめ商品セクション
            StarRecommendedProductsSection(
              starId: starId,
              title: 'おすすめ商品',
              maxProducts: 4,
              onSeeAllTap: () {
                // すべての商品を表示する画面に遷移
                print('See all recommended products');
              },
            ),
            
            // 広告バナー（スターのプロフィール画面ではスタンダード会員にも広告を表示しない）
            if (userType == UserType.free)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FreeUserAdBanner(
                  userId: userId,
                  adType: AdType.banner,
                  preferredSize: AdSize.medium,
                ),
              ),
            
            // スペース
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// スタープロフィールヘッダーを構築
  Widget _buildStarProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // スターのアバターと基本情報
          Row(
            children: [
              // アバター
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              // 基本情報
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'スター名',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '@starname',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'フォロワー: 10,000人',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // スターの自己紹介
          const Text(
            'これはスターの自己紹介文です。ここにスターの詳細な説明や活動内容などが表示されます。',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // フォローボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // フォロー処理
                print('Follow star: $starId');
              },
              child: const Text('フォローする'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 収益化機能を統合した設定画面
class MonetizedSettingsScreen extends ConsumerWidget {
  final String userId;
  final String userType;

  const MonetizedSettingsScreen({
    Key? key,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          // 会員ステータス
          ListTile(
            title: const Text('会員ステータス'),
            subtitle: Text(_getUserTypeLabel(userType)),
            leading: const Icon(Icons.card_membership),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 会員ステータス画面に遷移
              print('Navigate to membership status screen');
            },
          ),
          
          // 会員プランのアップグレード（無料ユーザーとスタンダード会員のみ表示）
          if (userType == UserType.free || userType == UserType.standard)
            ListTile(
              title: const Text('会員プランをアップグレード'),
              subtitle: const Text('広告を非表示にして、より多くの機能を利用できます'),
              leading: const Icon(Icons.upgrade),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // アップグレード画面に遷移
                print('Navigate to upgrade screen');
              },
            ),
          
          // スターの場合のみ収益管理を表示
          if (userType == UserType.star)
            ListTile(
              title: const Text('収益管理'),
              subtitle: const Text('アフィリエイト収益の詳細を確認できます'),
              leading: const Icon(Icons.attach_money),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // 収益詳細画面に遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AffiliateRevenueDetailScreen(starId: userId),
                  ),
                );
              },
            ),
          
          // 広告設定（無料ユーザーとスタンダード会員のみ表示）
          if (userType == UserType.free || userType == UserType.standard)
            ListTile(
              title: const Text('広告設定'),
              subtitle: const Text('広告の表示方法をカスタマイズできます'),
              leading: const Icon(Icons.ad_units),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // 広告設定画面に遷移
                print('Navigate to ad settings screen');
              },
            ),
          
          // アカウント設定
          const ListTile(
            title: Text('アカウント設定'),
            subtitle: Text('プロフィール、通知、セキュリティなどの設定'),
            leading: Icon(Icons.settings),
            trailing: Icon(Icons.chevron_right),
          ),
          
          // ヘルプとサポート
          const ListTile(
            title: Text('ヘルプとサポート'),
            subtitle: Text('よくある質問、お問い合わせ'),
            leading: Icon(Icons.help),
            trailing: Icon(Icons.chevron_right),
          ),
          
          // ログアウト
          ListTile(
            title: const Text('ログアウト'),
            leading: const Icon(Icons.logout),
            onTap: () {
              // ログアウト処理
              print('Logout');
            },
          ),
          
          // 無料ユーザーの場合のみ下部に広告を表示
          if (userType == UserType.free)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FreeUserAdBanner(
                userId: userId,
                adType: AdType.banner,
                preferredSize: AdSize.medium,
              ),
            ),
        ],
      ),
    );
  }

  /// ユーザータイプに対応するラベルを取得
  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case UserType.free:
        return '無料ユーザー';
      case UserType.standard:
        return 'スタンダード会員';
      case UserType.premium:
        return 'プレミアム会員';
      case UserType.star:
        return 'スター';
      default:
        return '不明';
    }
  }
}
