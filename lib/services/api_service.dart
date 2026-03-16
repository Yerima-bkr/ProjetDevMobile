// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class ApiService {
  static const String baseUrl = "https://care-gsn2.onrender.com/api";
  // login
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        Session.connecter(
          id: 0,
          nom: user['nom'],
          email: user['email'],
          role: RoleUtilisateur.patient,
        );

        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // signup
  static Future<bool> register(
      String nom, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        body: jsonEncode({'nom': nom, 'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
