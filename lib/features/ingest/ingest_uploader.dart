import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IngestUploader extends StatefulWidget {
  const IngestUploader(
      {super.key, required this.baseUrl, required this.userId});

  final String baseUrl;
  final String userId;

  @override
  State<IngestUploader> createState() => _IngestUploaderState();
}

class _IngestUploaderState extends State<IngestUploader> {
  final _logs = <String>[];
  Timer? _poll;
  String? _jobId;
  String? _previewUrl;
  String? _storageKey;

  void _log(String message) {
    setState(() {
      _logs.add(message);
    });
  }

  Future<void> _pickAndUpload() async {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = false;
    input.click();
    await input.onChange.first;
    final files = input.files;
    if (files == null || files.isEmpty) return;

    final file = files.first;
    final form = html.FormData()
      ..append('userId', widget.userId)
      ..appendBlob('file', file, file.name);

    final req = html.HttpRequest()
      ..open('POST', '${widget.baseUrl}/ingest/upload')
      ..responseType = 'json';

    final completer = Completer<void>();
    req.onLoad.listen((_) => completer.complete());
    req.onError.listen((_) => completer.completeError('upload failed'));
    req.send(form);
    await completer.future;

    final resp = req.response as dynamic;
    final jobId = (resp?['jobId'] ?? '') as String;
    if (jobId.isEmpty) {
      _log('upload failed: no jobId');
      return;
    }

    _log('uploaded: ${file.name} → jobId=$jobId');
    setState(() {
      _jobId = jobId;
      _previewUrl = null;
      _storageKey = null;
    });
    _startPolling(jobId);
  }

  void _startPolling(String jobId) {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final res =
            await http.get(Uri.parse('${widget.baseUrl}/ingest/$jobId/status'));
        if (res.statusCode != 200) {
          _log('status error: ${res.statusCode}');
          return;
        }
        final body = res.body;
        final data = jsonDecode(body);
        if (data is! List) {
          _log('status: $body');
          return;
        }

        String? signedUrl;
        for (final entry in data) {
          if (entry is! Map) continue;
          final name = entry['name'] as String?;
          final progress = entry['progress'];
          if (_storageKey == null &&
              progress is Map &&
              progress['fileKey'] is String) {
            _storageKey = progress['fileKey'] as String;
          }
          if (name == 'enrich:search') {
            if (entry['url'] is String) {
              signedUrl = entry['url'] as String;
            } else if (progress is Map && progress['url'] is String) {
              signedUrl = progress['url'] as String;
            }
          }
        }

        if (signedUrl != null) {
          _log('preview url ready');
          setState(() => _previewUrl = signedUrl);
          _poll?.cancel();
        } else {
          _log('status: $body');
        }
      } catch (e) {
        _log('poll error: $e');
      }
    });
  }

  Future<void> _refreshSignedUrl() async {
    final key = _storageKey;
    if (key == null) return;
    try {
      final res = await http
          .get(Uri.parse('${widget.baseUrl}/media/signed-url?key=$key'));
      if (res.statusCode != 200) {
        _log('refresh failed: ${res.statusCode}');
        return;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final url = data['signedUrl'] as String?;
      if (url != null) {
        setState(() => _previewUrl = url);
      }
    } catch (e) {
      _log('refresh error: $e');
    }
  }

  Widget _preview() {
    if (_previewUrl == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('プレビュー'),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            _previewUrl!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              _refreshSignedUrl();
              return const Center(child: Text('プレビュー再取得中...'));
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton(
          onPressed: _pickAndUpload,
          child: const Text('画像を選んで取り込み'),
        ),
        const SizedBox(height: 12),
        Text('最新 jobId: ${_jobId ?? '-'}'),
        const SizedBox(height: 12),
        _preview(),
        const SizedBox(height: 12),
        Container(
          height: 160,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView(
            children: _logs
                .map((e) => Text(e, style: const TextStyle(fontSize: 12)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
