import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/netflix_models.dart';
import '../../ocr/ocr_service.dart';
import '../../../core/logging/logger.dart';
import '../../../core/errors/app_exceptions.dart';

/// Netflix視聴履歴OCR解析サービス
/// 既存のOCRServiceを拡張してNetflix特化の解析機能を提供
class NetflixOcrService {
  final OCRService _ocrService;
  final Logger _logger;
  final ImagePicker _imagePicker;

  NetflixOcrService({
    OCRService? ocrService,
    Logger? logger,
    ImagePicker? imagePicker,
  })  : _ocrService = ocrService ?? OCRService(),
        _logger = logger ?? Logger(),
        _imagePicker = imagePicker ?? ImagePicker();

  /// Netflix視聴履歴画像をOCR解析
  Future<List<NetflixViewingHistory>> analyzeNetflixViewingImage({
    required String userId,
    required File imageFile,
    required String sourceType, // 'screenshot', 'email', 'history_page'
  }) async {
    try {
      _logger.info('Starting Netflix viewing history OCR analysis for user: $userId');
      
      // 画像を圧縮してメモリ使用量を最適化
      final compressedImage = await _compressImage(imageFile);
      
      // 基本OCR解析を実行
      final ocrResult = await _ocrService.extractTextFromImage(compressedImage);
      
      if (ocrResult['text'] == null || ocrResult['text'].isEmpty) {
        throw ApiException(
          message: 'OCR failed to extract text from image',
          details: 'No text content found in the image',
        );
      }
      
      // Netflix特化のテキスト解析
      final viewingHistory = await _extractNetflixViewingFromText(
        userId: userId,
        ocrText: ocrResult['text'],
        sourceType: sourceType,
        confidence: ocrResult['confidence'] ?? 0.0,
      );
      
      _logger.info('Extracted ${viewingHistory.length} Netflix viewing items from OCR');
      return viewingHistory;
      
    } catch (e) {
      _logger.error('Netflix OCR analysis failed', e);
      throw ApiException(
        message: 'Failed to analyze Netflix viewing history image',
        details: e.toString(),
      );
    } finally {
      // 一時ファイルをクリーンアップ
      _cleanupTempFiles();
    }
  }

