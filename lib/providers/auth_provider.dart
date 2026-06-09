import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/utils/dummy_data.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

/// AuthProvider — mengelola state autentikasi dengan API Backend MySQL
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  final _storage = LocalStorageService.instance;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isModerator => _currentUser?.role == 'moderator';

  AuthProvider() {
    _restoreSession();
  }

  /// Coba pulihkan sesi dari storage menggunakan JWT Token
  Future<void> _restoreSession() async {
    final token = _storage.getToken();
    if (token == null) return;

    try {
      final res = await ApiService.get('/auth/me');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          _currentUser = _userFromJson(body['data']);
          _isLoggedIn = true;
          notifyListeners();
        } else {
          await logout();
        }
      } else {
        await logout();
      }
    } catch (e) {
      debugPrint('Restore Session Error: $e');
      // Jangan langsung logout jika karena koneksi offline, agar user tidak terlempar
    }
  }

  /// Login ke Backend
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final token = body['data']['token'] as String;
        final userData = body['data']['user'];

        await _storage.saveToken(token);
        _currentUser = _userFromJson(userData);
        _isLoggedIn = true;
        _isLoading = false;
        
        await _storage.saveSession(_currentUser!.id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Register ke Backend
  Future<bool> register(
    String displayName,
    String username,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.post('/auth/register', {
        'display_name': displayName,
        'username': username,
        'email': email,
        'password': password,
      });

      final body = jsonDecode(res.body);
      if (res.statusCode == 201 && body['success'] == true) {
        final token = body['data']['token'] as String;
        final userData = body['data']['user'];

        await _storage.saveToken(token);
        _currentUser = _userFromJson(userData);
        _isLoggedIn = true;
        _isLoading = false;

        await _storage.saveSession(_currentUser!.id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Logout dari Backend
  Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', null);
    } catch (_) {}
    _currentUser = null;
    _isLoggedIn = false;
    await _storage.clearToken();
    await _storage.clearSession();
    notifyListeners();
  }

  /// Update profil pengguna di Backend (mensupport image upload avatar)
  Future<bool> updateProfile(UserModel updated) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fields = {
        'display_name': updated.displayName,
        'bio': updated.bio,
      };

      final bool shouldUpload = updated.avatarUrl.isNotEmpty &&
          ((kIsWeb && updated.avatarUrl.startsWith('blob:')) ||
           (!kIsWeb && !updated.avatarUrl.startsWith('http') && !updated.avatarUrl.contains('uploads')));

      final res = await ApiService.multipartRequest(
        'PUT',
        '/users/profile',
        fields: fields,
        fileKey: shouldUpload ? 'avatar' : null,
        filePath: shouldUpload ? updated.avatarUrl : null,
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final userData = body['data'];
        _currentUser = _userFromJson(userData);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update Profile Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Toggle simpan post di Backend
  void toggleSavePost(String postId) async {
    if (_currentUser == null) return;

    try {
      final res = await ApiService.post('/saved/posts/$postId', null);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final isSavedVal = body['data']['is_saved'] as bool;
        final saved = List<String>.from(_currentUser!.savedPosts);
        if (isSavedVal) {
          if (!saved.contains(postId)) saved.add(postId);
        } else {
          saved.remove(postId);
        }
        _currentUser = _currentUser!.copyWith(savedPosts: saved);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Toggle Save Post Error: $e');
    }
  }

  /// Cek apakah postingan sudah disimpan
  bool isSaved(String postId) {
    if (_currentUser == null) return false;
    return _currentUser!.savedPosts.contains(postId);
  }

  /// Parser untuk data JSON User dari Backend
  UserModel _userFromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final username = json['username'] as String? ?? '';
    final displayName = json['display_name'] as String? ?? json['username'] as String? ?? '';
    final email = json['email'] as String? ?? '';
    final bio = json['bio'] as String? ?? '';
    final avatarUrl = ApiService.resolveImageUrl(json['avatar_url'] as String?);

    // Hitung initials
    final parts = displayName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : displayName.isNotEmpty && displayName.length >= 2
            ? displayName.substring(0, 2).toUpperCase()
            : displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    // Warna avatar acak tetapi konsisten berdasarkan hash username
    final colorVal = username.hashCode.abs() % 5;
    final Color color;
    switch (colorVal) {
      case 0:
        color = const Color(0xFFFB923C);
        break;
      case 1:
        color = const Color(0xFFF43F5E);
        break;
      case 2:
        color = const Color(0xFF8B5CF6);
        break;
      case 3:
        color = const Color(0xFF06B6D4);
        break;
      default:
        color = const Color(0xFF10B981);
    }

    final role = json['role'] as String? ?? 'user';
    final savedPosts = List<String>.from((json['saved_posts'] as List?)?.map((e) => e.toString()) ?? []);

    return UserModel(
      id: id,
      username: username,
      displayName: displayName,
      email: email,
      password: '',
      bio: bio,
      avatarUrl: avatarUrl,
      avatarInitials: initials,
      avatarColor: color,
      role: role,
      savedPosts: savedPosts,
      joinedAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
}
