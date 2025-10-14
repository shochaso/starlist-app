import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/core/telemetry/search_telemetry.dart';
import 'package:starlist_app/features/ingest/tag_only_saver.dart';
import 'package:starlist_app/features/search/data/search_repository.dart';
import 'package:starlist_app/features/search/providers/search_provider.dart';
import 'package:starlist_app/features/search/providers/search_providers.dart';

class _FakeSearchRepository implements SearchRepository {
  const _FakeSearchRepository();

  @override
  Future<List<SearchItem>> search({String? query, required String mode}) async {
    if (mode == 'full') {
      return const [
        SearchItem(id: 'a'),
        SearchItem(id: 'b'),
      ];
    }
    return const [
      SearchItem(id: 'b'),
      SearchItem(id: 'c'),
    ];
  }

  @override
  Future<void> insertTagOnly(TagPayload payload, {required String userId}) async {}
}

class _SlowSearchRepository implements SearchRepository {
  const _SlowSearchRepository();

  @override
  Future<List<SearchItem>> search({String? query, required String mode}) async {
    await Future.delayed(const Duration(milliseconds: 1600));
    return const [SearchItem(id: 'slow')];
  }

  @override
  Future<void> insertTagOnly(TagPayload payload, {required String userId}) async {}
}

class _SpyTelemetry extends NoopSearchTelemetry {
  int slaHits = 0;
  int dedupEvents = 0;

  @override
  void searchSlaMissed(int elapsedMs) {
    slaHits++;
  }

  @override
  void tagOnlyDedupHit(int removedCount) {
    dedupEvents += removedCount;
  }
}

void main() {
  test('mixed mode deduplicates tag-only results when flag enabled', () async {
    final telemetry = _SpyTelemetry();
    final container = ProviderContainer(overrides: [
      searchRepositoryProvider.overrideWithValue(const _FakeSearchRepository()),
      searchTelemetryProvider.overrideWithValue(telemetry),
      enableTagOnlySearchProvider.overrideWithValue(true),
    ]);
    addTearDown(container.dispose);

    // Prime the controller.
    container.read(searchControllerProvider);

    await container
        .read(searchControllerProvider.notifier)
        .runSearch(query: 'query', includeTagOnly: true);

    final state = container.read(searchControllerProvider);
    final value = state.requireValue;
    expect(value.mode, 'mixed');
    expect(value.items.map((item) => item.id).toList(), ['a', 'b', 'c']);
    expect(telemetry.dedupEvents, 1);
  });

  test('keeps mode full when feature flag disabled', () async {
    final telemetry = _SpyTelemetry();
    final container = ProviderContainer(overrides: [
      searchRepositoryProvider.overrideWithValue(const _FakeSearchRepository()),
      searchTelemetryProvider.overrideWithValue(telemetry),
      enableTagOnlySearchProvider.overrideWithValue(false),
    ]);
    addTearDown(container.dispose);

    container.read(searchControllerProvider);

    await container
        .read(searchControllerProvider.notifier)
        .runSearch(query: 'query', includeTagOnly: true);

    final state = container.read(searchControllerProvider);
    final value = state.requireValue;
    expect(value.mode, 'full');
    expect(value.items.map((item) => item.id).toList(), ['a', 'b']);
    expect(telemetry.dedupEvents, 0);
  });

  test('emits telemetry when SLA threshold exceeded', () async {
    final telemetry = _SpyTelemetry();
    final container = ProviderContainer(overrides: [
      searchRepositoryProvider.overrideWithValue(const _SlowSearchRepository()),
      searchTelemetryProvider.overrideWithValue(telemetry),
      enableTagOnlySearchProvider.overrideWithValue(false),
    ]);
    addTearDown(container.dispose);

    container.read(searchControllerProvider);

    await container
        .read(searchControllerProvider.notifier)
        .runSearch(query: 'slow', includeTagOnly: false);

    expect(telemetry.slaHits, 1);
  });
}
