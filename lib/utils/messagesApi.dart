import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:suivie/models.dart';


Future<List<Message>> getMessages(int patientId, int medecinId) async {

  print('Got here');
  final response = await http.get(Uri.parse('https://care-gsn2.onrender.com/api/messages/get-by-user/$patientId/$medecinId'));
  print('And here');
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => Message.fromJson(data)).toList();
  } else {
    //throw Exception('Failed to load messages');
    print("Failed to load messages.");

    return List<Message>.empty();
  }
}

Future<bool> sendMessage(Message message) async {

  final response = await http.post(Uri.parse('https://care-gsn2.onrender.com/api/messages/creer'), body: message.toJson());
  if (response.statusCode == 200) {

    return true;
  } else {
    //throw Exception('Failed to load messages');
    print("Failed to send message.");

    return false;
  }
}