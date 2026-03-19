// lib/screens/medecin/chat_screen.dart  — Écrans 7 & 8
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../utils/messagesApi.dart';
import '../../widgets/patient_avatar.dart';

class ChatScreen extends StatefulWidget {
  final Patient patient;
  const ChatScreen({super.key, required this.patient});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _chargement = true;
  List<Message> _msgs = [];
  static String? chatBg;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {

    final messages = Hive.box("UserMessages");

    List<Message> distantMessages = [];

    distantMessages = await getMessages(widget.patient.id, Session.id!);

    _msgs = messages.get("MessagesOf${Session.id}And${widget.patient.id}") != null ? messages.get("MessagesOf${Session.id}And${widget.patient.id}")?.cast<Message>() : _msgs;

    if(distantMessages.length > _msgs.length)
    {
      for(int i = _msgs.length; i < distantMessages.length; i++)
      {
        _msgs.add(distantMessages[i]);
      }
    }

    /*_msgs = [
      Message(id: 1, patientId: widget.patient.id, medecinId: 1, expediteur: 'medecin',
        texte: 'Bonjour, j\'aimerais savoir lkhfkjhkjdfhkjsdhfhsgdhfbsbhsdbcsbdsybdfysdfskjdfsbdfbsdfjhsbjdhbfjsdbfhsbdjfsbhdjfbhsdjfhbsdjfhbsjdfh.',
        dateEnvoi: DateTime(2026, 2, 26, 17, 0)),
      Message(id: 2, patientId: widget.patient.id, medecinId: 1, expediteur: 'patient',
        texte: 'Bonjour, j\'aimerais savoir lkhfkjhkjdfhkjsdhfhsgdhfbsbhsdbcsbdsybdfysdfskjdfsbdfbsdfjhsbjdhbfjsdbfhsbdjfsbhdjfbhsdjfhbsdjfhbsjdfh.',
        dateEnvoi: DateTime(2026, 2, 26, 21, 17)),
    ];*/


    setState(() => _chargement = false);
    _scrollBas();
  }

  void _scrollBas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  void _envoyer() async{

    final messages = Hive.box("UserMessages");

    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    final m = Message(id: DateTime.now().millisecondsSinceEpoch, patientId: Session.id ?? 1, medecinId: widget.patient.id, expediteur: 'medecin', texte: t, dateEnvoi: DateTime.now());

    bool res = await sendMessage(m);

    if(res == true)
    {
      setState(() => _msgs.add(m));

      messages.put("MessagesOf${Session.id}And${widget.patient.id}", _msgs);
    }
    else
    {
      print('An error occured while sending message.');
    }

    _ctrl.clear();
    _scrollBas();
  }

  Future<void> _ouvrirPrescription() async {
    final result = await showDialog<Prescription>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogPrescription(patientId: widget.patient.id),
    );
    if (result != null) {
      // TODO: await DatabaseService.insererPrescription(result);
      final msg = Message(id: DateTime.now().millisecondsSinceEpoch, patientId: widget.patient.id, medecinId: 1, expediteur: 'medecin',
        texte: '📋 Prescription envoyée\n💊 ${result.medicament}\n📝 ${result.message}', dateEnvoi: DateTime.now());
      setState(() => _msgs.add(msg));
      _scrollBas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Prescription envoyée au patient'),
        backgroundColor: kTeal, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSmall)),
      ));
      }
    }
  }

  String _heure(DateTime d) => '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(),
        title: Row(children: [
          PatientAvatar(nom: widget.patient.nom, radius: 20, hasBorder: true),
          const SizedBox(width: 10),
          Text(widget.patient.nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(2), child: Container(height: 2, color: kTeal)),
      ),
      body: Stack(children: [
        Positioned.fill(child: chatBg != null
            ? Image.asset(chatBg!, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: const Color(0xFFE8F4F4)))
            : Container(color: const Color(0xFFE8F4F4))),
        Column(children: [
          Expanded(child: _chargement
              ? const Center(child: CircularProgressIndicator(color: kTeal))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: _msgs.length,
                  itemBuilder: (_, i) => _Bulle(msg: _msgs[i], heure: _heure(_msgs[i].dateEnvoi)),
                )),
          Container(
            color: Colors.white.withOpacity(0.97),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SafeArea(top: false, child: Row(children: [
              GestureDetector(
                onTap: _ouvrirPrescription,
                child: Container(width: 48, height: 48, decoration: BoxDecoration(color: kTeal, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 22)),
              ),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _envoyer(),
                decoration: InputDecoration(
                  hintText: 'Message', fillColor: const Color(0xFFF0F4F4), filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: kTeal, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _envoyer,
                child: Container(width: 48, height: 48, decoration: BoxDecoration(color: kTeal, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 22)),
              ),
            ])),
          ),
        ]),
      ]),
    );
  }
}

class _Bulle extends StatelessWidget {
  final Message msg;
  final String heure;
  const _Bulle({required this.msg, required this.heure});
  @override
  Widget build(BuildContext context) {
    final isMed = msg.expediteur == 'medecin';
    return Align(
      alignment: isMed ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMed ? kTeal : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMed ? 18 : 4),
            bottomRight: Radius.circular(isMed ? 4 : 18),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6)],
        ),

        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(msg.texte, style: TextStyle(color: isMed ? Colors.white : kTextMain, fontSize: 14, height: 1.4)),
          const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(heure, style: TextStyle(fontSize: 10, color: isMed ? Colors.white60 : kTextSub)),
            //if (isMed) ...[const SizedBox(width: 4), const Icon(Icons.done_all_rounded, size: 13, color: Colors.white60)],
          ]),
        ]),
      ),
    );
  }
}

