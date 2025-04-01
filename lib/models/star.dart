class Star {
  final String id;
  final String name;
  final String category;
  final String rank;
  final int followers;
  final String imageUrl;

  Star({
    required this.id,
    required this.name,
    required this.category,
    required this.rank,
    required this.followers,
    required this.imageUrl,
  });

  factory Star.fromJson(Map<String, dynamic> json) {
    return Star(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      rank: json['rank'],
      followers: json['followers'],
      imageUrl: json['imageUrl'],
    );
  }
} 