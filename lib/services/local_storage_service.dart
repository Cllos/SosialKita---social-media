import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// LocalStorageService — Layanan singleton untuk menyimpan dan memuat
/// data aplikasi secara lokal menggunakan SharedPreferences.
///
/// Strategi penyimpanan:
/// - Likes: Map<postId, List<userId>> → disimpan sebagai JSON string
/// - Saved Posts: Map<userId, List<postId>> → disimpan sebagai JSON string
/// - Following: Map<userId, List<userId>> → disimpan sebagai JSON string
/// - Followers: Map<userId, List<userId>> → disimpan sebagai JSON string
/// - Comments baru: List<Map> → disimpan sebagai JSON string
/// - Posts baru: List<Map> → disimpan sebagai JSON string
/// - Stories baru: List<Map> → disimpan sebagai JSON string
/// - Session: String (userId user yang login)
/// - Profile updates: Map<userId, Map> → bio, avatarUrl, displayName
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static SharedPreferences? _prefs;

  // ── Storage Keys ──
  static const _kLikes = 'sk_post_likes';
  static const _kSavedPosts = 'sk_saved_posts';
  static const _kFollowing = 'sk_following';
  static const _kFollowers = 'sk_followers';
  static const _kNewComments = 'sk_new_comments';
  static const _kNewPosts = 'sk_new_posts';
  static const _kDeletedPostIds = 'sk_deleted_post_ids';
  static const _kNewStories = 'sk_new_stories';
  static const _kSession = 'sk_session_uid';
  static const _kToken = 'sk_auth_token';
  static const _kProfiles = 'sk_profiles';

  /// Inisialisasi SharedPreferences — wajib dipanggil di main() sebelum runApp()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'LocalStorageService.init() belum dipanggil!');
    return _prefs!;
  }

  // ══════════════════════════════════════════
  //  SESSION & TOKEN
  // ══════════════════════════════════════════

  String? getSession() => _p.getString(_kSession);

  Future<void> saveSession(String userId) => _p.setString(_kSession, userId);

  Future<void> clearSession() => _p.remove(_kSession);

  String? getToken() => _p.getString(_kToken);

  Future<void> saveToken(String token) => _p.setString(_kToken, token);

  Future<void> clearToken() => _p.remove(_kToken);

  // ══════════════════════════════════════════
  //  LIKES — Map<postId, List<userId>>
  // ══════════════════════════════════════════

  Map<String, List<String>> loadLikes() {
    final raw = _p.getString(_kLikes);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveLikes(Map<String, List<String>> likes) =>
      _p.setString(_kLikes, jsonEncode(likes));

  // ══════════════════════════════════════════
  //  SAVED POSTS — Map<userId, List<postId>>
  // ══════════════════════════════════════════

  Map<String, List<String>> loadSavedPosts() {
    final raw = _p.getString(_kSavedPosts);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveSavedPosts(Map<String, List<String>> savedPosts) =>
      _p.setString(_kSavedPosts, jsonEncode(savedPosts));

  // ══════════════════════════════════════════
  //  FOLLOWING — Map<userId, List<userId>>
  // ══════════════════════════════════════════

  Map<String, List<String>> loadFollowing() {
    final raw = _p.getString(_kFollowing);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveFollowing(Map<String, List<String>> following) =>
      _p.setString(_kFollowing, jsonEncode(following));

  // ══════════════════════════════════════════
  //  FOLLOWERS — Map<userId, List<userId>>
  // ══════════════════════════════════════════

  Map<String, List<String>> loadFollowers() {
    final raw = _p.getString(_kFollowers);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveFollowers(Map<String, List<String>> followers) =>
      _p.setString(_kFollowers, jsonEncode(followers));

  // ══════════════════════════════════════════
  //  NEW COMMENTS — List<Map>
  // ══════════════════════════════════════════

  List<Map<String, dynamic>> loadNewComments() {
    final raw = _p.getString(_kNewComments);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNewComments(List<Map<String, dynamic>> comments) =>
      _p.setString(_kNewComments, jsonEncode(comments));

  // ══════════════════════════════════════════
  //  NEW POSTS — List<Map>
  // ══════════════════════════════════════════

  List<Map<String, dynamic>> loadNewPosts() {
    final raw = _p.getString(_kNewPosts);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNewPosts(List<Map<String, dynamic>> posts) =>
      _p.setString(_kNewPosts, jsonEncode(posts));

  // ══════════════════════════════════════════
  //  DELETED POST IDs — List<String>
  // ══════════════════════════════════════════

  List<String> loadDeletedPostIds() {
    return _p.getStringList(_kDeletedPostIds) ?? [];
  }

  Future<void> saveDeletedPostIds(List<String> ids) =>
      _p.setStringList(_kDeletedPostIds, ids);

  // ══════════════════════════════════════════
  //  NEW STORIES — List<Map>
  // ══════════════════════════════════════════

  List<Map<String, dynamic>> loadNewStories() {
    final raw = _p.getString(_kNewStories);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNewStories(List<Map<String, dynamic>> stories) =>
      _p.setString(_kNewStories, jsonEncode(stories));

  // ══════════════════════════════════════════
  //  PROFILE UPDATES — Map<userId, Map>
  // ══════════════════════════════════════════

  Map<String, Map<String, dynamic>> loadProfiles() {
    final raw = _p.getString(_kProfiles);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveProfile(String userId, Map<String, dynamic> profileData) async {
    final profiles = loadProfiles();
    profiles[userId] = profileData;
    await _p.setString(_kProfiles, jsonEncode(profiles));
  }

  // ══════════════════════════════════════════
  //  CONVERSATIONS — List<Map>
  // ══════════════════════════════════════════

  List<Map<String, dynamic>> loadConversations() {
    final raw = _p.getString('sk_conversations');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveConversations(List<Map<String, dynamic>> conversations) =>
      _p.setString('sk_conversations', jsonEncode(conversations));

  /// Reset seluruh data (berguna untuk testing)
  Future<void> clearAll() => _p.clear();
}
