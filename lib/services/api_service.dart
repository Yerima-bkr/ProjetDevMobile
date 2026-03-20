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

      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        Session.connecter(
          id: user['id'],
          nom: user['nom'],
          email: user['email'],
          role: user['role'] != null ? RoleUtilisateur.medecin : RoleUtilisateur.patient,
          token: data['token']
        );

        if(user['role'] == null){
          Patient test = await getPatient(user['id']);

          Session.connectedPatient = Patient(
            id: test.id,
            nom: test.nom,
            email: test.email,
            taille: test.taille,
            poids: test.poids,
            groupeSanguin: test.groupeSanguin,
            glycemie: test.glycemie
          );
        }

        return true;
      }
      return false;
    } catch (e) {
      print('Here : $e');
      return false;
    }
  }

  static Future<Patient> getPatient(int patientId) async {

    final response = await http.get(Uri.parse('https://care-gsn2.onrender.com/api/auth/check/${patientId.toString()}'));

    if (response.statusCode == 200 || response.statusCode == 201) {

      final user = json.decode(response.body);

      return Patient(
          id: user['id'],
          nom: user['nom'],
          email: user['email'],
          taille: double.parse(user['taille'].toString()),
          poids: double.parse(user['poids'].toString()),
          groupeSanguin: user['groupeSanguin'],
          glycemie: double.parse(user['glycemie'].toString())
      );
    } else {
      //throw Exception('Failed to load messages');
      print("Failed to get patient : ${response.body}");

      return Patient(id: 0, nom: 'nom', email: 'email', taille: 0, poids: 0, groupeSanguin: 'groupeSanguin', glycemie: 0);
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
