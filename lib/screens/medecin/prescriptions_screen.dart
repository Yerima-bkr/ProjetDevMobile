// lib/screens/medecin/prescriptions_screen.dart
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models.dart';

class PrescriptionsScreen extends StatefulWidget {
  final Patient patient;
  const PrescriptionsScreen({super.key, required this.patient});
  @override State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  bool _chargement = true;
  List<Prescription> _liste = [];

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    // TODO: _liste = await DatabaseService.getPrescriptions(patientId: widget.patient.id);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _liste = [
        Prescription(id: 1, patientId: widget.patient.id, medecinId: Session.id ?? 1, medecinNom: Session.nom ?? 'Médecin', specialite: 'Ophtalmologue', medicament: 'Paracétamol 500mg', message: 'Prendre 3x/jour après les repas.', dateDebut: DateTime(2026, 2, 1),  dateFin: DateTime(2026, 2, 28)),
        Prescription(id: 2, patientId: widget.patient.id, medecinId: Session.id ?? 1, medecinNom: Session.nom ?? 'Médecin', specialite: 'Ophtalmologue', medicament: 'Ibuprofène 400mg',   message: 'En cas de douleur uniquement.',   dateDebut: DateTime(2026, 2, 10), dateFin: DateTime(2026, 3, 10)),
        Prescription(id: 3, patientId: widget.patient.id, medecinId: Session.id ?? 1, medecinNom: Session.nom ?? 'Médecin', specialite: 'Ophtalmologue', medicament: 'Amoxicilline 500mg', message: 'Matin et soir après les repas.',    dateDebut: DateTime(2026, 2, 15), dateFin: DateTime(2026, 2, 22)),
        Prescription(id: 4, patientId: widget.patient.id, medecinId: Session.id ?? 1, medecinNom: Session.nom ?? 'Médecin', specialite: 'Ophtalmologue', medicament: 'Vitamine D3',         message: 'Une dose par semaine.',           dateDebut: DateTime(2026, 1, 1),  dateFin: DateTime(2026, 6, 30)),
      ];
      _chargement = false;
    });
  }

  Future<void> _ajouter() async {
    final result = await showModalBottomSheet<Prescription>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _FormPrescription(patientId: widget.patient.id),
    );
    if (result != null) {
      // TODO: await DatabaseService.insererPrescription(result);
      setState(() => _liste.insert(0, result));
      _snack('Prescription ajoutée');
    }
  }

  Future<void> _supprimer(Prescription p) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      title: const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.w800)),
      content: Text('Supprimer "${p.medicament}" ?', style: const TextStyle(color: kTextSub)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler', style: TextStyle(color: kTextSub))),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: kDanger), child: const Text('Supprimer')),
      ],
    ));
    if (ok == true) {
      // TODO: await DatabaseService.supprimerPrescription(p.id);
      setState(() => _liste.remove(p));
      _snack('Prescription supprimée');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg), backgroundColor: kTeal, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSmall)),
  ));

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Prescriptions du patient', style: TextStyle(fontSize: 12, color: kTextSub, fontWeight: FontWeight.normal)),
          Text(widget.patient.nom, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kTextMain)),
        ]),
        actions: [
          TextButton.icon(
            onPressed: _ajouter,
            icon: const Icon(Icons.add_rounded, color: kTeal),
            label: const Text('Ajouter', style: TextStyle(color: kTeal, fontWeight: FontWeight.w700)),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: kDivider)),
      ),
      body: _chargement
          ? const Center(child: CircularProgressIndicator(color: kTeal))
          : _liste.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.assignment_outlined, size: 64, color: kTextSub.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('Aucune prescription', style: TextStyle(color: kTextSub, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(onPressed: _ajouter, icon: const Icon(Icons.add), label: const Text('Ajouter une prescription')),
                ]))
              : RefreshIndicator(
                  color: kTeal, onRefresh: _charger,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      Container(
                        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadow),
                        child: Column(children: List.generate(_liste.length, (i) {
                          final p = _liste[i];
                          return Column(children: [
                            ListTile(
                              contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.medication_outlined, color: kTeal, size: 22),
                              ),
                              title: Text(p.medicament, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextMain)),
                              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const SizedBox(height: 3),
                                Row(children: [
                                  const Icon(Icons.calendar_today_outlined, size: 11, color: kTextSub),
                                  const SizedBox(width: 4),
                                  Text('${_fmt(p.dateDebut)} → ${_fmt(p.dateFin)}', style: const TextStyle(color: kTextSub, fontSize: 11)),
                                ]),
                                if (p.message.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(p.message, style: const TextStyle(fontSize: 12, color: kTextSub), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ]),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert_rounded, color: kTextSub),
                                onPressed: () => showModalBottomSheet(
                                  context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                  builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
                                    const SizedBox(height: 12),
                                    ListTile(leading: const Icon(Icons.info_outline, color: kTeal), title: Text(p.medicament, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${_fmt(p.dateDebut)} → ${_fmt(p.dateFin)}')),
                                    if (p.message.isNotEmpty) ListTile(leading: const Icon(Icons.message_outlined, color: kTeal), title: Text(p.message)),
                                    ListTile(leading: const Icon(Icons.delete_outline_rounded, color: kDanger), title: const Text('Supprimer', style: TextStyle(color: kDanger, fontWeight: FontWeight.w600)), onTap: () { Navigator.pop(context); _supprimer(p); }),
                                    const SizedBox(height: 8),
                                  ]),
                                ),
                              ),
                            ),
                            if (i < _liste.length - 1) const Divider(height: 1, color: kDivider, indent: 76),
                          ]);
                        })),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ─── Formulaire ajout prescription (bottom sheet) ─────────────
