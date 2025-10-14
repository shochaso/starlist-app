/// Telemetry contract for search operations.
abstract class SearchTelemetry {
  void searchSlaMissed(int elapsedMs);
  void tagOnlyDedupHit(int removedCount);
}

/// No-op telemetry implementation used when analytics is not wired.
class NoopSearchTelemetry implements SearchTelemetry {
  const NoopSearchTelemetry();

  @override
  void searchSlaMissed(int elapsedMs) {}

  @override
  void tagOnlyDedupHit(int removedCount) {}
}
