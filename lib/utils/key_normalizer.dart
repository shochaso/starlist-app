String normalizeKey(String raw) => raw
    .trim()
    .toLowerCase()
    .replaceFirst(RegExp(r'^key[-_]+'), '')
    .replaceAll(RegExp(r'[\s-]+'), '_');

const Map<String, String> kServiceAliases = {
  'prime_video': 'amazon_prime_video',
  'amazon_prime': 'amazon_prime_video',
  'amazon_prime_video': 'amazon_prime_video',
  'unext': 'u_next',
  'u_next': 'u_next',
  'u-next': 'u_next',
  'u_next_video': 'u_next',
}; 

String resolveAlias(String key) => kServiceAliases[key] ?? key;
