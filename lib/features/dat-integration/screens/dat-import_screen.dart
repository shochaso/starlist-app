import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/features/data_integration/widgets/blank_avatar.dart';

class DataImportScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  const DataImportScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<DataImportScreen> createState() => _DataImportScreenState();
}

class _DataImportScreenState extends ConsumerState<DataImportScreen> {
  // ... existing code ...

  @override
  Widget build(BuildContext context) {
    // テスト画像
    // const ServiceIcon('assets/service_icons/abema.png', size: 40),
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text('データ取込み')) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    '取り込み可能なサービス',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildServiceCard(context, theme, 'youtube', 'YouTube',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'spotify', 'Spotify',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'amazon', 'Amazon',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'netflix', 'Netflix',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(
                          context,
                          theme,
                          'prime_video',
                          'Prime Video',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'hulu', 'Hulu',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(
                          context,
                          theme,
                          'disney_plus',
                          'Disney+',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'ubereats', 'Uber Eats',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'demaecan', '出前館',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'steam', 'Steam',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(
                          context,
                          theme,
                          'playstation',
                          'PlayStation',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'nintendo', 'Nintendo',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'kindle', 'Kindle',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(
                          context,
                          theme,
                          'apple_music',
                          'Apple Music',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(
                          context,
                          theme,
                          'youtube_music',
                          'YouTube Music',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'unext', 'U-NEXT',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'abema', 'ABEMA',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(
                          context,
                          theme,
                          'rakuten_ichiba',
                          '楽天市場',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'shein', 'SHEIN',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(
                          context,
                          theme,
                          'yahoo_shopping',
                          'Yahoo!ショッピング',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'zozotown', 'ZOZOTOWN',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'gu', 'GU',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'uniqlo', 'UNIQLO',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(context, theme, 'audible', 'Audible',
                          buildBlankAvatar(size: 24)),
                      _buildServiceCard(
                          context,
                          theme,
                          'rakuten_books',
                          '楽天ブックス',
                          buildBlankAvatar(size: 24)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('取込み精度確認'),
                  const SizedBox(height: 16),
                  _buildOcrAccuracySection(
                      context, theme, currentUser.id, ocrResult),
                  const SizedBox(height: 32),
                  _buildSectionTitle('エンリッチ（データ拡充）精度確認'),
                  const SizedBox(height: 16),
                  _buildEnrichAccuracySection(
                      context, theme, currentUser.id, enrichResult),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
