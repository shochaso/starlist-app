enum ContentTypeModel {
  video,
  image,
  text,
  link,
}

class ContentModel {
  final String id;
  final String title;
  final String description;
  final ContentTypeModel type;
  final String url;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final bool isPublished;
  final int likes;
  final int comments;
  final int shares;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
    this.isPublished = true,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json["id"] as String,
      title: json["title"] as String,
      description: json["description"] as String,
      type: ContentTypeModel.values.firstWhere(
        (e) => e.toString() == "ContentTypeModel.${json["type"]}",
        orElse: () => ContentTypeModel.text,
      ),
      url: json["url"] as String,
      authorId: json["authorId"] as String,
      authorName: json["authorName"] as String,
      createdAt: DateTime.parse(json["createdAt"] as String),
      updatedAt: DateTime.parse(json["updatedAt"] as String),
      metadata: json["metadata"] as Map<String, dynamic>,
      isPublished: json["isPublished"] as bool? ?? true,
      likes: json["likes"] as int? ?? 0,
      comments: json["comments"] as int? ?? 0,
      shares: json["shares"] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "type": type.toString().split(".").last,
      "url": url,
      "authorId": authorId,
      "authorName": authorName,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "metadata": metadata,
      "isPublished": isPublished,
      "likes": likes,
      "comments": comments,
      "shares": shares,
    };
  }
}