class _FormPrescription extends StatefulWidget {
  final int patientId;
  const _FormPrescription({required this.patientId});
  @override State<_FormPrescription> createState() => _FormPrescriptionState();
}

class _FormPrescriptionState extends State<_FormPrescription> {
  final _med = TextEditingController();
  final _msg = TextEditingController();
  DateTime? _debut, _fin;
  String? _err;

  Future<void> _pick(bool isDebut) async {
    final d = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime(2020), lastDate: DateTime(2035),
      builder: (c, child) => Theme(data: Theme.of(c).copyWith(colorScheme: const ColorScheme.light(primary: kTeal)), child: child!),
    );
    if (d != null) setState(() => isDebut ? _debut = d : _fin = d);
  }

  String _fd(DateTime? d) => d == null ? 'Sélectionner' : '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  @override
  void dispose() { _med.dispose(); _msg.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: kDivider, borderRadius: BorderRadius.circular(2))),
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.assignment_outlined, color: kTeal, size: 20)),
            const SizedBox(width: 10),
            const Text('Prescription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextMain)),
          ]),
          const SizedBox(height: 20),
          TextField(controller: _med, decoration: const InputDecoration(hintText: 'Médicament *', prefixIcon: Icon(Icons.medication_outlined, color: kTeal, size: 20))),
          const SizedBox(height: 12),
          TextField(controller: _msg, maxLines: 3, decoration: const InputDecoration(hintText: 'Message du médecin pour le patient...')),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('Période :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextMain))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _BtnDate('Début', _fd(_debut), () => _pick(true))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('→', style: TextStyle(color: kTeal, fontWeight: FontWeight.w700, fontSize: 20))),
            Expanded(child: _BtnDate('Fin', _fd(_fin), () => _pick(false))),
          ]),
          if (_err != null) Padding(padding: const EdgeInsets.only(top: 10),
            child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: kDangerLight, borderRadius: BorderRadius.circular(kRadiusSmall)),
              child: Text(_err!, style: const TextStyle(color: kDanger, fontSize: 12)))),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: kTeal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusBtn)), padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: kTeal, fontWeight: FontWeight.w700)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                if (_med.text.trim().isEmpty || _debut == null || _fin == null) {
                  setState(() => _err = 'Médicament et période obligatoires.'); return;
                }
                Navigator.pop(context, Prescription(
                  id: DateTime.now().millisecondsSinceEpoch,
                  patientId: widget.patientId,
                  medecinId: Session.id ?? 1,
                  medecinNom: Session.nom ?? 'Médecin',
                  specialite: 'Médecin traitant',
                  medicament: _med.text.trim(),
                  message: _msg.text.trim(),
                  dateDebut: _debut!, dateFin: _fin!,
                ));
              },
              child: const Text('Prescrire'),
            )),
          ]),
        ])),
      ),
    );
  }
}

class _BtnDate extends StatelessWidget {
  final String label, val;
  final VoidCallback onTap;
  const _BtnDate(this.label, this.val, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: kTeal), borderRadius: BorderRadius.circular(kRadiusSmall), color: kTealLight),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: kTextSub, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: kTealDark)),
      ]),
    ),
  );
}