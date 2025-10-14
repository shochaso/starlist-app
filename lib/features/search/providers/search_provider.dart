import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/search_repository.dart';
import '../support_matrix.dart';
import 'search_providers.dart';

final searchControllerProvider =
    AutoDisposeAsyncNotifierProvider<SearchController, SearchState>(
  SearchController.new,
);

class SearchState {
  const SearchState._({
    required this.items,
    required this.mode,
  });

  const SearchState.initial()
      : this._(items: const <SearchItem>[], mode: kSearchDefaultMode);

  const SearchState.done({required List<SearchItem> items, required String mode})
      : this._(items: items, mode: mode);

  final List<SearchItem> items;
  final String mode;
}

class SearchController extends AutoDisposeAsyncNotifier<SearchState> {
  late final SearchRepository _repo;

  @override
  FutureOr<SearchState> build() {
    _repo = ref.read(searchRepositoryProvider);
    return const SearchState.initial();
  }

  /// Executes a search, mixing tag-only results when toggled and flag-enabled.
  Future<void> runSearch({String? query, bool includeTagOnly = false}) async {
    final allowTagOnly =
        ref.read(enableTagOnlySearchProvider) && includeTagOnly;
    final telemetry = ref.read(searchTelemetryProvider);

    state = const AsyncLoading();
    final stopwatch = Stopwatch()..start();

    try {
      final results = <SearchItem>[];
      final full = await _repo.search(query: query, mode: kSearchDefaultMode);
      results.addAll(full);

      if (allowTagOnly) {
        final tagOnly = await _repo.search(query: query, mode: 'tag_only');
        final seen = <String>{for (final item in results) item.id};
        var removed = 0;
        for (final item in tagOnly) {
          if (seen.add(item.id)) {
            results.add(item);
          } else {
            removed++;
          }
        }
        if (removed > 0) {
          telemetry.tagOnlyDedupHit(removed);
        }
      }

      stopwatch.stop();
      if (stopwatch.elapsedMilliseconds > 1500) {
        telemetry.searchSlaMissed(stopwatch.elapsedMilliseconds);
      }

      state = AsyncData(
        SearchState.done(
          items: results,
          mode: allowTagOnly ? 'mixed' : kSearchDefaultMode,
        ),
      );
    } catch (error, stackTrace) {
      stopwatch.stop();
      state = AsyncError(error, stackTrace);
    }
  }
}
