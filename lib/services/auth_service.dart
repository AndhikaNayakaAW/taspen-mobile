//lib/services/auth_service.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobileapp/model/user.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<User> loadUserInfo() async {
    try {
      String? userJson = await _storage.read(key: 'user');
      return User.fromJson(jsonDecode(userJson!));
    } catch (e) {
      debugPrint('Error loading user info: $e');
      throw Exception('Failed to load user info.');
    }
  }
}
