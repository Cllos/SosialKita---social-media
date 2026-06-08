/// Model data Story SosialKita
class StoryModel {
  final String id;
  final String userId;
  final String mediaUrl;
  final DateTime createdAt;
  final List<String> viewerIds; // list of user IDs who viewed this story

  StoryModel({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.createdAt,
    List<String>? viewerIds,
  }) : viewerIds = viewerIds ?? [];
}
