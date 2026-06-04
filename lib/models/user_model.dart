import 'package:flutter/material.dart';

/// Model pengguna SosialKita
class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String password; // plain text (dummy only)
  final String bio;
  final String avatarUrl; // asset atau network dummy
  final String avatarInitials; // fallback "AY"
  final Color avatarColor; // warna avatar
  final String role; // 'user' | 'moderator'
  final List<String> followers; // list of user IDs
  final List<String> following; // list of user IDs
  final List<String> savedPosts; // list of post IDs
  final DateTime joinedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.password,
    this.bio = '',
    this.avatarUrl = '',
    required this.avatarInitials,
    required this.avatarColor,
    this.role = 'user',
    List<String>? followers,
    List<String>? following,
    List<String>? savedPosts,
    DateTime? joinedAt,
  })  : followers = followers ?? [],
        following = following ?? [],
        savedPosts = savedPosts ?? [],
        joinedAt = joinedAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? password,
    String? bio,
    String? avatarUrl,
    String? avatarInitials,
    Color? avatarColor,
    String? role,
    List<String>? followers,
    List<String>? following,
    List<String>? savedPosts,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarColor: avatarColor ?? this.avatarColor,
      role: role ?? this.role,
      followers: followers ?? List.from(this.followers),
      following: following ?? List.from(this.following),
      savedPosts: savedPosts ?? List.from(this.savedPosts),
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
