import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../config/environment_config.dart';
import '../models/enriched_link_result.dart';
import 'openai_ocr_service.dart';
import 'youtube_api_link_enricher_service.dart';
import 'youtube_ocr_parser_v6.dart';

enum YoutubeOcrProviderMode { responsesApi, legacyChat }

/// Lightweight wrapper that mirrors the local "YouTube視聴履歴OCRインポーター"
/// behavior. The importer runs a multimodal OpenAI OCR request and then parses
/// the raw text into [VideoData] with simple heuristics. It can also enrich
/// YouTube URLs via OpenAI when an API key is provided.
class YoutubeLocalImporter {
  YoutubeLocalImporter._();

  static const _ocrPrompt =
      'This is a screenshot of a YouTube watch history. Extract the video titles and their corresponding channel names. Each video entry might span one or two lines. Format the output as one line per video, with title and channel separated by " - ". IMPORTANT: Do not include any introductory text, headers, explanations, or markdown formatting like asterisks. Only return the raw list of videos.';
  static final YoutubeApiLinkEnricherService _youtubeApiEnricher =
      YoutubeApiLinkEnricherService();

  /// Parses OCR text into structured [VideoData] using the same heuristics as
  /// the local importer (TypeScript version).
  static List<VideoData> parseOcrText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return [];

    final allLines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (allLines.isEmpty) return [];

    final preamblePattern = RegExp(r'^(here are|sure, here|here are|以下に|はい、)',
        caseSensitive: false);

    var startIndex = allLines.indexWhere((line) {
      final isPreamble = preamblePattern.hasMatch(line);
      final isHeaderLike = line.endsWith(':');
      return !isPreamble && !isHeaderLike && line.length > 5;
    });

    if (startIndex == -1) {
      final hasPreamble = allLines.any(preamblePattern.hasMatch);
      if (hasPreamble) return [];
      startIndex = 0;
    }

    final lines = allLines.sublist(startIndex);
    final items = <VideoData>[];

    for (var i = 0; i < lines.length; i++) {
      final cleaned =
          lines[i].replaceFirst(RegExp(r'^[\*\-\d\.]+\s*'), '').trim();
      if (cleaned.isEmpty) continue;

      final dashIndex = cleaned.lastIndexOf(' - ');
      if (dashIndex > 0 && dashIndex < cleaned.length - 3) {
        final title = cleaned.substring(0, dashIndex).trim();
        final channel = cleaned.substring(dashIndex + 3).trim();
        items.add(
          VideoData(
            title: title,
            channel: channel,
            confidence: 0.95,
          ),
        );
        continue;
      }

      final title = cleaned;
      var channel = '';
      if (i + 1 < lines.length) {
        final nextLine = lines[i + 1];
        final maybeTitle = RegExp(r'^[\*\-\d\.]+\s*').hasMatch(nextLine) ||
            nextLine.contains(' - ');
        if (!maybeTitle) {
          channel = nextLine;
          const splitters = ['・', '•', '—', '視聴回数', '回視聴'];
          for (final splitter in splitters) {
            if (channel.contains(splitter)) {
              channel = channel.split(splitter).first.trim();
              break;
            }
          }
          i++; // consume channel line
        }
      }

      items.add(
        VideoData(
          title: title,
          channel: channel,
          confidence: 0.9,
        ),
      );
    }

