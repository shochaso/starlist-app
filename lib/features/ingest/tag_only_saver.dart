/// Payload metadata for tag-only ingests.
class TagPayload {
  const TagPayload({
    required this.sourceId,
    required this.tagHash,
    this.category,
    required this.payloadJson,
  });

  final String sourceId;
  final String tagHash;
  final String? category;
  final Map<String, dynamic> payloadJson;
}

/// Abstraction that persists tag-only payloads.
abstract class TagOnlyRepository {
  Future<void> insertTagOnly(TagPayload payload, {required String userId});
}

/// Handles persistence guard rails for tag-only data sets.
class TagOnlySaver {
  const TagOnlySaver(this._repository);

  final TagOnlyRepository _repository;

  /// Saves non-game payloads; idempotency is enforced via DB UNIQUE constraints.
  Future<void> saveTagOnly(TagPayload payload, {required String userId}) async {
    // DoD: ignore game purchase payloads entirely.
    if (payload.category == 'game') return;

    await _repository.insertTagOnly(payload, userId: userId);
  }
}
