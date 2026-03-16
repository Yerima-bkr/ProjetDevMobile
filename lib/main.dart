// lib/main.dart
import 'package:flutter/material.dart';
import 'constants.dart';
import 'models.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/medecin/home_screen.dart';
import 'screens/medecin/patient_detail_screen.dart';
import 'screens/medecin/prescriptions_screen.dart';
import 'screens/medecin/chat_screen.dart';
import 'screens/medecin/settings_screen.dart';
import 'screens/patient/patient_home_screen.dart';
import 'screens/patient/doctors_screen.dart';
import 'screens/patient/chat_patient_screen.dart';
import 'screens/patient/prescriptions_patient_screen.dart';
import 'screens/patient/settings_patient_screen.dart';
import 'screens/patient/auth_screen.dart';
import 'screens/patient/account_management_screen.dart';

void main() => runApp(const CareApp());

class CareApp extends StatelessWidget {
  const CareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CARE',
      debugShowCheckedModeBanner: false,
      theme: careTheme(),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          // ── AUTH ──────────────────────────────────────────
          case '/login':
            return _route(const LoginScreen());
          case '/register':
            return _route(const RegisterScreen());

          // ── REDIRECTION APRÈS LOGIN ────────────────────────
          case '/accueil':
            return _route(Session.estMedecin ? const HomeScreen() : const PatientHomeScreen());

          // ── MÉDECIN ───────────────────────────────────────
          case '/medecin/home':
            return _route(const HomeScreen());
          case '/medecin/patient-detail':
            return _route(PatientDetailScreen(patient: settings.arguments as Patient));
          case '/medecin/prescriptions':
            return _route(PrescriptionsScreen(patient: settings.arguments as Patient));
          case '/medecin/chat':
            return _route(ChatScreen(patient: settings.arguments as Patient));
          case '/medecin/settings':
            return _route(const SettingsScreen());

          // ── PATIENT ───────────────────────────────────────
          case '/patient/home':
            return _route(const PatientHomeScreen());
          case '/patient/doctors':
            return _route(const DoctorsScreen());
          case '/patient/chat':
            return _route(ChatPatientScreen(medecin: settings.arguments as Medecin));
          case '/patient/prescriptions':
            return _route(const PrescriptionsPatientScreen());
          case '/patient/settings':
            return _route(const SettingsPatientScreen());
          case '/patient/auth':
            return _route(const AuthScreen());
          case '/patient/account':
            return _route(const AccountManagementScreen());

          default:
            return _route(const LoginScreen());
        }
      },
    );
  }

  PageRoute _route(Widget page) => MaterialPageRoute(builder: (_) => page);
}