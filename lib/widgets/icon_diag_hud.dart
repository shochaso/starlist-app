import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/debug_flags.dart';
import '../services/service_icon/service_icon_cache.dart';
import '../services/service_icon/service_icon_registry.dart';

class IconDiagEvent {
  const IconDiagEvent({
    required this.key,
    required this.origin,
    required this.source,
    required this.duration,
    this.cacheHit = false,
    this.fallback = false,
  });

  final String key;
  final String origin;
  final ServiceIconSourceType source;
  final Duration duration;
  final bool cacheHit;
  final bool fallback;
}

class _DiagState {
  _DiagState({
    this.calls = 0,
    this.fallbacks = 0,
    this.lastEvent,
  });

  final int calls;
  final int fallbacks;
  final IconDiagEvent? lastEvent;

  _DiagState copyWith({
    int? calls,
    int? fallbacks,
    IconDiagEvent? lastEvent,
  }) =>
      _DiagState(
        calls: calls ?? this.calls,
        fallbacks: fallbacks ?? this.fallbacks,
        lastEvent: lastEvent ?? this.lastEvent,
      );
}

final ValueNotifier<_DiagState> _diagState =
    ValueNotifier<_DiagState>(_DiagState());

void recordIconDiag(IconDiagEvent event) {
  if (!kDebugMode) {
    return;
  }
  final current = _diagState.value;
  _diagState.value = current.copyWith(
    calls: current.calls + 1,
    fallbacks: current.fallbacks + (event.fallback ? 1 : 0),
    lastEvent: event,
  );
}

void resetIconDiag() {
  if (!kDebugMode) {
    return;
  }
  _diagState.value = _DiagState();
}

class IconDiagHUD extends StatelessWidget {
  const IconDiagHUD({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !DebugFlags.instance.iconDiagnostics) {
      return const SizedBox.shrink();
    }
    return Positioned(
      right: 12,
      top: 12,
      child: ValueListenableBuilder<_DiagState>(
        valueListenable: _diagState,
        builder: (_, state, __) {
          final event = state.lastEvent;
          final hasFallback = state.fallbacks > 0;
          final textTheme = Theme.of(context).textTheme;
          return Material(
            elevation: 6,
            color: Colors.transparent,
            child: Container(
              width: 260,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (hasFallback ? Colors.redAccent : Colors.black87)
                    .withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DefaultTextStyle(
                style: textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontFamily: 'RobotoMono',
                      fontSize: 11,
                    ) ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontFamily: 'RobotoMono',
                    ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IconDiag HUD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    _buildLine('calls', '${state.calls}'),
                    _buildLine('fallbacks', '${state.fallbacks}'),
                    if (event != null) ...[
                      const SizedBox(height: 6),
                      _buildLine('key', event.key),
                      _buildLine(
                        'source',
                        '${event.source.name}${event.cacheHit ? " (cache)" : ""}',
                      ),
                      _buildLine(
                        'duration',
                        '${event.duration.inMilliseconds} ms',
                      ),
                      _buildLine('origin', event.origin),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _DiagActionButton(
                          label: 'Clear Icon Cache',
                          onPressed: () {
                            ServiceIconCache.clear();
                            resetIconDiag();
                          },
                        ),
                        _DiagActionButton(
                          label: 'Clear Image Cache',
                          onPressed: () {
                            PaintingBinding.instance.imageCache.clear();
                            PaintingBinding.instance.imageCache
                                .clearLiveImages();
                          },
                        ),
                        _DiagActionButton(
                          label: 'Reload Icons',
                          onPressed: () {
                            ServiceIconRegistry.instance.clear();
                            ServiceIconCache.clear();
                            PaintingBinding.instance.imageCache.clear();
                            PaintingBinding.instance.imageCache
                                .clearLiveImages();
                            resetIconDiag();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLine(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        child: Text('$label: $value', overflow: TextOverflow.ellipsis),
      );
}

class _DiagActionButton extends StatefulWidget {
  const _DiagActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_DiagActionButton> createState() => _DiagActionButtonState();
}

class _DiagActionButtonState extends State<_DiagActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _hovering
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
