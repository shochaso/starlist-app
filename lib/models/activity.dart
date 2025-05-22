class Activity {
  final String id;
  final String starId;
  final String type;
  final String title;
  final String content;
  final DateTime timestamp;
  final String imageUrl;
  final double? price;

  Activity({
    required this.id,
    required this.starId,
    required this.type,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.imageUrl,
    this.price,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      starId: json['star_id'],
      type: json['type'],
      title: json['title'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['image_url'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'star_id': starId,
      'type': type,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      'price': price,
    };
  }
} 