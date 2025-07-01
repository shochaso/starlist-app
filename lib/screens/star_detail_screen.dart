import 'package:flutter/material.dart';
import '../models/star.dart';
import '../models/activity.dart';
import '../widgets/activity_card.dart';

class StarDetailScreen extends StatelessWidget {
  final Star star;

  const StarDetailScreen({
    Key? key,
    required this.star,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
    final accentColor = isDarkMode ? Colors.blue : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final dividerColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    
    // モック用アクティビティデータ
    final List<Activity> activities = [
      Activity(
        id: '1',
        starId: star.id,
        type: 'youtube',
        title: '新曲「祝福」MV公開',
        content: 'YOASOBIの新曲「祝福」ミュージックビデオがYouTubeで公開されました。',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl: 'https://example.com/yoasobi_mv.jpg',
      ),
      Activity(
        id: '2',
        starId: star.id,
        type: 'music',
        title: 'デジタルシングル「祝福」配信開始',
        content: 'デジタルシングル「祝福」の配信が各音楽ストリーミングサービスで開始されました。',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: 'https://example.com/yoasobi_digital.jpg',
      ),
      Activity(
        id: '3',
        starId: star.id,
        type: 'purchase',
        title: '1stアルバム「THE BOOK」発売',
        content: 'YOASOBIの1stアルバム「THE BOOK」が発売されました。',
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        imageUrl: 'https://example.com/yoasobi_album.jpg',
        price: 3300,
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // アプリバー
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: backgroundColor,
            iconTheme: IconThemeData(color: textColor),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      star.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.star,
                            size: 100,
                            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                star.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (star.isVerified)
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'フォロワー: ${_formatNumber(star.followers)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: textColor),
                onPressed: () {
                  // シェア機能
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: textColor),
                onPressed: () {
                  // お気に入り機能
                },
              ),
            ],
          ),

          // スター情報
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // プラットフォーム
                  Text(
                    'プラットフォーム',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: star.platforms.map((platform) {
                      return Chip(
                        backgroundColor: _getPlatformColor(platform),
                        label: Text(
                          platform,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // ジャンル
                  Text(
                    'ジャンル',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: star.genres.map((genre) {
                      final genreRating = star.genreRatings[genre];
                      final level = genreRating?.level ?? 0;
                      
                      return Chip(
                        backgroundColor: _getGenreColor(genre),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              genre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (level > 0) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Lv.$level',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 認証状況
                  _buildVerificationSection(
                    context: context,
                    star: star,
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                    cardColor: cardColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // SNSアカウント
                  if (star.socialAccounts.isNotEmpty) ...[
                    Text(
                      '連携SNSアカウント',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...star.socialAccounts.map((account) => 
                      _buildSocialAccountItem(
                        context: context,
                        account: account,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        cardColor: cardColor,
                      ),
                    ).toList(),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // フォローボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // フォロー処理
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'フォローする',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVerificationSection({
    required BuildContext context,
    required Star star,
    required Color backgroundColor,
    required Color textColor,
    required Color cardColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                star.isVerified ? Icons.verified : Icons.info_outline,
                color: star.isVerified ? Colors.blue : Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '認証状況',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            star.isVerified
                ? 'このスターアカウントは公式に認証されています。SNSアカウントとの連携が確認され、本人であることが確認されています。'
                : 'このスターアカウントはまだ認証されていません。認証されると、プロフィール名の横に認証済みバッジが表示されます。',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
            ),
          ),
          if (!star.isVerified) ...[
            const SizedBox(height: 12),
            Text(
              '認証を受けるには、公式SNSアカウントを連携してください。',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSocialAccountItem({
    required BuildContext context,
    required SocialAccount account,
    required Color backgroundColor,
    required Color textColor,
    required Color cardColor,
  }) {
    IconData iconData;
    Color iconColor;
    
    switch (account.platform) {
      case 'X (Twitter)':
        iconData = Icons.alternate_email;
        iconColor = Colors.blue;
        break;
      case 'Instagram':
        iconData = Icons.photo_camera;
        iconColor = Colors.pink;
        break;
      case 'YouTube':
        iconData = Icons.play_arrow;
        iconColor = Colors.red;
        break;
      case 'TikTok':
        iconData = Icons.music_note;
        iconColor = Colors.black;
        break;
      default:
        iconData = Icons.link;
        iconColor = Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.platform,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  account.username,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (account.isVerified)
            const Icon(Icons.verified, color: Colors.blue)
        ],
      ),
    );
  }
  
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'YouTuber':
        return Colors.red;
      case 'ミュージシャン':
        return Colors.blue;
      case 'アイドル':
        return Colors.pink;
      case '実況者':
        return Colors.purple;
      case 'ストリーマー':
        return Colors.green;
      case 'お笑い芸人':
        return Colors.orange;
      case 'モデル':
        return Colors.amber;
      case 'クリエイター':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
  
  Color _getGenreColor(String genre) {
    switch (genre) {
      case '音楽':
        return Colors.blue.shade700;
      case 'J-POP':
        return Colors.blue.shade400;
      case 'ゲーム':
        return Colors.indigo;
      case 'スポーツ':
        return Colors.green;
      case 'アイドル':
        return Colors.pink;
      case '料理':
        return Colors.amber;
      case 'エンタメ':
        return Colors.purple;
      default:
        return Colors.grey.shade700;
    }
  }
} 