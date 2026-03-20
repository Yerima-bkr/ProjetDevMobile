import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:suivie/models.dart';


Future<List<Message>> getMessages(int patientId, int medecinId) async {

  print('Got here. IdPatient : $patientId IdMedecin : $medecinId');
  final response = await http.get(Uri.parse('https://care-gsn2.onrender.com/api/messages/get-by-user/${patientId.toString()}/${medecinId.toString()}'));
  print('And here');
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => Message.fromJson(data)).toList();
  } else {
    //throw Exception('Failed to load messages');
    print("Failed to load messages : ${response.body}");

    return List<Message>.empty();
  }
}

Future<List<Medecin>> getMedecins() async {

  final response = await http.get(Uri.parse('https://care-gsn2.onrender.com/api/medecin/get'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => Medecin.fromJson(data)).toList();
  } else {
    //throw Exception('Failed to load messages');
    print("Failed to load medecins : ${response.body}");

    return List<Medecin>.empty();
  }
}

Future<bool> sendMessage(Message message) async {

  final response = await http.post(
    Uri.parse('https://care-gsn2.onrender.com/api/messages/creer'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(message.toJson()),
  );

  print(message.toJson().toString());

  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  } else {
    print("Failed to send message : ${response.body}");
    return false;
  }
}