  /// ギャラリーから画像を選択してOCR解析
  Future<List<NetflixViewingHistory>> analyzeImageFromGallery({
    required String userId,
    required String sourceType,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        throw ApiException(
          message: 'No image selected',
          details: 'User cancelled image selection',
        );
      }

      final imageFile = File(pickedFile.path);
      return await analyzeNetflixViewingImage(
        userId: userId,
        imageFile: imageFile,
        sourceType: sourceType,
      );
      
    } catch (e) {
      _logger.error('Failed to analyze image from gallery', e);
      rethrow;
    }
  }

  /// Netflix特化のテキスト解析
  Future<List<NetflixViewingHistory>> _extractNetflixViewingFromText({
    required String userId,
    required String ocrText,
    required String sourceType,
    required double confidence,
  }) async {
    final viewingHistory = <NetflixViewingHistory>[];
    
    try {
      // Netflix視聴履歴画面パターン
      if (sourceType == 'screenshot' || sourceType == 'history_page') {
        viewingHistory.addAll(await _extractFromHistoryScreenPattern(userId, ocrText));
      }
      
      // Netflix通知メールパターン
      else if (sourceType == 'email') {
        viewingHistory.addAll(await _extractFromEmailPattern(userId, ocrText));
      }
      
      // 汎用パターン（フォールバック）
      else {
        viewingHistory.addAll(await _extractFromGenericPattern(userId, ocrText));
      }
      
    } catch (e) {
      _logger.warning('Pattern extraction failed, trying fallback: $e');
      viewingHistory.addAll(await _extractFromGenericPattern(userId, ocrText));
    }
    
    return viewingHistory;
  }

  /// Netflix視聴履歴画面からの抽出
  Future<List<NetflixViewingHistory>> _extractFromHistoryScreenPattern(String userId, String text) async {
    final viewingHistory = <NetflixViewingHistory>[];
    
    // 視聴履歴の一般的なパターン
    final historyItemRegex = RegExp(
      r'(.+?)\s+(\d{1,2}\/\d{1,2}\/\d{4}|\d{4}\/\d{1,2}\/\d{1,2})',
      multiLine: true,
      caseSensitive: false,
    );
    
    // シーズン・エピソード情報のパターン
    final episodeRegex = RegExp(
      r'(.+?)\s+シーズン\s*(\d+)\s*[:：]?\s*エピソード\s*(\d+)[:：]?\s*(.+)?',
      multiLine: true,
      caseSensitive: false,
    );
    
    final matches = historyItemRegex.allMatches(text);
    int itemIndex = 0;
    
    for (final match in matches) {
      final fullTitle = match.group(1)?.trim();
      final dateString = match.group(2)?.trim();
      
      if (fullTitle != null && dateString != null) {
        // 日付を解析
        DateTime? watchedAt;
        try {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            // 日本形式の日付を想定
            if (parts[0].length == 4) {
              // YYYY/MM/DD
              watchedAt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            } else {
              // MM/DD/YYYY
              watchedAt = DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
            }
          }
        } catch (e) {
          _logger.warning('Failed to parse date: $dateString');
          watchedAt = DateTime.now().subtract(Duration(days: itemIndex));
        }
        
        // シーズン・エピソード情報を抽出
        String title = fullTitle;
        String? subtitle;
        int? seasonNumber;
        int? episodeNumber;
        NetflixContentType contentType = NetflixContentType.movie;
        
        final episodeMatch = episodeRegex.firstMatch(fullTitle);
        if (episodeMatch != null) {
          title = episodeMatch.group(1)?.trim() ?? title;
          seasonNumber = int.tryParse(episodeMatch.group(2) ?? '');
          episodeNumber = int.tryParse(episodeMatch.group(3) ?? '');
          subtitle = episodeMatch.group(4)?.trim();
          contentType = NetflixContentType.series;
        }
        
        final viewingItem = NetflixViewingHistory(
          id: 'ocr_history_${DateTime.now().millisecondsSinceEpoch}_$itemIndex',
          userId: userId,
          contentId: 'content_${title.hashCode}',
          title: title,
          subtitle: subtitle,
          contentType: contentType,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
          watchedAt: watchedAt ?? DateTime.now().subtract(Duration(days: itemIndex)),
          watchStatus: NetflixWatchStatus.completed,
          cast: [],
          genres: _inferGenresFromTitle(title),
          metadata: {
            'source': 'history_ocr',
            'extraction_method': 'history_screen_pattern',
            'original_text_snippet': match.group(0),
            'source_type': 'screenshot',
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        viewingHistory.add(viewingItem);
        itemIndex++;
      }
    }
    
    return viewingHistory;
  }

  /// Netflix通知メールからの抽出
  Future<List<NetflixViewingHistory>> _extractFromEmailPattern(String userId, String text) async {
    final viewingHistory = <NetflixViewingHistory>[];
    
    // Netflix通知メールの一般的なパターン
    final emailPatterns = [
      // 新しいエピソードの通知
      RegExp(r'(.+?)の新しいエピソードが配信されました', caseSensitive: false),
      // 新作映画の通知
      RegExp(r'新作映画\s*[:：]\s*(.+?)(?:が|を)', caseSensitive: false),
      // おすすめコンテンツ
      RegExp(r'おすすめ\s*[:：]?\s*(.+)', caseSensitive: false),
    ];
    
    int itemIndex = 0;
    for (final pattern in emailPatterns) {
      final matches = pattern.allMatches(text);
      
      for (final match in matches) {
        final title = match.group(1)?.trim();
        
        if (title != null && title.length > 2) {
          final viewingItem = NetflixViewingHistory(
            id: 'ocr_email_${DateTime.now().millisecondsSinceEpoch}_$itemIndex',
            userId: userId,
            contentId: 'content_${title.hashCode}',
            title: title,
            contentType: _inferContentTypeFromTitle(title),
            watchedAt: DateTime.now(),
            watchStatus: NetflixWatchStatus.watchlist,
            cast: [],
            genres: _inferGenresFromTitle(title),
            metadata: {
              'source': 'email_ocr',
              'extraction_method': 'email_pattern',
              'original_text_snippet': match.group(0),
              'confidence': 'medium',
            },
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          viewingHistory.add(viewingItem);
          itemIndex++;
        }
      }
    }
    
    return viewingHistory;
  }

  /// 汎用パターンからの抽出（フォールバック）
  Future<List<NetflixViewingHistory>> _extractFromGenericPattern(String userId, String text) async {
    final viewingHistory = <NetflixViewingHistory>[];
    
    // Netflix関連のキーワードを含む行を抽出
    final lines = text.split('\n');
    final netflixLines = lines.where((line) => 
        line.contains('Netflix') || 
        line.contains('シーズン') || 
        line.contains('エピソード') ||
        line.contains('映画') ||
        line.contains('ドラマ')
    ).toList();
    
    int itemIndex = 0;
    for (final line in netflixLines.take(10)) { // 最大10件に制限
      final cleanLine = line.trim();
      if (cleanLine.length >= 3 && cleanLine.length <= 100) {
        final viewingItem = NetflixViewingHistory(
          id: 'ocr_generic_${DateTime.now().millisecondsSinceEpoch}_$itemIndex',
          userId: userId,
          contentId: 'content_${cleanLine.hashCode}',
          title: cleanLine,
          contentType: _inferContentTypeFromTitle(cleanLine),
          watchedAt: DateTime.now(),
          watchStatus: NetflixWatchStatus.completed,
          cast: [],
          genres: _inferGenresFromTitle(cleanLine),
          metadata: {
            'source': 'generic_ocr',
            'extraction_method': 'generic_pattern',
            'original_text_snippet': cleanLine,
            'confidence': 'low',
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        viewingHistory.add(viewingItem);
        itemIndex++;
      }
    }
    
    return viewingHistory;
  }

  /// タイトルからコンテンツタイプを推定
  NetflixContentType _inferContentTypeFromTitle(String title) {
    final titleLower = title.toLowerCase();
    
    // アニメ
    if (titleLower.contains('アニメ') || titleLower.contains('anime') ||
        titleLower.contains('進撃の巨人') || titleLower.contains('鬼滅の刃') ||
        titleLower.contains('ワンピース')) {
      return NetflixContentType.anime;
    }
    
    // ドキュメンタリー
    if (titleLower.contains('ドキュメンタリー') || titleLower.contains('documentary') ||
        titleLower.contains('地球') || titleLower.contains('自然') ||
        titleLower.contains('科学')) {
      return NetflixContentType.documentary;
    }
    
    // キッズ
    if (titleLower.contains('キッズ') || titleLower.contains('子供') ||
        titleLower.contains('kids') || titleLower.contains('ペッパピッグ')) {
      return NetflixContentType.kids;
    }
    
    // シーズン・エピソードの表記があればシリーズ
    if (titleLower.contains('シーズン') || titleLower.contains('season') ||
        titleLower.contains('エピソード') || titleLower.contains('episode') ||
        titleLower.contains('第') && titleLower.contains('話')) {
      return NetflixContentType.series;
    }
    
    // 映画キーワード
    if (titleLower.contains('映画') || titleLower.contains('movie') ||
        titleLower.contains('劇場版')) {
      return NetflixContentType.movie;
    }
    
    // デフォルトは映画
    return NetflixContentType.movie;
  }

  /// タイトルからジャンルを推定
  List<String> _inferGenresFromTitle(String title) {
    final genres = <String>[];
    final titleLower = title.toLowerCase();
    
    // 日本関連
    if (titleLower.contains('日本') || titleLower.contains('japan') ||
        titleLower.contains('和') || titleLower.contains('邦')) {
      genres.add('日本');
    }
    
    // アクション
    if (titleLower.contains('アクション') || titleLower.contains('action') ||
        titleLower.contains('戦') || titleLower.contains('バトル')) {
      genres.add('アクション');
    }
    
    // コメディ
    if (titleLower.contains('コメディ') || titleLower.contains('comedy') ||
        titleLower.contains('笑') || titleLower.contains('爆笑')) {
      genres.add('コメディ');
    }
    
    // ホラー・スリラー
    if (titleLower.contains('ホラー') || titleLower.contains('horror') ||
        titleLower.contains('スリラー') || titleLower.contains('thriller') ||
        titleLower.contains('怖')) {
      genres.add('ホラー');
    }
    
    // ロマンス
    if (titleLower.contains('ロマンス') || titleLower.contains('romance') ||
        titleLower.contains('恋') || titleLower.contains('愛')) {
      genres.add('ロマンス');
    }
    
    // SF
    if (titleLower.contains('sf') || titleLower.contains('sci-fi') ||
        titleLower.contains('未来') || titleLower.contains('宇宙')) {
      genres.add('SF');
    }
    
    // ドラマ
    if (titleLower.contains('ドラマ') || titleLower.contains('drama')) {
      genres.add('ドラマ');
    }
    
    return genres.isEmpty ? ['その他'] : genres;
  }

  /// 画像を圧縮してメモリ使用量を最適化
  Future<File> _compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_netflix_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 800,
        minHeight: 600,
        format: CompressFormat.jpeg,
      );
      
      return compressedFile != null ? File(compressedFile.path) : imageFile;
    } catch (e) {
      _logger.warning('Image compression failed, using original: $e');
      return imageFile;
    }
  }

  /// 一時ファイルのクリーンアップ
  Future<void> _cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && file.path.contains('compressed_netflix_')) {
          final stats = await file.stat();
          final age = DateTime.now().difference(stats.modified);
          
          // 1時間以上古い一時ファイルを削除
          if (age.inHours > 1) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      _logger.warning('Failed to cleanup temp files: $e');
    }
  }
}