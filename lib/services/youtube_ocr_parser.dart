import 'dart:typed_data';
import 'dart:convert';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';

class YouTubeVideo {
  final String title;
  final String channel;
  final String? viewCount;
  bool isSelected;

  YouTubeVideo({
    required this.title,
    required this.channel,
    this.viewCount,
    this.isSelected = true,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'channel': channel,
        'viewCount': viewCount,
        'isSelected': isSelected,
      };
}

class YouTubeOCRParser {
  final String _apiKey;
  vision.VisionApi? _visionApi;

  YouTubeOCRParser({required String apiKey}) : _apiKey = apiKey;

  Future<void> _initializeApi() async {
    final client = clientViaApiKey(_apiKey);
    _visionApi = vision.VisionApi(client);
  }

  Future<List<YouTubeVideo>> parseScreenshot(Uint8List imageBytes) async {
    if (_visionApi == null) {
      await _initializeApi();
    }

    final image = vision.Image()
      ..content = base64Encode(imageBytes);

    final feature = vision.Feature()
      ..type = 'TEXT_DETECTION';

    final request = vision.AnnotateImageRequest()
      ..image = image
      ..features = [feature];

    final batchRequest = vision.BatchAnnotateImagesRequest()
      ..requests = [request];

    final response = await _visionApi!.images.annotate(batchRequest);
    final textAnnotation = response.responses?.first.fullTextAnnotation;

    if (textAnnotation == null) {
      return [];
    }

    return _parseYouTubeText(textAnnotation.text ?? '');
  }

  // 手動入力テキストの解析メソッドを追加
  Future<List<YouTubeVideo>> parseManualText(String text) async {
    return _parseYouTubeText(text);
  }

  List<YouTubeVideo> _parseYouTubeText(String text) {
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    final videos = <YouTubeVideo>[];
    
    String? currentTitle;
    String? currentChannel;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // パターン1: "題名：" で始まる行
      if (line.startsWith('題名：') || line.startsWith('題名:')) {
        currentTitle = line.substring(3).trim(); // "題名："を除去
        continue;
      }
      
      // パターン2: "投稿者：" または "投稿者；" で始まる行
      if (line.startsWith('投稿者：') || line.startsWith('投稿者:') || line.startsWith('投稿者；')) {
        final colonIndex = line.indexOf('：');
        final semicolonIndex = line.indexOf('；');
        final separatorIndex = colonIndex != -1 ? colonIndex : (semicolonIndex != -1 ? semicolonIndex : line.indexOf(':'));
        
        if (separatorIndex != -1) {
          currentChannel = line.substring(separatorIndex + 1).trim();
          
          // 題名と投稿者が揃ったら動画オブジェクトを作成
          if (currentTitle != null) {
            videos.add(YouTubeVideo(
              title: currentTitle,
              channel: _cleanChannelName(currentChannel),
              viewCount: null,
            ));
            currentTitle = null;
            currentChannel = null;
          }
        }
        continue;
      }
      
      // パターン3: 題名と投稿者のラベルなしでタイトルだけの行（次の行が投稿者）
      if (!_isSystemText(line) && line.length > 5 && currentTitle == null) {
        // 次の行が投稿者かチェック
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          if (nextLine.startsWith('投稿者：') || nextLine.startsWith('投稿者:') || nextLine.startsWith('投稿者；')) {
            currentTitle = line;
            continue;
          }
        }
        
        // 単独のタイトル行として処理（チャンネル名が見つからない場合）
        if (!line.contains('投稿者') && !line.contains('題名')) {
          currentTitle = line;
        }
      }
    }
    
    // 残った題名だけのアイテムも追加（投稿者不明として）
    if (currentTitle != null) {
      videos.add(YouTubeVideo(
        title: currentTitle,
        channel: '不明',
        viewCount: null,
      ));
    }
    
    return videos;
  }

  String _cleanChannelName(String channel) {
    // チャンネル名から余分な記号を除去
    return channel
        .replaceAll('・', '')
        .replaceAll('「', '')
        .replaceAll('」', '')
        .replaceAll('【', '')
        .replaceAll('】', '')
        .trim();
  }

  bool _isSystemText(String text) {
    // システムテキストや不要な行を除外
    final systemPatterns = [
      '登録チャンネル',
      'マイページ',
      'YouTube',
      'ホーム',
      '検索',
      '履歴',
      '再生リスト',
      'ライブラリ',
      '設定',
    ];
    
    // 短すぎる行や記号のみの行を除外
    if (text.length < 3) return true;
    if (RegExp(r'^[：；:+？\s]+$').hasMatch(text)) return true;
    
    return systemPatterns.any((pattern) => text.contains(pattern));
  }
}