// lib/screens/patient/prescriptions_patient_screen.dart  — Écrans 13, 14, 15
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../widgets/care_bottom_nav.dart';
import '../../widgets/patient_avatar.dart';
import 'patient_home_screen.dart';
import 'doctors_screen.dart';
import 'settings_patient_screen.dart';

class PrescriptionsPatientScreen extends StatefulWidget {
  const PrescriptionsPatientScreen({super.key});
  @override
  State<PrescriptionsPatientScreen> createState() => _PrescriptionsPatientScreenState();
}

class _PrescriptionsPatientScreenState extends State<PrescriptionsPatientScreen> {
  bool _chargement = true;
  List<Prescription> _liste = [];
  int? _ouvertIndex;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    setState(() { _chargement = true; _ouvertIndex = null; });
    // ════════════════════════════════════════════════════════
    // TODO: _liste = await DatabaseService.getPrescriptionsPatient(Session.id);
    await Future.delayed(const Duration(milliseconds: 400));
    _liste = [
      Prescription(id: 1, patientId: Session.id ?? 1, medecinId: 1, medecinNom: 'Edouard Newgate', specialite: 'Ophtalmologue', medicament: 'Paracétamol', message: 'Vous devez vous assurez de suivre avec ponctualité les prises de ce médicament.', dateDebut: DateTime(2026, 2, 1),  dateFin: DateTime(2026, 2, 28)),
      Prescription(id: 2, patientId: Session.id ?? 1, medecinId: 1, medecinNom: 'Edouard Newgate', specialite: 'Ophtalmologue', medicament: 'Ibuprofène 400mg',   message: 'En cas de douleur uniquement.',   dateDebut: DateTime(2026, 2, 10), dateFin: DateTime(2026, 3, 10)),
      Prescription(id: 3, patientId: Session.id ?? 1, medecinId: 1, medecinNom: 'Edouard Newgate', specialite: 'Ophtalmologue', medicament: 'Amoxicilline 500mg', message: 'Matin et soir après les repas.',    dateDebut: DateTime(2026, 2, 15), dateFin: DateTime(2026, 2, 22)),
      Prescription(id: 4, patientId: Session.id ?? 1, medecinId: 1, medecinNom: 'Edouard Newgate', specialite: 'Ophtalmologue', medicament: 'Vitamine D3',         message: 'Une dose par semaine.',           dateDebut: DateTime(2026, 1, 1),  dateFin: DateTime(2026, 6, 30)),
    ];
    // ════════════════════════════════════════════════════════
    setState(() => _chargement = false);
  }

  void _onNav(int i) {
    switch (i) {
      case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PatientHomeScreen())); break;
      case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorsScreen())); break;
      case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsPatientScreen())); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text('Vos prescriptions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextMain)),
          ),
          Expanded(
            child: _chargement
                ? const Center(child: CircularProgressIndicator(color: kTeal))
                : _liste.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
                          child: const Center(child: Padding(
                            padding: EdgeInsets.all(60),
                            child: Text('Vous n\'avez recu aucune prescription...', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextSub), textAlign: TextAlign.center),
                          )),
                        ),
                      )
                    : RefreshIndicator(
                        color: kTeal,
                        onRefresh: _charger,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                          children: [
                            Container(
                              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(kRadius),
                                child: Column(children: List.generate(_liste.length, (i) {
                                  final p      = _liste[i];
                                  final ouvert = _ouvertIndex == i;
                                  return Column(children: [
                                    InkWell(
                                      onTap: () => setState(() => _ouvertIndex = ouvert ? null : i),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        child: Row(children: [
                                          PatientAvatar(nom: p.medecinNom, radius: 28, hasBorder: true),
                                          const SizedBox(width: 14),
                                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Text('De : ${p.medecinNom}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kTextMain)),
                                            Text(p.specialite, style: const TextStyle(color: kTextSub, fontSize: 13)),
                                          ])),
                                          AnimatedRotation(
                                            turns: ouvert ? 0.25 : 0,
                                            duration: const Duration(milliseconds: 200),
                                            child: const Icon(Icons.play_arrow_rounded, color: kTeal, size: 28),
                                          ),
                                        ]),
                                      ),
                                    ),

                                    // Détail expandable
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      child: ouvert ? Container(
                                        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: kTeal, width: 1.5),
                                          borderRadius: BorderRadius.circular(kRadiusSmall),
                                          color: kTealLight,
                                        ),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          _ligne('Médicament', p.medicament),
                                          const SizedBox(height: 10),
                                          _ligne('Message du médecin', p.message),
                                          const SizedBox(height: 14),
                                          const Text('Période :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextMain)),
                                          const SizedBox(height: 10),
                                          _MiniCalendrier(dateDebut: p.dateDebut, dateFin: p.dateFin),
                                        ]),
                                      ) : const SizedBox.shrink(),
                                    ),

                                    if (i < _liste.length - 1)
                                      const Divider(height: 1, color: kDivider, indent: 76),
                                  ]);
                                })),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ]),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: kShadowLight),
              child: const Text('Vous avez une question ?', style: TextStyle(fontSize: 12, color: kTextSub))),
          const SizedBox(width: 8),
          FloatingActionButton(heroTag: 'bot', backgroundColor: kTeal, elevation: 4, mini: true, onPressed: () {}, child: const Icon(Icons.smart_toy_rounded, color: Colors.white)),
        ]),
      ),
      bottomNavigationBar: CareBottomNavPatient(currentIndex: 2, onTap: _onNav),
    );
  }

  Widget _ligne(String label, String valeur) => RichText(text: TextSpan(
    style: const TextStyle(fontSize: 14, color: kTextMain, height: 1.5),
    children: [
      TextSpan(text: '$label : ', style: const TextStyle(fontWeight: FontWeight.w700)),
      TextSpan(text: valeur),
    ],
  ));
}

