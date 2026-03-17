// lib/screens/patient/patient_home_screen.dart  — Écran 9
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../widgets/bot_help_button.dart';
import '../../widgets/care_bottom_nav.dart';
import 'doctors_screen.dart';
import 'prescriptions_patient_screen.dart';
import 'settings_patient_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});
  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  bool _chargement = true;
  Patient? _patient;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    setState(() => _chargement = true);
    // ════════════════════════════════════════════════════════
    // TODO: _patient = await DatabaseService.getPatientConnecte(Session.id);
    await Future.delayed(const Duration(milliseconds: 400));
    _patient = Patient(
      id: Session.id ?? 1, nom: Session.nom ?? 'Patient',
      email: Session.email ?? '', taille: 2.75, poids: 150,
      groupeSanguin: 'Z-', glycemie: 1.0,
    );
    // ════════════════════════════════════════════════════════
    setState(() => _chargement = false);
  }

  void _onNav(int i) {
    switch (i) {
      case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorsScreen())); break;
      case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PrescriptionsPatientScreen())); break;
      case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsPatientScreen())); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: _chargement
            ? const Center(child: CircularProgressIndicator(color: kTeal))
            : _patient == null
                ? const Center(child: Text('Erreur de chargement'))
                : RefreshIndicator(
                    color: kTeal,
                    onRefresh: _charger,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('👋 Bienvenu!', style: TextStyle(color: kTextSub, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(_patient!.nom, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextMain)),
                        const SizedBox(height: 28),

                        Row(children: [
                          Expanded(child: _Carte(label: 'Taille', valeur: '${_patient!.taille.toStringAsFixed(2)} m', icon: Icons.accessibility_new_rounded)),
                          const SizedBox(width: 14),
                          Expanded(child: _Carte(label: 'Poids', valeur: '${_patient!.poids.toStringAsFixed(0)} kg', icon: Icons.monitor_weight_outlined)),
                        ]),
                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('IMC', style: TextStyle(color: kTextSub, fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(_patient!.imc.toStringAsFixed(2), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kTextMain)),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: _patient!.imcCouleur.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                              child: Text(_patient!.imcStatut, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _patient!.imcCouleur)),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'Normal: 18.5 – 24.9',
                              child: Container(width: 28, height: 28,
                                decoration: BoxDecoration(border: Border.all(color: kTeal, width: 1.5), shape: BoxShape.circle),
                                child: const Icon(Icons.info_outline, size: 16, color: kTeal)),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 14),

                        Row(children: [
                          Expanded(child: _Carte(label: 'Groupe sanguin', valeur: _patient!.groupeSanguin, icon: Icons.water_drop_rounded, iconColor: Colors.red)),
                          const SizedBox(width: 14),
                          Expanded(child: _Carte(
                            label: 'Glycémie', valeur: '${_patient!.glycemie.toStringAsFixed(2)} g/l',
                            icon: Icons.biotech_rounded,
                            alerte: _patient!.glycemie > 1.1 || _patient!.glycemie < 0.7,
                            alerteMsg: 'Normal: 0.70 – 1.10 g/l',
                          )),
                        ]),
                      ]),
                    ),
                  ),
      ),
      floatingActionButton: BotButton(),
      bottomNavigationBar: CareBottomNavPatient(currentIndex: 0, onTap: _onNav),
    );
  }
}

class _Carte extends StatelessWidget {
  final String label, valeur;
  final IconData icon;
  final Color? iconColor;
  final bool alerte;
  final String? alerteMsg;

  const _Carte({required this.label, required this.valeur, required this.icon, this.iconColor, this.alerte = false, this.alerteMsg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius),
          border: alerte ? Border.all(color: kDanger.withOpacity(0.4), width: 1.5) : null, boxShadow: kShadowLight),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: kTextSub)),
          if (alerte && alerteMsg != null)
            Tooltip(message: alerteMsg!, child: const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.info_outline, size: 14, color: kDanger))),
        ]),
        const SizedBox(height: 10),
        Icon(icon, size: 38, color: iconColor ?? kTeal),
        const SizedBox(height: 8),
        Text(valeur, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: alerte ? kDanger : kTextMain)),
        if (alerte) const Text('⚠ Hors norme', style: TextStyle(fontSize: 10, color: kDanger, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}