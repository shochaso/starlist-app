import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    Image.asset('assets/service_icons/abema.jpg', width: 40, height: 40),
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
                          ServiceIconRegistry.iconFor('youtube')),
                      _buildServiceCard(context, theme, 'spotify', 'Spotify',
                          ServiceIconRegistry.iconFor('spotify')),
                      _buildServiceCard(context, theme, 'amazon', 'Amazon',
                          ServiceIconRegistry.iconFor('amazon')),
                      _buildServiceCard(context, theme, 'netflix', 'Netflix',
                          ServiceIconRegistry.iconFor('netflix')),
                      _buildServiceCard(context, theme, 'prime_video', 'Prime Video',
                          ServiceIconRegistry.iconFor('amazon_prime_video')),
                      _buildServiceCard(context, theme, 'hulu', 'Hulu',
                          ServiceIconRegistry.iconFor('hulu')),
                      _buildServiceCard(context, theme, 'disney_plus', 'Disney+',
                          ServiceIconRegistry.iconFor('disney_plus')),
                      _buildServiceCard(context, theme, 'ubereats', 'Uber Eats',
                          ServiceIconRegistry.iconFor('uber_eats')),
                      _buildServiceCard(context, theme, 'demaecan', '出前館',
                          ServiceIconRegistry.iconFor('demaecan')),
                      _buildServiceCard(context, theme, 'steam', 'Steam',
                          ServiceIconRegistry.iconFor('steam')),
                      _buildServiceCard(context, theme, 'playstation', 'PlayStation',
                          ServiceIconRegistry.iconFor('playstation')),
                      _buildServiceCard(context, theme, 'nintendo', 'Nintendo',
                          ServiceIconRegistry.iconFor('nintendo')),
                      _buildServiceCard(context, theme, 'kindle', 'Kindle',
                          ServiceIconRegistry.iconFor('kindle')),
                      _buildServiceCard(context, theme, 'apple_music', 'Apple Music',
                          ServiceIconRegistry.iconFor('apple_music')),
                      _buildServiceCard(context, theme, 'youtube_music', 'YouTube Music',
                          ServiceIconRegistry.iconFor('youtube_music')),
                      _buildServiceCard(context, theme, 'unext', 'U-NEXT',
                          ServiceIconRegistry.iconFor('unext')),
                      _buildServiceCard(context, theme, 'abema', 'ABEMA',
                          ServiceIconRegistry.iconFor('abema')),
                      _buildServiceCard(context, theme, 'rakuten_ichiba', '楽天市場',
                          ServiceIconRegistry.iconFor('rakuten_ichiba')),
                      _buildServiceCard(context, theme, 'shein', 'SHEIN',
                          ServiceIconRegistry.iconFor('shein')),
                      _buildServiceCard(context, theme, 'yahoo_shopping', 'Yahoo!ショッピング',
                          ServiceIconRegistry.iconFor('yahoo_shopping')),
                      _buildServiceCard(context, theme, 'zozotown', 'ZOZOTOWN',
                          ServiceIconRegistry.iconFor('zozotown')),
                      _buildServiceCard(context, theme, 'gu', 'GU',
                          ServiceIconRegistry.iconFor('gu')),
                      _buildServiceCard(context, theme, 'uniqlo', 'UNIQLO',
                          ServiceIconRegistry.iconFor('uniqlo')),
                      _buildServiceCard(context, theme, 'audible', 'Audible',
                          ServiceIconRegistry.iconFor('audible')),
                      _buildServiceCard(context, theme, 'rakuten_books', '楽天ブックス',
                          ServiceIconRegistry.iconFor('rakuten_books')),
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
