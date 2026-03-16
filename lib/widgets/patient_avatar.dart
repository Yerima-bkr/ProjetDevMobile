// lib/widgets/patient_avatar.dart
import 'package:flutter/material.dart';
import '../constants.dart';

class PatientAvatar extends StatelessWidget {
  final String nom;
  final double radius;
  final String? avatarUrl; // Renommé imageUrl -> avatarUrl
  final bool hasBorder;

  const PatientAvatar({
    super.key,
    required this.nom,
    this.radius = 24,
    this.avatarUrl, // Renommé ici aussi
    this.hasBorder = false,
  });

  static const _colors = [kTeal, kTealDark, Color(0xFF00AAAA), Color(0xFF00BFBF), Color(0xFF26A69A)];

  Color get _couleur => _colors[nom.isNotEmpty ? nom.codeUnitAt(0) % _colors.length : 0];

  String get _initiales {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nom.isNotEmpty ? nom.substring(0, nom.length.clamp(0, 2)).toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    // Utilisation du nouveau nom avatarUrl
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: _couleur,
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: _couleur,
        child: Text(
          _initiales,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.8, // Légèrement augmenté pour la lisibilité
          ),
        ),
      );
    }

    if (hasBorder) {
      return Container(
        padding: const EdgeInsets.all(2), // Petit espace entre la bordure et l'image
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: kTeal, width: 2.5),
        ),
        child: avatar,
      );
    }
    return avatar;
  }
}