// lib/screens/medecin/home_screen.dart  — Écran 3
import 'package:flutter/material.dart';
import 'package:suivie/screens/medecin/prescription_glob.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../widgets/bot_help_button.dart';
import '../../widgets/care_bottom_nav.dart';
import '../../widgets/patient_avatar.dart';
import 'patient_detail_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _chargement = true;
  List<Patient> _patients = [];
  List<Patient> _filtres  = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _charger();
    _searchCtrl.addListener(_filtrer);
  }

  Future<void> _charger() async {
    setState(() => _chargement = true);
    // ════════════════════════════════════════════════════════
    // TODO: _patients = await DatabaseService.getPatientsDuMedecin(Session.id);
    await Future.delayed(const Duration(milliseconds: 500));
    _patients = [
      Patient(id: 1, nom: 'Abah',     email: 'abah@gmail.com',     taille: 2.75, poids: 150, groupeSanguin: 'Z-', glycemie: 1.0),
      Patient(id: 2, nom: 'Abolaca',  email: 'abolaca@gmail.com',  taille: 1.70, poids: 72,  groupeSanguin: 'A+', glycemie: 0.85),
      Patient(id: 3, nom: 'Boufson',  email: 'boufson@gmail.com',  taille: 1.82, poids: 90,  groupeSanguin: 'O-', glycemie: 1.25),
      Patient(id: 4, nom: 'Braladji', email: 'braladji@gmail.com', taille: 1.65, poids: 65,  groupeSanguin: 'B+', glycemie: 0.95),
    ];
    // ════════════════════════════════════════════════════════
    setState(() { _filtres = List.from(_patients); _chargement = false; });
  }

  void _filtrer() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() => _filtres = q.isEmpty ? List.from(_patients) : _patients.where((p) => p.nom.toLowerCase().contains(q)).toList());
  }

  Future<void> _ajouterPatient() async {
    final result = await showDialog<Patient>(context: context, builder: (_) => const _DialogAjout());
    if (result != null) {
      // TODO: await DatabaseService.insererPatient(result);
      setState(() { _patients.add(result); _filtrer(); });
      if (mounted) _showSnack('${result.nom} ajouté avec succès');
    }
  }

  Future<void> _supprimerPatient(Patient p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        title: const Text('Supprimer le patient', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Voulez-vous supprimer ${p.nom} ?', style: const TextStyle(color: kTextSub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler', style: TextStyle(color: kTextSub))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kDanger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusBtn))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // TODO: await DatabaseService.supprimerPatient(p.id);
      setState(() { _patients.removeWhere((x) => x.id == p.id); _filtrer(); });
      if (mounted) _showSnack('${p.nom} supprimé');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: kTeal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSmall)),
    ));
  }

  void _onNav(int i) {
    switch(i)
    {
      case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PrescriptionGlob())); break;
      case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); break;
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          // ── Header ─────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('👋 Bienvenu!', style: TextStyle(color: kTextSub, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(Session.nom ?? 'Médecin', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kTextMain)),
                ])),
                GestureDetector(
                  onTap: _ajouterPatient,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: kTeal, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              // Barre recherche
              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un patient...',
                  prefixIcon: Icon(Icons.search_rounded, color: kTextSub),
                ),
              ),
            ]),
          ),

          // Titre section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Vos patients', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: kTextMain)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(20)),
                child: Text('${_filtres.length}', style: const TextStyle(color: kTealDark, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ]),
          ),

          // ── Liste patients ──────────────────────────────
          Expanded(
            child: _chargement
                ? const Center(child: CircularProgressIndicator(color: kTeal))
                : _filtres.isEmpty
                    ? _vide()
                    : RefreshIndicator(
                        color: kTeal,
                        onRefresh: _charger,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(kRadius),
                            child: ListView.separated(
                              itemCount: _filtres.length,
                              separatorBuilder: (_, _) => const Divider(height: 1, color: kDivider, indent: 76),
                              itemBuilder: (_, i) {
                                final p = _filtres[i];
                                return InkWell(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: p))),
                                  onLongPress: () => _supprimerPatient(p),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(children: [
                                      PatientAvatar(nom: p.nom, radius: 26, hasBorder: true),
                                      const SizedBox(width: 14),
                                      Expanded(child: Text(p.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kTextMain))),
                                      GestureDetector(
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(patient: p))),
                                        child: Container(
                                          width: 42, height: 42,
                                          decoration: const BoxDecoration(color: kTeal, shape: BoxShape.circle),
                                          child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    ]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
      floatingActionButton: BotButton(),
      bottomNavigationBar: CareBottomNav(currentIndex: 0, onTap: _onNav),
    );
  }

  Widget _vide() => const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.people_outline_rounded, size: 64, color: Color(0xFFCCE8E8)),
    SizedBox(height: 12),
    Text('Aucun patient trouvé', style: TextStyle(color: kTextSub, fontWeight: FontWeight.w600)),
  ]));
}

// ── Dialog ajout patient ──────────────────────────────────────
class _DialogAjout extends StatefulWidget {
  const _DialogAjout();
  @override
  State<_DialogAjout> createState() => _DialogAjoutState();
}

class _DialogAjoutState extends State<_DialogAjout> {
  final _nom    = TextEditingController();
  final _email  = TextEditingController();
  final _taille = TextEditingController();
  final _poids  = TextEditingController();
  final _groupe = TextEditingController();
  final _glyc   = TextEditingController();

  @override
  void dispose() { _nom.dispose(); _email.dispose(); _taille.dispose(); _poids.dispose(); _groupe.dispose(); _glyc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      title: const Text('Nouveau patient', style: TextStyle(fontWeight: FontWeight.w800, color: kTextMain)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _f('Nom complet *', _nom),
        _f('Email', _email, type: TextInputType.emailAddress),
        _f('Taille (m)', _taille, type: TextInputType.number),
        _f('Poids (kg)', _poids, type: TextInputType.number),
        _f('Groupe sanguin', _groupe),
        _f('Glycémie (g/l)', _glyc, type: TextInputType.number),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: kTextSub))),
        ElevatedButton(
          onPressed: () {
            if (_nom.text.trim().isEmpty) return;
            Navigator.pop(context, Patient(
              id: DateTime.now().millisecondsSinceEpoch,
              nom: _nom.text.trim(), email: _email.text.trim(),
              taille: double.tryParse(_taille.text) ?? 1.70,
              poids: double.tryParse(_poids.text) ?? 70,
              groupeSanguin: _groupe.text.trim().isEmpty ? 'O+' : _groupe.text.trim(),
              glycemie: double.tryParse(_glyc.text) ?? 1.0,
            ));
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  Widget _f(String hint, TextEditingController c, {TextInputType? type}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(controller: c, keyboardType: type, decoration: InputDecoration(hintText: hint)),
  );
}