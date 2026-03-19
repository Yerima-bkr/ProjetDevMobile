import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MaelaApp());
}

// --- 1. CHARTE GRAPHIQUE ET THÈME ---
// Couleurs : Blanc, Vert, Bleu [cite: 17, 18]
// Police : Times New Roman [cite: 15, 16]
class MaelaApp extends StatelessWidget {
  const MaelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maela - Suivi Curatif',
      theme: ThemeData(
        fontFamily: 'Times New Roman', // [cite: 15, 16]
        primaryColor: const Color(0xFF008000), // Vert [cite: 17, 18]
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008000),
          primary: const Color(0xFF008000),
          secondary: const Color(0xFF0000FF), // Bleu [cite: 17, 18]
        ),
        scaffoldBackgroundColor: Colors.white, // Blanc [cite: 17, 18]
        useMaterial3: true,
      ),
      home: const CurativeFollowUpPage(),
    );
  }
}

// --- 2. MODÈLES DE DONNÉES (Diagramme de Classe) ---
// Structure basée sur les classes 'traitement' et 'prescription' 
class Treatment {
  final String id;
  final String medicament;
  final String dosage;
  final DateTime dateDebut;
  final DateTime dateFin;
  final List<String> rappels; // Heures de prise
  bool estConfirme;

  Treatment({
    required this.id,
    required this.medicament,
    required this.dosage,
    required this.dateDebut,
    required this.dateFin,
    required this.rappels,
    this.estConfirme = false,
  });
}

class Appointment {
  final String id;
  final String titre;
  final DateTime dateHeure;
  final String lieu;

  Appointment({
    required this.id,
    required this.titre,
    required this.dateHeure,
    required this.lieu,
  });
}

// --- 3. SERVICE DE NOTIFICATION (Système de Rappel) ---
// Gère l'envoi des alertes pour les prises et les RDV 
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleReminder(int id, String title, String body, DateTime date) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'curatif_channel', 'Suivi Curatif',
          importance: Importance.max, priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

// --- 4. INTERFACE UTILISATEUR (UI) ---
class CurativeFollowUpPage extends StatefulWidget {
  const CurativeFollowUpPage({super.key});

  @override
  State<CurativeFollowUpPage> createState() => _CurativeFollowUpPageState();
}

class _CurativeFollowUpPageState extends State<CurativeFollowUpPage> {
  // Données de test simulant la base de données PostgreSQL [cite: 13, 17]
  final List<Treatment> _treatments = [
    Treatment(
      id: "1",
      medicament: "Paracétamol",
      dosage: "500mg - 1 comprimé",
      dateDebut: DateTime.now(),
      dateFin: DateTime.now().add(const Duration(days: 5)),
      rappels: ["08:00", "20:00"],
    ),
  ];

  final List<Appointment> _appointments = [
    Appointment(
      id: "101",
      titre: "Consultation Cardiologie",
      dateHeure: DateTime.now().add(const Duration(days: 2)),
      lieu: "Hôpital Central",
    ),
  ];

  // Logique du Diagramme d'Activité : Confirmer la prise 
  void _confirmIntake(int index) {
    setState(() {
      _treatments[index].estConfirme = true;
      // Ici, on enregistre dans l'historique de la DB comme prévu par l'UML 
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Prise confirmée et enregistrée dans l'historique.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Suivi Curatif", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Prise de Médicaments", Icons.medication),
            ..._treatments.asMap().entries.map((entry) => _buildTreatmentCard(entry.value, entry.key)),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader("Rappels de RDV", Icons.event),
            ..._appointments.map((apt) => _buildAppointmentCard(apt)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Action pour "Etablir traitement" (Medecin) 
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(Treatment treatment, int index) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(treatment.medicament, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${treatment.dosage}\nProchaine prise : ${treatment.rappels.first}"),
        trailing: treatment.estConfirme 
          ? const Icon(Icons.check_circle, color: Colors.green)
          : ElevatedButton(
              onPressed: () => _confirmIntake(index),
              child: const Text("Confirmer"),
            ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment apt) {
    final dateStr = DateFormat('dd/MM à HH:mm').format(apt.dateHeure);
    return Card(
      color: const Color(0xFFE3F2FD), // Teinte bleutée légère [cite: 17]
      child: ListTile(
        leading: const Icon(Icons.notifications_active, color: Colors.blue),
        title: Text(apt.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${apt.lieu} - $dateStr"),
      ),
    );
  }
}