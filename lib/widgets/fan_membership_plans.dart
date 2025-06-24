import 'package:flutter/material.dart';

class FanMembershipPlans extends StatelessWidget {
  const FanMembershipPlans({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ファンプラン管理',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'あなたにぴったりのプランを選んで、限定コンテンツを楽しもう',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF65676B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // プレミアムプラン
          _buildPlanCard(
            title: 'プレミアムプラン',
            price: '¥2,980',
            originalPrice: '¥3,980',
            period: '/月',
            description: '最高級の体験をお届け',
            features: [
              '全てのスター限定コンテンツ',
              '広告完全非表示',
              '優先メッセージ返信',
              '特別イベント招待',
              '限定ライブ配信アクセス',
              'プレミアムバッジ表示',
            ],
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            isPopular: true,
          ),

          const SizedBox(height: 20),

          // スタンダードプラン
          _buildPlanCard(
            title: 'スタンダードプラン',
            price: '¥1,980',
            period: '/月',
            description: 'バランスの取れた標準プラン',
            features: [
              '基本限定コンテンツ',
              '広告削減（50%オフ）',
              'メッセージ送信',
              '月1回特別コンテンツ',
              'スタンダードバッジ表示',
            ],
            gradient: const LinearGradient(
              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          const SizedBox(height: 20),

          // ライトプラン
          _buildPlanCard(
            title: 'ライトプラン',
            price: '¥980',
            period: '/月',
            description: 'お試しに最適な軽量プラン',
            features: [
              '一部限定コンテンツ',
              'メッセージ送信',
              'フォロー機能',
              'ライトバッジ表示',
            ],
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE66D), Color(0xFFFF9A9E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          const SizedBox(height: 20),

          // 無料プラン
          _buildFreePlan(),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    String? originalPrice,
    required String period,
    required String description,
    required List<String> features,
    required LinearGradient gradient,
    bool isPopular = false,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: isPopular ? 12 : 0),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.9),
                blurRadius: 1,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (originalPrice != null) ...[
                          Text(
                            originalPrice,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              price,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              period,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: プラン登録の実装
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: gradient.colors.first,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'このプランを選択',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isPopular)
          Positioned(
            top: 0,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                '🔥 人気No.1',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFreePlan() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ベーシックプラン',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '無料でスタート',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF65676B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '¥0',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '/月',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF10B981).withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...[
              '基本コンテンツアクセス',
              'メッセージ送信',
              'フォロー機能',
              'コミュニティ参加',
            ].map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF10B981),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981),
                  width: 2,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 無料登録の実装
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '無料で始める',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 