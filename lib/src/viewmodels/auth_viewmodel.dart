import 'package:flutter/material.dart';
import 'package:movilsw2/src/models/user.dart';
import 'package:movilsw2/src/services/api_service.dart';

class AuthViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Aquí llamas a la API para autenticar al usuario
      // _user = await _apiService.login(email, password);
      
      // Datos ficticios para la prueba
      await Future.delayed(Duration(seconds: 2));
      _user = User(email: email, token: 'faketoken123');
    } catch (e) {
      // Manejar errores
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}