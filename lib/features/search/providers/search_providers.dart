import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starlist_app/core/telemetry/search_telemetry.dart';
import 'package:starlist_app/core/telemetry/prod_search_telemetry.dart';
import 'package:starlist_app/features/search/data/search_repository.dart';
import 'package:starlist_app/src/config/providers.dart' as core_providers;
import 'package:starlist_app/src/core/config/feature_flags.dart';

/// Provides the backing repository for search queries.
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final client = ref.read(core_providers.supabaseClientProvider);
  return SupabaseSearchRepository(client);
});

/// Telemetry provider that can be overridden with a real analytics implementation.
final searchTelemetryProvider = Provider<SearchTelemetry>((ref) {
  if (FeatureFlags.enableProdTelemetry) {
    return ProdSearchTelemetry();
  }
  return const NoopSearchTelemetry();
});

/// Feature flag toggle for mixing tag-only results.
final enableTagOnlySearchProvider = Provider<bool>((ref) {
  return FeatureFlags.enableTagOnlySearch;
});