    return items
        .where((item) => !preamblePattern.hasMatch(item.title))
        .toList();
  }

  /// Runs OpenAI multimodal OCR (legacy chat completions).
  static Future<String> runOpenAiLegacyOcr({
    required Uint8List imageBytes,
    required String mimeType,
    required String apiKey,
  }) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final payload = {
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': _ocrPrompt,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:$mimeType;base64,${base64Encode(imageBytes)}',
              },
            },
          ],
        }
      ],
      'max_tokens': 1000,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'OpenAI OCR failed (${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = body['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('OpenAI OCR response format error: no choices found');
    }

    final message = choices[0]['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;

    return content?.trim() ?? '';
  }

  /// Runs OpenAI Responses API OCR (gpt-4.1-mini).
  static Future<String> runOpenAiResponsesOcr({
    required Uint8List imageBytes,
    required String mimeType,
    String? apiKey,
  }) async {
    final service =
        OpenAiOcrService(apiKey: apiKey ?? EnvironmentConfig.openaiApiKey);
    return service.runOcr(imageBytes: imageBytes, mimeType: mimeType);
  }

  /// Auto-select OCR provider based on available keys.
  static Future<String> runOcrAuto({
    required Uint8List imageBytes,
    required String mimeType,
    required String? openAiKey,
    YoutubeOcrProviderMode mode = YoutubeOcrProviderMode.responsesApi,
  }) async {
    final resolvedKey = (openAiKey != null && openAiKey.isNotEmpty)
        ? openAiKey
        : EnvironmentConfig.openaiApiKey;

    if (mode == YoutubeOcrProviderMode.responsesApi && resolvedKey.isNotEmpty) {
      return runOpenAiResponsesOcr(
        imageBytes: imageBytes,
        mimeType: mimeType,
        apiKey: resolvedKey,
      );
    }

    if (resolvedKey.isNotEmpty) {
      return runOpenAiLegacyOcr(
        imageBytes: imageBytes,
        mimeType: mimeType,
        apiKey: resolvedKey,
      );
    }

    throw Exception('No OCR API key provided');
  }

  /// Enriches a video with a YouTube URL via OpenAI (best effort, no web search tools).
  static Future<EnrichedLinkResult?> enrichVideoLinkOpenAi({
    required String title,
    required String channel,
    required String apiKey,
  }) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final prompt =
        'Find the exact YouTube video URL for the video titled "$title" from the YouTube channel "$channel". '
        'Respond on one line: URL: <url or null> | SCORE: <0-1> | REASON: <short>';

    final payload = {
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt}
          ],
        }
      ],
      'temperature': 0.1,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'OpenAI link enrichment failed (${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = body['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return null;

    final message = choices[0]['message'] as Map<String, dynamic>?;
    final text = (message?['content'] as String?)?.trim();

    if (text == null) return null;

    if (text.startsWith('URL: null')) {
      return const EnrichedLinkResult(
        url: null,
        score: 0,
        reason: 'No confident match found by the model.',
      );
    }

    final urlMatch =
        RegExp(r'URL:\s*(https:\/\/www\.youtube\.com\/watch\?v=[\w\-]+)')
            .firstMatch(text);
    final scoreMatch = RegExp(r'SCORE:\s*([\d\.]+)').firstMatch(text);
    final reasonMatch = RegExp(r'REASON:\s*(.*)').firstMatch(text);

    final url = urlMatch?.group(1);
    final score =
        scoreMatch != null ? double.tryParse(scoreMatch.group(1)!) : null;
    final reason = reasonMatch?.group(1)?.trim() ?? 'No reason provided.';

    return EnrichedLinkResult(
      url: url,
      score: score,
      reason: url == null ? 'Failed to parse response: $text' : reason,
    );
  }

  static Future<EnrichedLinkResult> enrichVideoLinkYoutubeApi({
    required String title,
    required String channel,
  }) async {
    return _youtubeApiEnricher.findBestMatch(title: title, channel: channel);
  }

  /// Auto-select link enrichment provider based on available keys.
  static Future<EnrichedLinkResult?> enrichVideoLinkAuto({
    required String title,
    required String channel,
    required String? openAiKey,
  }) async {
    if (EnvironmentConfig.youtubeApiKey.isNotEmpty) {
      return enrichVideoLinkYoutubeApi(
        title: title,
        channel: channel,
      );
    }

    if (openAiKey != null && openAiKey.isNotEmpty) {
      return enrichVideoLinkOpenAi(
        title: title,
        channel: channel,
        apiKey: openAiKey,
      );
    }
    throw Exception('No API key provided for link enrichment');
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
