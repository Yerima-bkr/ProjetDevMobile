import 'package:flutter/material.dart';
import 'package:suivie/screens/medecin/home_screen.dart';
import 'package:suivie/screens/medecin/prescriptions_screen.dart';
import 'package:suivie/screens/medecin/settings_screen.dart';

import '../../constants.dart';
import '../../models.dart';
import '../../widgets/care_bottom_nav.dart';
import '../../widgets/patient_avatar.dart';

class PrescriptionGlob extends StatefulWidget{

  const PrescriptionGlob({super.key});

  @override
  State<PrescriptionGlob> createState() => _PrescriptionGlobState();

}

class _PrescriptionGlobState extends State<PrescriptionGlob> {

  bool _chargement = true;
  List<Patient> patients = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _onNav(int i) {
    switch(i)
    {
      case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); break;
    }
  }

  Future<void> _charger() async {
    setState(() => _chargement = true);
    // ════════════════════════════════════════════════════════
    // TODO: _patients = await DatabaseService.getPatientsDuMedecin(Session.id);
    await Future.delayed(const Duration(milliseconds: 500));
    patients = [
      Patient(id: 1, nom: 'Abah',     email: 'abah@gmail.com',     taille: 2.75, poids: 150, groupeSanguin: 'Z-', glycemie: 1.0),
      Patient(id: 2, nom: 'Abolaca',  email: 'abolaca@gmail.com',  taille: 1.70, poids: 72,  groupeSanguin: 'A+', glycemie: 0.85),
      Patient(id: 3, nom: 'Boufson',  email: 'boufson@gmail.com',  taille: 1.82, poids: 90,  groupeSanguin: 'O-', glycemie: 1.25),
      Patient(id: 4, nom: 'Braladji', email: 'braladji@gmail.com', taille: 1.65, poids: 65,  groupeSanguin: 'B+', glycemie: 0.95),
    ];
    // ════════════════════════════════════════════════════════
    setState(() => _chargement = false );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(leading: const BackButton()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text('Vos prescriptions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextMain)),
          ),
          Expanded(
            child: _chargement
                ? const Center(child: CircularProgressIndicator(color: kTeal))
                  : patients.isEmpty
                    ? const Center(child: Text('Aucun patient', style: TextStyle(color: kTextSub)))
                : Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadius),
                child: ListView.separated(
                  itemCount: patients.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: kDivider, indent: 76),
                  itemBuilder: (_, i) {
                    final p = patients[i];
                    return InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrescriptionsScreen(patient: p))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(children: [
                          PatientAvatar(nom: p.nom, radius: 26, hasBorder: true),
                          const SizedBox(width: 14),
                          Expanded(child: Text(p.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kTextMain))),
                          const Icon(Icons.play_arrow_rounded, color: kTeal, size: 28),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: CareBottomNav(currentIndex: 1, onTap: _onNav),
    );
  }
}
