import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../config/environment_config.dart';

class OpenAiOcrService {
  OpenAiOcrService({
    http.Client? httpClient,
    String? apiKey,
  })  : _client = httpClient ?? http.Client(),
        _apiKey = apiKey ?? EnvironmentConfig.openaiApiKey;

  final http.Client _client;
  final String _apiKey;

  static const _endpoint = 'https://api.openai.com/v1/responses';
  static const _model = 'gpt-4.1-mini';

  Future<String> runOcr({
    required Uint8List imageBytes,
    required String mimeType,
    String prompt =
        'This is a screenshot of a YouTube watch history. Extract the video titles and their corresponding channel names. Each video entry might span one or two lines. Format the output as one line per video, with title and channel separated by " - ". IMPORTANT: Do not include any introductory text, headers, explanations, or markdown formatting like asterisks. Only return the raw list of videos.',
  }) async {
    if (_apiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY is not configured.');
    }

    final imageData = base64Encode(imageBytes);
    final body = jsonEncode({
      'model': _model,
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text': prompt,
            },
            {
              'type': 'input_image',
              'image_url': 'data:$mimeType;base64,$imageData',
            }
          ],
        }
      ],
      'max_output_tokens': 1200,
    });

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'OpenAI OCR failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final output = decoded['output'] as List<dynamic>?;
    if (output == null || output.isEmpty) {
      throw Exception('OpenAI OCR response missing output payload.');
    }

    final first = output.first as Map<String, dynamic>;
    if (first['content'] is List) {
      final content = first['content'] as List<dynamic>;
      final textPart = content.firstWhere(
        (item) =>
            item is Map<String, dynamic> &&
            item['type'] == 'output_text' &&
            item['text'] is String,
        orElse: () => {'text': ''},
      ) as Map<String, dynamic>;
      return (textPart['text'] as String?)?.trim() ?? '';
    }

    if (first['text'] is String) {
      return (first['text'] as String).trim();
    }

    return '';
  }
}
