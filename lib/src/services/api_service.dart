import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movilsw2/src/models/user.dart';

class ApiService {
  static const String baseUrl = 'https://example.com/api'; // Reemplaza esta URL con tu API

  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }
}
