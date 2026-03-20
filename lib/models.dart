// lib/models.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // nécessaire pour Color dans imcCouleur

part 'models.g.dart';

// ── Rôle ─────────────────────────────────────────────────────
enum RoleUtilisateur { medecin, patient }

// ── Session (utilisateur connecté) ───────────────────────────
class Session {
  static int?             id;
  static String?          nom;
  static String?          email;
  static RoleUtilisateur? role;

  static bool get estMedecin  => role == RoleUtilisateur.medecin;
  static bool get estPatient  => role == RoleUtilisateur.patient;
  static bool get estConnecte => id != null;

  /// Appeler avec les données retournées par DatabaseService.login()
  static void connecter({
    required int id,
    required String nom,
    required String email,
    required RoleUtilisateur role,
  }) {
    Session.id    = id;
    Session.nom   = nom;
    Session.email = email;
    Session.role  = role;
  }

  static void deconnecter() {
    id = null; nom = null; email = null; role = null;
  }
}

// ── Patient ───────────────────────────────────────────────────
class Patient {
  final int     id;
  final String  nom;
  final String  email;
  final String? avatarUrl;
  final double  taille;       // mètres
  final double  poids;        // kg
  final String  groupeSanguin;
  final double  glycemie;     // g/l

  Patient({
    required this.id,
    required this.nom,
    required this.email,
    this.avatarUrl,
    required this.taille,
    required this.poids,
    required this.groupeSanguin,
    required this.glycemie,
  });

  double get imc => poids / (taille * taille);

  String get imcStatut {
    final v = imc;
    if (v < 18.5) return 'Insuffisance pondérale';
    if (v < 25)   return 'Poids normal';
    if (v < 30)   return 'Surpoids';
    return 'Obésité';
  }

  Color get imcCouleur {
    final v = imc;
    if (v < 18.5) return const Color(0xFF2196F3);
    if (v < 25)   return const Color(0xFF2EC4C4);
    if (v < 30)   return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  bool get glycemieAnormale => glycemie > 1.1 || glycemie < 0.7;

  // TODO: connecter à DatabaseService
  factory Patient.fromMap(Map<String, dynamic> m) => Patient(
    id: m['id'], nom: m['nom'], email: m['email'] ?? '',
    avatarUrl: m['avatar_url'],
    taille: (m['taille'] as num).toDouble(),
    poids:  (m['poids']  as num).toDouble(),
    groupeSanguin: m['groupe_sanguin'],
    glycemie: (m['glycemie'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'nom': nom, 'email': email, 'avatar_url': avatarUrl,
    'taille': taille, 'poids': poids,
    'groupe_sanguin': groupeSanguin, 'glycemie': glycemie,
    'role': 'patient',
  };
}

// ── Médecin ───────────────────────────────────────────────────
class Medecin {
  final int     id;
  final String  nom;
  final String  email;
  final String  specialite;
  final String? avatarUrl;

  Medecin({
    required this.id,
    required this.nom,
    required this.email,
    required this.specialite,
    this.avatarUrl,
  });

  // TODO: connecter à DatabaseService
  factory Medecin.fromMap(Map<String, dynamic> m) => Medecin(
    id: m['id'], nom: m['nom'], email: m['email'] ?? '',
    specialite: m['specialite'], avatarUrl: m['avatar_url'],
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'nom': nom, 'email': email,
    'specialite': specialite, 'avatar_url': avatarUrl,
    'role': 'medecin',
  };
}

// ── Prescription ──────────────────────────────────────────────
class Prescription {
  final int      id;
  final int      patientId;
  final int      medecinId;   // ← nouveau champ
  final String   medecinNom;
  final String   specialite;
  final String   medicament;
  final String   message;
  final DateTime dateDebut;
  final DateTime dateFin;

  Prescription({
    required this.id,
    required this.patientId,
    required this.medecinId,
    required this.medecinNom,
    required this.specialite,
    required this.medicament,
    required this.message,
    required this.dateDebut,
    required this.dateFin,
  });

  // TODO: connecter à DatabaseService
  factory Prescription.fromMap(Map<String, dynamic> m) => Prescription(
    id: m['id'], patientId: m['patient_id'], medecinId: m['medecin_id'],
    medecinNom: m['medecin_nom'], specialite: m['specialite'],
    medicament: m['medicament'], message: m['message'] ?? '',
    dateDebut: DateTime.parse(m['date_debut']),
    dateFin:   DateTime.parse(m['date_fin']),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'patient_id': patientId, 'medecin_id': medecinId,
    'medecin_nom': medecinNom, 'specialite': specialite,
    'medicament': medicament, 'message': message,
    'date_debut': dateDebut.toIso8601String(),
    'date_fin':   dateFin.toIso8601String(),
  };
}

// ── Message ───────────────────────────────────────────────────
@HiveType(typeId: 1)
class Message extends HiveObject{
  @HiveField(0)
  final int      id;
  @HiveField(1)
  final int      patientId;
  @HiveField(2)
  final int      medecinId;
  @HiveField(3)
  final String   expediteur; // 'patient' ou 'medecin'
  @HiveField(4)
  final String   texte;
  @HiveField(5)
  final DateTime dateEnvoi;
  @HiveField(6)
  bool           lu;

  Message({
    required this.id,
    required this.patientId,
    required this.medecinId,
    required this.expediteur,
    required this.texte,
    required this.dateEnvoi,
    this.lu = false,
  });


  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        id: int.parse(json['id']),
        patientId: int.parse(json['PatientId']),
        medecinId: int.parse(json['medecinId']),
        expediteur: json['expediteur'] == "0" ? "patient" : "medecin",
        texte: json['text'],
        dateEnvoi: DateTime.parse(json['dateEnvoi']),
        lu: bool.parse(json['lu']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'PatientId': patientId.toString(),
      'medecinId': medecinId.toString(),
      'expediteur': expediteur == "patient" ? "0" : "1",
      'text': texte,
      'dateEnvoi': dateEnvoi.toIso8601String(),
      'lu': lu.toString()
    };
  }

}
// ── Message du bot───────────────────────────────────────────────────
@HiveType(typeId: 0)
class BotMessage extends HiveObject {

  @HiveField(0)
  final int      id;
  @HiveField(1)
  final String   texte;
  @HiveField(2)
  final String   expediteur;
  @HiveField(3)
  final DateTime dateEnvoi;

  BotMessage({
    required this.id,
    required this.texte,
    required this.expediteur,
    required this.dateEnvoi
  });

}