// ── Dialog Prescription avec calendrier interactif ─────────────
class _DialogPrescription extends StatefulWidget {
  final int patientId;
  const _DialogPrescription({required this.patientId});
  @override
  State<_DialogPrescription> createState() => _DialogPrescriptionState();
}

class _DialogPrescriptionState extends State<_DialogPrescription> {
  final _med = TextEditingController();
  final _msg = TextEditingController();
  DateTime? _debut, _fin;
  late DateTime _moisAffiche;
  bool _choixDebut = true;
  String? _err;
  static const _jours = ['Su','Mo','Tu','We','Th','Fr','Sa'];
  static const _moisN = ['January','February','March','April','May','June','July','August','September','October','November','December'];

  @override
  void initState() { super.initState(); _moisAffiche = DateTime(DateTime.now().year, DateTime.now().month); }
  @override
  void dispose() { _med.dispose(); _msg.dispose(); super.dispose(); }

  bool _dansSelection(DateTime d) {
    if (_debut == null || _fin == null) return false;
    return !d.isBefore(_debut!) && !d.isAfter(_fin!);
  }

  void _tapJour(DateTime d) => setState(() {
    if (_choixDebut) { _debut = d; _fin = null; _choixDebut = false; }
    else {
      if (d.isBefore(_debut!)) { _fin = _debut; _debut = d; } else { _fin = d; }
      _choixDebut = true;
    }
  });

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final premier = DateTime(_moisAffiche.year, _moisAffiche.month, 1);
    final dernier = DateTime(_moisAffiche.year, _moisAffiche.month + 1, 0);
    final offset  = premier.weekday % 7;
    final lignes  = ((offset + dernier.day) / 7).ceil();
    final auj     = DateTime.now();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(child: Text('Prescription', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kTextMain))),
          const SizedBox(height: 20),
          const Text('Médicament :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextMain)),
          const SizedBox(height: 8),
          TextField(controller: _med, decoration: const InputDecoration(hintText: 'Nom du médicament')),
          const SizedBox(height: 14),
          const Text('Message du médecin :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextMain)),
          const SizedBox(height: 8),
          TextField(controller: _msg, maxLines: 3, decoration: const InputDecoration(hintText: 'Message accompagnant la prescription pour le patient.')),
          const SizedBox(height: 16),
          const Text('Période :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextMain)),
          const SizedBox(height: 4),
          Text(
            _debut == null ? 'Sélectionnez le début puis la fin' : (_fin == null ? 'Sélectionnez la date de fin' : 'Du ${_fmt(_debut!)} au ${_fmt(_fin!)}'),
            style: TextStyle(fontSize: 12, color: _debut == null ? kTextSub : kTealDark, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          // Calendrier
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(kRadiusSmall), border: Border.all(color: kTeal, width: 1.5)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${_moisN[_moisAffiche.month - 1]} ${_moisAffiche.year}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: kTealDark)),
                Row(children: [
                  GestureDetector(onTap: () => setState(() => _moisAffiche = DateTime(_moisAffiche.year, _moisAffiche.month - 1)), child: const Icon(Icons.arrow_drop_up, color: kTealDark, size: 24)),
                  GestureDetector(onTap: () => setState(() => _moisAffiche = DateTime(_moisAffiche.year, _moisAffiche.month + 1)), child: const Icon(Icons.arrow_drop_down, color: kTealDark, size: 24)),
                ]),
              ]),
              const SizedBox(height: 8),
              Row(children: _jours.map((j) => Expanded(child: Center(child: Text(j, style: const TextStyle(fontSize: 11, color: kTealDark, fontWeight: FontWeight.w600))))).toList()),
              const SizedBox(height: 4),
              ...List.generate(lignes, (ligne) => Row(children: List.generate(7, (col) {
                final idx  = ligne * 7 + col;
                final jour = idx - offset + 1;
                if (jour < 1 || jour > dernier.day) return const Expanded(child: SizedBox(height: 30));
                final date    = DateTime(_moisAffiche.year, _moisAffiche.month, jour);
                final sel     = _dansSelection(date);
                final debutOk = _debut != null && date.isAtSameMomentAs(_debut!);
                final finOk   = _fin   != null && date.isAtSameMomentAs(_fin!);
                final estAuj  = date.year == auj.year && date.month == auj.month && date.day == auj.day;
                Color? bg;
                if (debutOk || finOk) {
                  bg = kTealDark;
                } else if (sel) bg = kTeal;
                else if (estAuj) bg = kTeal.withOpacity(0.3);
                return Expanded(child: GestureDetector(
                  onTap: () => _tapJour(date),
                  child: Container(
                    margin: const EdgeInsets.all(1.5), height: 30,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                    child: Center(child: Text('$jour', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: bg != null ? Colors.white : Colors.black54))),
                  ),
                ));
              }))),
            ]),
          ),
          if (_err != null) ...[const SizedBox(height: 10), Text(_err!, style: const TextStyle(color: kDanger, fontSize: 12))],
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ElevatedButton(
              onPressed: () {
                if (_med.text.trim().isEmpty) { setState(() => _err = 'Médicament obligatoire.'); return; }
                if (_debut == null || _fin == null) { setState(() => _err = 'Sélectionnez la période.'); return; }
                Navigator.pop(context, Prescription(
                  id: DateTime.now().millisecondsSinceEpoch,
                  patientId: widget.patientId, medecinId: Session.id ?? 1,
                  medecinNom: Session.nom ?? 'Médecin', specialite: 'Médecin traitant',
                  medicament: _med.text.trim(), message: _msg.text.trim(),
                  dateDebut: _debut!, dateFin: _fin!,
                ));
              },
              child: const Text('Prescrire'),
            )),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: kTeal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusBtn)), padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: kTeal, fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }
}