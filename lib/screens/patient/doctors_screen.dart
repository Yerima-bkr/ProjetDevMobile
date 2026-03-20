// lib/screens/patient/doctors_screen.dart  — Écrans 10 & 11
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:suivie/utils/messagesApi.dart';
import 'package:suivie/widgets/bot_help_button.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../widgets/care_bottom_nav.dart';
import '../../widgets/patient_avatar.dart';
import 'patient_home_screen.dart';
import 'chat_patient_screen.dart';
import 'prescriptions_patient_screen.dart';
import 'settings_patient_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});
  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final _searchCtrl = TextEditingController();
  bool _chargement  = false;
  bool _aRecherche  = false;
  bool _showFiltres = false;
  final List<Medecin> _contactes = [];
  List<Medecin> _resultats = [];
  String _specialiteChoisie = 'Toutes';
  List<String> _specialites = ['Toutes', /*'Ophtalmologue', 'Psychiatre', 'Généraliste', 'Cardiologue', 'Pédiatre'*/];
  List<Medecin> tous = [
    /*Medecin(id: 1, nom: 'Edouard Newgate',  email: 'enewgate@care.com',  specialite: 'Ophtalmologue'),
    Medecin(id: 2, nom: 'Marshall D Teech', email: 'mteech@care.com',    specialite: 'Psychiatre'),
    Medecin(id: 3, nom: 'Scratchmen Apoo',  email: 'sapoo@care.com',     specialite: 'Psychiatre'),
    Medecin(id: 4, nom: 'Usopp',            email: 'usopp@care.com',     specialite: 'Ophtalmologue'),*/
  ];

  @override
  void initState() { super.initState(); _chargerContactes(); }

  Future<void> _chargerContactes() async {

    setState(() { _chargement = true;});

    tous = await getMedecins();

    if(tous.isNotEmpty) {
      for (int i = 0; i < tous.length; i++) {
        if (_specialites.contains(tous[i].specialite)) {
          continue;
        }

        _specialites.add(tous[i].specialite);
      }
    }

    // ════════════════════════════════════════════════════════
    // TODO: _contactes = await DatabaseService.getMedecinsContactes(Session.id);
    //await Future.delayed(const Duration(milliseconds: 300));

    final messages = Hive.box("UserMessages");

    Message? m;

    for(int i = 0; i < tous.length; i++)
      {
        if(messages.get("MessagesOf${Session.id}And${tous[i].id}") == null)
          {
            continue;
          }

        List<Message> list = messages.get("MessagesOf${Session.id}And${tous[i].id}").cast<Message>();

        if(list.isNotEmpty)
          {
            m = list.last;
          }

        if(m == null)
          {
            _contactes.add(tous[i]);
          }
        else
          {
            if(m.dateEnvoi.compareTo(list.last.dateEnvoi) == -1)
              {
                _contactes.insert(0, tous[i]);
              }
            else
              {
                _contactes.add(tous[i]);
              }
          }
      }
    // ════════════════════════════════════════════════════════
    //setState(() {});

    setState(() { _chargement = false;});
  }

  Future<void> _rechercher() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty && _specialiteChoisie == 'Toutes') {
      setState(() { _resultats = []; _aRecherche = false; }); return;
    }
    setState(() { _chargement = true; _aRecherche = true; });
    // ════════════════════════════════════════════════════════
    // TODO: _resultats = await DatabaseService.rechercherMedecins(q, _specialiteChoisie == 'Toutes' ? null : _specialiteChoisie);
    await Future.delayed(const Duration(milliseconds: 500));
    _resultats = tous.where((m) {
      final matchQ  = q.isEmpty || m.nom.toLowerCase().contains(q.toLowerCase()) || m.specialite.toLowerCase().contains(q.toLowerCase());
      final matchSp = _specialiteChoisie == 'Toutes' || m.specialite == _specialiteChoisie;
      return matchQ && matchSp;
    }).toList();
    // ════════════════════════════════════════════════════════
    setState(() => _chargement = false);
  }

  void _onNav(int i) {
    switch (i) {
      case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PatientHomeScreen())); break;
      case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PrescriptionsPatientScreen())); break;
      case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsPatientScreen())); break;
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Widget _medecinTile(Medecin m) => InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPatientScreen(medecin: m))),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        PatientAvatar(nom: m.nom, radius: 28, hasBorder: true),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kTextMain)),
          Text(m.specialite, style: const TextStyle(color: kTextSub, fontSize: 13)),
        ])),
        const Icon(Icons.play_arrow_rounded, color: kTeal, size: 26),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final liste   = _aRecherche ? _resultats : _contactes;
    final msgVide = _aRecherche ? 'Aucun médecin trouvé...' : 'Vous n\'avez contacté aucun medecin...';

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Besoin d\'un medecin ?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextMain)),
              const SizedBox(height: 16),

              // Barre de recherche
              Row(children: [
                Expanded(child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _rechercher(),
                  decoration: const InputDecoration(hintText: 'Nom ou spécialité du medecin', prefixIcon: Icon(Icons.search_rounded, color: kTextSub)),
                )),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _rechercher,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(color: kTeal, borderRadius: BorderRadius.circular(kRadiusSmall)),
                    child: const Text('Rechercher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
              ]),
              const SizedBox(height: 10),

              // Filtre spécialité
              GestureDetector(
                onTap: () => setState(() => _showFiltres = !_showFiltres),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  decoration: BoxDecoration(color: const Color(0xFFF5F8F8), borderRadius: BorderRadius.circular(kRadiusBtn), border: Border.all(color: const Color(0xFFE0EEEE))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(_specialiteChoisie == 'Toutes' ? 'Spécialité du medecin' : _specialiteChoisie,
                        style: TextStyle(color: _specialiteChoisie == 'Toutes' ? kTextSub : kTextMain, fontSize: 14)),
                    Icon(_showFiltres ? Icons.arrow_drop_up : Icons.play_arrow_rounded, color: kTeal, size: 22),
                  ]),
                ),
              ),

              if (_showFiltres) Container(
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(kRadiusSmall), boxShadow: kShadow),
                child: Column(children: _specialites.map((s) => InkWell(
                  onTap: () { setState(() { _specialiteChoisie = s; _showFiltres = false; }); _rechercher(); },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(s, style: TextStyle(fontWeight: _specialiteChoisie == s ? FontWeight.w700 : FontWeight.normal, color: _specialiteChoisie == s ? kTeal : kTextMain)),
                      if (_specialiteChoisie == s) const Icon(Icons.check_rounded, color: kTeal, size: 16),
                    ]),
                  ),
                )).toList()),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Liste
          Expanded(
            child: _chargement
                ? const Center(child: CircularProgressIndicator(color: kTeal))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
                      child: liste.isEmpty
                          ? Center(child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text(msgVide, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextSub), textAlign: TextAlign.center),
                            ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(kRadius),
                              child: ListView.separated(
                                itemCount: liste.length,
                                separatorBuilder: (_, _) => const Divider(height: 1, color: kDivider, indent: 76),
                                itemBuilder: (_, i) => _medecinTile(liste[i]),
                              ),
                            ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
      floatingActionButton: BotButton(),
      bottomNavigationBar: CareBottomNavPatient(currentIndex: 1, onTap: _onNav),
    );
  }
}