import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class _DiagState {
  int calls = 0;
  int fallbacks = 0;
  String lastKey = '';
  String lastPath = '';

  _DiagState copy() {
    final next = _DiagState()
      ..calls = calls
      ..fallbacks = fallbacks
      ..lastKey = lastKey
      ..lastPath = lastPath;
    return next;
  }
}

final ValueNotifier<_DiagState> _diagState = ValueNotifier<_DiagState>(_DiagState());

void diagTouch({String? key, String? path, bool fallback = false, bool incrementCall = true}) {
  if (!kDebugMode) {
    return;
  }
  final current = _diagState.value;
  if (incrementCall) {
    current.calls++;
  }
  if (fallback) {
    current.fallbacks++;
  }
  if (key != null && key.isNotEmpty) {
    current.lastKey = key;
  }
  if (path != null && path.isNotEmpty) {
    current.lastPath = path;
  }
  _diagState.value = current.copy();
}

class IconDiagHUD extends StatelessWidget {
  const IconDiagHUD({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    return Positioned(
      right: 12,
      bottom: 12,
      child: ValueListenableBuilder<_DiagState>(
        valueListenable: _diagState,
        builder: (_, state, __) {
          final hasFallback = state.fallbacks > 0;
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (hasFallback ? Colors.redAccent : Colors.black87)
                  .withOpacity(0.82),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white, fontSize: 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('ICON DIAG'),
                  Text('calls: ${state.calls} fb: ${state.fallbacks}'),
                  Text('lastKey: ${state.lastKey}'),
                  Text('lastPath: ${state.lastPath}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
