/// Model postingan SosialKita
class PostModel {
  final String id;
  final String userId;
  final String imageUrl; // network dummy image URL
  final String caption;
  final List<String> likes; // list of user IDs
  final List<String> tags; // hashtags
  final String location;
  final DateTime createdAt;
  final List<String> reports; // list of user IDs who reported this post

  PostModel({
    required this.id,
    required this.userId,
    this.imageUrl = '',
    this.caption = '',
    List<String>? likes,
    List<String>? tags,
    this.location = '',
    DateTime? createdAt,
    List<String>? reports,
  })  : likes = likes ?? [],
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        reports = reports ?? [];

  PostModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? caption,
    List<String>? likes,
    List<String>? tags,
    String? location,
    DateTime? createdAt,
    List<String>? reports,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      likes: likes ?? List.from(this.likes),
      tags: tags ?? List.from(this.tags),
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      reports: reports ?? List.from(this.reports),
    );
  }
}

