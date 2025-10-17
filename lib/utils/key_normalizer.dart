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
  'shein_fashion': 'shein',
  'she_in': 'shein',
  'sheinjp': 'shein',
  'shein_jp': 'shein',
  'シーイン': 'shein',
  'ubereats': 'uber_eats',
  'uber_eats': 'uber_eats',
  'uber_eats_jp': 'uber_eats',
  'ウーバーイーツ': 'uber_eats',
};

String resolveAlias(String key) => kServiceAliases[key] ?? key;
