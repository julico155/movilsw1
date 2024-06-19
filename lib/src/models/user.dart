import 'dart:convert';


class User {
  String email;
  String token;

  User({required this.email, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      token: json['token'],
    );
  }
}
