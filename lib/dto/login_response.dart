// lib/dto/login_response.dart

import 'package:mobileapp/model/user.dart';

class LoginResponse {
  final int statusLogin;
  final String text;
  final String token;
  final User user;

  LoginResponse({
    required this.statusLogin,
    required this.text,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      statusLogin: json['status']['STATUSLOGIN'],
      text: json['status']['TEXT'] ?? '',
      token: json['_token'] ?? '',
      user: User.fromJson(json['status']),
    );
  }
}
