// lib/screens/medecin/patient_detail_screen.dart  — Écran 4
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../widgets/patient_avatar.dart';
import 'prescriptions_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final glycAnorm = patient.glycemie > 1.1 || patient.glycemie < 0.7;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        leading: const BackButton(),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: kDivider)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(children: [
          // Profil
          PatientAvatar(nom: patient.nom, radius: 40, avatarUrl: patient.avatarUrl, hasBorder: true),
          const SizedBox(height: 8),
          const Text('Informations du patient', style: TextStyle(color: kTextSub, fontSize: 13)),
          const SizedBox(height: 4),
          Text(patient.nom, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kTextMain)),
          const SizedBox(height: 28),

          // Taille / Poids
          Row(children: [
            Expanded(child: _CarteInfo(
              label: 'Taille', valeur: '${patient.taille.toStringAsFixed(2)} m',
              icon: Icons.accessibility_new_rounded, iconColor: kTeal,
            )),
            const SizedBox(width: 14),
            Expanded(child: _CarteInfo(
              label: 'Poids', valeur: '${patient.poids.toStringAsFixed(0)} kg',
              icon: Icons.monitor_weight_outlined, iconColor: kTeal,
            )),
          ]),
          const SizedBox(height: 14),

          // IMC
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('IMC', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: kTextSub)),
                const SizedBox(height: 4),
                Text(patient.imc.toStringAsFixed(2), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kTextMain)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: patient.imcCouleur.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.circle, size: 10, color: patient.imcCouleur),
                  const SizedBox(width: 6),
                  Text(patient.imcStatut, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: patient.imcCouleur)),
                ]),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Normal: 18.5 – 24.9',
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(border: Border.all(color: kTeal, width: 1.5), shape: BoxShape.circle),
                  child: const Icon(Icons.info_outline, size: 16, color: kTeal),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Groupe sanguin / Glycémie
          Row(children: [
            Expanded(child: _CarteInfo(
              label: 'Groupe sanguin', valeur: patient.groupeSanguin,
              icon: Icons.water_drop_rounded, iconColor: Colors.red,
            )),
            const SizedBox(width: 14),
            Expanded(child: _CarteInfo(
              label: 'Glycémie', valeur: '${patient.glycemie.toStringAsFixed(2)} g/l',
              icon: Icons.biotech_rounded, iconColor: glycAnorm ? kDanger : kTeal,
              alerte: glycAnorm, alerteMsg: 'Normal: 0.70 – 1.10 g/l',
            )),
          ]),
          const SizedBox(height: 32),

          // Bouton prescriptions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrescriptionsScreen(patient: patient))),
              icon: const Icon(Icons.assignment_rounded, size: 20),
              label: const Text('Prescriptions du patient'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _CarteInfo extends StatelessWidget {
  final String label, valeur;
  final IconData icon;
  final Color iconColor;
  final bool alerte;
  final String? alerteMsg;

  const _CarteInfo({
    required this.label, required this.valeur,
    required this.icon, required this.iconColor,
    this.alerte = false, this.alerteMsg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(kRadius),
        border: alerte ? Border.all(color: kDanger.withOpacity(0.4), width: 1.5) : null,
        boxShadow: kShadowLight,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: kTextSub)),
          if (alerte && alerteMsg != null)
            Tooltip(message: alerteMsg!, child: const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.info_outline, size: 14, color: kDanger))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(icon, size: 36, color: iconColor),
          const Spacer(),
        ]),
        const SizedBox(height: 8),
        Text(valeur, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: alerte ? kDanger : kTextMain)),
        if (alerte) const Text('⚠ Hors norme', style: TextStyle(fontSize: 10, color: kDanger, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}