// ── Mini calendrier ───────────────────────────────────────────
class _MiniCalendrier extends StatefulWidget {
  final DateTime dateDebut, dateFin;
  const _MiniCalendrier({required this.dateDebut, required this.dateFin});
  @override
  State<_MiniCalendrier> createState() => _MiniCalendrierState();
}

class _MiniCalendrierState extends State<_MiniCalendrier> {
  late DateTime _mois;
  static const _j = ['Su','Mo','Tu','We','Th','Fr','Sa'];
  static const _m = ['January','February','March','April','May','June','July','August','September','October','November','December'];

  @override
  void initState() { super.initState(); _mois = DateTime(widget.dateDebut.year, widget.dateDebut.month); }

  bool _dansPlage(DateTime d) => !d.isBefore(widget.dateDebut) && !d.isAfter(widget.dateFin);

  @override
  Widget build(BuildContext context) {
    final premier = DateTime(_mois.year, _mois.month, 1);
    final dernier = DateTime(_mois.year, _mois.month + 1, 0);
    final offset  = premier.weekday % 7;
    final lignes  = ((offset + dernier.day) / 7).ceil();
    final auj     = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(kRadiusSmall), border: Border.all(color: kTeal, width: 1.5)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_m[_mois.month - 1]} ${_mois.year}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: kTealDark)),
          Row(children: [
            GestureDetector(onTap: () => setState(() => _mois = DateTime(_mois.year, _mois.month - 1)), child: const Icon(Icons.arrow_drop_up,   color: kTealDark, size: 22)),
            GestureDetector(onTap: () => setState(() => _mois = DateTime(_mois.year, _mois.month + 1)), child: const Icon(Icons.arrow_drop_down, color: kTealDark, size: 22)),
          ]),
        ]),
        const SizedBox(height: 6),
        Row(children: _j.map((j) => Expanded(child: Center(child: Text(j, style: const TextStyle(fontSize: 10, color: kTealDark, fontWeight: FontWeight.w600))))).toList()),
        const SizedBox(height: 4),
        ...List.generate(lignes, (ligne) => Row(children: List.generate(7, (col) {
          final idx  = ligne * 7 + col;
          final jour = idx - offset + 1;
          if (jour < 1 || jour > dernier.day) return const Expanded(child: SizedBox(height: 28));
          final date    = DateTime(_mois.year, _mois.month, jour);
          final enPlage = _dansPlage(date);
          final estAuj  = date.year == auj.year && date.month == auj.month && date.day == auj.day;
          Color? bg;
          if (enPlage) bg = kTealDark;
          else if (estAuj) bg = kTeal.withOpacity(0.4);
          return Expanded(child: Container(
            margin: const EdgeInsets.all(1.5), height: 28,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
            child: Center(child: Text('$jour', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: bg != null ? Colors.white : Colors.black54))),
          ));
        }))),
      ]),
    );
  }
}