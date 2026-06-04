import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../core/utils/dummy_data.dart';

/// AuthProvider — mengelola state autentikasi
/// Login/register/logout menggunakan data dummy in-memory
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isModerator => _currentUser?.role == 'moderator';

  /// Login: cocokkan email + password dengan dummyUsers
  /// Mengembalikan true jika berhasil, false jika gagal
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulasi delay jaringan
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final user = dummyUsers.firstWhere(
        (u) =>
            (u.email.toLowerCase() == email.toLowerCase() ||
                u.username.toLowerCase() == email.toLowerCase()) &&
            u.password == password,
      );

      _currentUser = user;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register: buat user baru, tambah ke list dummy, auto login
  Future<bool> register(
    String displayName,
    String username,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    // Cek duplikat email / username
    final emailExists = dummyUsers.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    final usernameExists = dummyUsers.any(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );

    if (emailExists || usernameExists) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Generate initials dari displayName
    final parts = displayName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : displayName.substring(0, 2).toUpperCase();

    final newUser = UserModel(
      id: 'u${dummyUsers.length + 1}',
      username: username,
      displayName: displayName,
      email: email,
      password: password,
      avatarInitials: initials,
      avatarColor: const Color(0xFFFB923C), // default orange
      role: 'user',
      joinedAt: DateTime.now(),
    );

    dummyUsers.add(newUser);
    _currentUser = newUser;
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Logout: bersihkan state
  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Update profil pengguna saat ini
  void updateProfile(UserModel updated) {
    _currentUser = updated;
    final idx = dummyUsers.indexWhere((u) => u.id == updated.id);
    if (idx != -1) {
      dummyUsers[idx] = updated;
    }
    notifyListeners();
  }
}
