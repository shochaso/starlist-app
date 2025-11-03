/// Represents a failure while fetching remote or cached data.
class DataFetchException implements Exception {
  const DataFetchException(
    this.message, {
    this.cause,
    this.stackTrace,
  });

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => 'DataFetchException: $message';
}
