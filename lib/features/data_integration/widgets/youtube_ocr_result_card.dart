import 'package:flutter/material.dart';

class YoutubeOcrResultCard extends StatefulWidget {
  const YoutubeOcrResultCard({
    super.key,
    required this.rawText,
    required this.onTextChanged,
    required this.onRunOcr,
    required this.isRunning,
    required this.isImageSelected,
  });

  final String rawText;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onRunOcr;
  final bool isRunning;
  final bool isImageSelected;

  @override
  State<YoutubeOcrResultCard> createState() => _YoutubeOcrResultCardState();
}

class _YoutubeOcrResultCardState extends State<YoutubeOcrResultCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = widget.rawText.isNotEmpty;
    final lines = widget.rawText.isEmpty
        ? 0
        : widget.rawText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _StepBadge(index: 2),
              const SizedBox(width: 12),
              Text(
                'テキスト抽出（OCR）',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '画像を解析して動画タイトルとチャンネル名を抽出します。',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          if (hasText)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF8EC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '解析完了: $lines 行のデータを検出しました',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF207544),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.isRunning || !widget.isImageSelected
                          ? null
                          : widget.onRunOcr,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        backgroundColor: const Color(0xFF4C63F5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: widget.isRunning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(widget.isRunning ? '解析中…' : 'OCRを実行'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RawTextToggle(
                  isExpanded: _isExpanded,
                  hasText: hasText,
                  onToggle: () => setState(() {
                    if (hasText) _isExpanded = !_isExpanded;
                  }),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: TextEditingController(text: widget.rawText),
                      onChanged: widget.onTextChanged,
                      maxLines: 12,
                      minLines: 6,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'OCR結果がここに表示されます',
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF5A6AF0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          '$index',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _RawTextToggle extends StatelessWidget {
  const _RawTextToggle({
    required this.isExpanded,
    required this.hasText,
    required this.onToggle,
  });

  final bool isExpanded;
  final bool hasText;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: hasText ? onToggle : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: const Color(0xFF5A6AF0),
            ),
            const SizedBox(width: 6),
            Text(
              hasText ? '生テキストを${isExpanded ? '隠す' : '確認'}' : 'OCR結果を待機中…',
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF5A6AF0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
