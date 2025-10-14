import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'import_diagnose_repository.dart';
import 'models.dart';

class ImportDiagnoseScreen extends ConsumerWidget {
  const ImportDiagnoseScreen({super.key, this.jobId});

  final String? jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(importDiagnoseProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('データ取込み診断'),
        elevation: 0,
      ),
      body: SafeArea(
        child: stateAsync.when(
          data: (state) => _DiagnoseBody(state: state, jobId: jobId),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message:
                '診断データの取得に失敗しました\n${_diagnoseReadableError(error)}',
          ),
        ),
      ),
    );
  }
}

class _DiagnoseBody extends ConsumerWidget {
  const _DiagnoseBody({required this.state, required this.jobId});

  final ImportDiagnoseState state;
  final String? jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confidence = state.confidence;
    final confidenceColor = confidence >= 0.8
        ? Colors.green
        : confidence >= 0.6
            ? Colors.orange
            : Colors.red;

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bubble_chart, color: confidenceColor),
                        const SizedBox(width: 6),
                        Text('精度 ${(confidence * 100).toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    avatar: const Icon(Icons.memory, size: 18),
                    label: Text('enrich命中 ${state.enrichHits}件'),
                  ),
                  const Spacer(),
                  Text(
                    state.lastAnalyzed != null
                        ? '最終解析: ${_formatDt(state.lastAnalyzed!)}'
                        : '未解析',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: _ImagePane(imageUrl: state.originalImageUrl)),
                    const SizedBox(width: 16),
                    Expanded(child: _OcrPane(text: state.ocrText)),
                  ],
                ),
              ),
            ),
            _ActionBar(jobId: jobId),
          ],
        ),
        if (state.alertMessage != null && state.alertMessage!.isNotEmpty)
          Positioned(
            top: 12,
            right: 16,
            child: _AlertBanner(message: state.alertMessage!),
          ),
      ],
    );
  }
}

class _ImagePane extends StatelessWidget {
  const _ImagePane({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.photo_outlined),
                const SizedBox(width: 8),
                Text('原本画像',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.zoom_in_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 3.5,
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.contain)
                    : Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Text('画像がありません'),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OcrPane extends StatefulWidget {
  const _OcrPane({required this.text});

  final String text;

  @override
  State<_OcrPane> createState() => _OcrPaneState();
}

class _OcrPaneState extends State<_OcrPane> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.text_snippet_outlined),
                const SizedBox(width: 8),
                Text('OCRテキスト結果',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _controller.text = widget.text),
                  icon: const Icon(Icons.refresh),
                  label: const Text('リセット'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _controller,
                expands: true,
                maxLines: null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends ConsumerStatefulWidget {
  const _ActionBar({required this.jobId});

  final String? jobId;

  @override
  ConsumerState<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends ConsumerState<_ActionBar> {
  bool _retryingOcr = false;
  bool _retryingEnrich = false;

  Future<void> _handleRetryOcr(BuildContext context) async {
    if (widget.jobId == null) return;
    setState(() => _retryingOcr = true);
    final repo = ref.read(importDiagnoseRepositoryProvider);
    try {
      await repo.retryOcr(widget.jobId!);
      await ref.refresh(importDiagnoseProvider(widget.jobId).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OCRを再解析しました')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('再解析に失敗しました: ${_diagnoseReadableError(error)}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _retryingOcr = false);
    }
  }

  Future<void> _handleRetryEnrich(BuildContext context) async {
    if (widget.jobId == null) return;
    setState(() => _retryingEnrich = true);
    final repo = ref.read(importDiagnoseRepositoryProvider);
    try {
      await repo.retryEnrich(widget.jobId!);
      await ref.refresh(importDiagnoseProvider(widget.jobId).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('商品情報の再取得を開始しました')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '商品情報の再取得に失敗しました: ${_diagnoseReadableError(error)}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _retryingEnrich = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _retryingOcr || _retryingEnrich;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              FilledButton(
                onPressed: widget.jobId == null || _retryingOcr
                    ? null
                    : () => _handleRetryOcr(context),
                child: const Text('再解析する'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: widget.jobId == null || _retryingEnrich
                    ? null
                    : () => _handleRetryEnrich(context),
                child: const Text('商品情報を再取得'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('完了'),
              ),
            ],
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.05),
                alignment: Alignment.center,
                child: const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      constraints: const BoxConstraints(maxWidth: 320),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.redAccent.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration(BuildContext context) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Theme.of(context).colorScheme.surface,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

String _formatDt(DateTime dt) {
  return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String _diagnoseReadableError(Object error) {
  if (error is ImportDiagnoseApiException) {
    return '${error.message} (code: ${error.statusCode})';
  }
  return error.toString();
}
