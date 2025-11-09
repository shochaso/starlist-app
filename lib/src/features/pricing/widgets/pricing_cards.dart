// Status:: in-progress
// Source-of-Truth:: lib/src/features/pricing/widgets/pricing_cards.dart
// Spec-State:: 確定済み（価格カードUI）
// Last-Updated:: 2025-11-08

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pricing_repository.dart';
import '../domain/pricing_validator.dart';

/// 価格カードウィジェット
class TierCard extends ConsumerStatefulWidget {
  final String title; // "Light" / "Standard" / "Premium"
  final String tier; // "light" / "standard" / "premium"
  final bool isAdult;
  final ValueChanged<int> onChanged;

  const TierCard({
    super.key,
    required this.title,
    required this.tier,
    required this.isAdult,
    required this.onChanged,
  });

  @override
  ConsumerState<TierCard> createState() => _TierCardState();
}

class _TierCardState extends ConsumerState<TierCard> {
  late final TextEditingController _controller;
  String? _errorMessage;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(pricingConfigProvider);

    return configAsync.when(
      data: (config) {
        final recommended = recommendedFor(
          config,
          tier: widget.tier,
          isAdult: widget.isAdult,
        );
        final limits = limitsFromConfig(config, isAdult: widget.isAdult);

        // 初期値設定（初回のみ）
        if (!_initialized) {
          _controller.text = recommended.toString();
          _initialized = true;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 12),
                    Chip(
                      label: Text('推奨 ¥$recommended'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '税込・${limits.step}円刻み / ${limits.min}〜${limits.max}円',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '¥',
                    hintText: '金額を入力',
                    errorText: _errorMessage,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (s) {
                    final v = int.tryParse(s) ?? 0;
                    final msg = validatePrice(value: v, limits: limits);

                    setState(() {
                      _errorMessage = msg;
                    });

                    if (msg == null) {
                      widget.onChanged(v);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('エラー: $error'),
        ),
      ),
    );
  }
}


// Spec-State:: 確定済み（価格カードUI）
// Last-Updated:: 2025-11-08

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pricing_repository.dart';
import '../domain/pricing_validator.dart';

/// 価格カードウィジェット
class TierCard extends ConsumerStatefulWidget {
  final String title; // "Light" / "Standard" / "Premium"
  final String tier; // "light" / "standard" / "premium"
  final bool isAdult;
  final ValueChanged<int> onChanged;

  const TierCard({
    super.key,
    required this.title,
    required this.tier,
    required this.isAdult,
    required this.onChanged,
  });

  @override
  ConsumerState<TierCard> createState() => _TierCardState();
}

class _TierCardState extends ConsumerState<TierCard> {
  late final TextEditingController _controller;
  String? _errorMessage;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(pricingConfigProvider);

    return configAsync.when(
      data: (config) {
        final recommended = recommendedFor(
          config,
          tier: widget.tier,
          isAdult: widget.isAdult,
        );
        final limits = limitsFromConfig(config, isAdult: widget.isAdult);

        // 初期値設定（初回のみ）
        if (!_initialized) {
          _controller.text = recommended.toString();
          _initialized = true;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 12),
                    Chip(
                      label: Text('推奨 ¥$recommended'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '税込・${limits.step}円刻み / ${limits.min}〜${limits.max}円',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '¥',
                    hintText: '金額を入力',
                    errorText: _errorMessage,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (s) {
                    final v = int.tryParse(s) ?? 0;
                    final msg = validatePrice(value: v, limits: limits);

                    setState(() {
                      _errorMessage = msg;
                    });

                    if (msg == null) {
                      widget.onChanged(v);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('エラー: $error'),
        ),
      ),
    );
  }
}

