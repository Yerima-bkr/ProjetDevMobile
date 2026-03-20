// lib/screens/patient/chat_patient_screen.dart  — Écran 12
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../utils/messagesApi.dart';
import '../../widgets/patient_avatar.dart';

class ChatPatientScreen extends StatefulWidget {
  final Medecin medecin;
  const ChatPatientScreen({super.key, required this.medecin});
  @override
  State<ChatPatientScreen> createState() => _ChatPatientScreenState();
}

class _ChatPatientScreenState extends State<ChatPatientScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _chargement = true;
  List<Message> _msgs = [];

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {

    setState(() => _chargement = true);

    final messages = Hive.box("UserMessages");

    List<Message> distantMessages = [];

    distantMessages = await getMessages(Session.id ?? 0, widget.medecin.id);

    _msgs = messages.get("MessagesOf${Session.id}And${widget.medecin.id}") != null ? messages.get("MessagesOf${Session.id}And${widget.medecin.id}")?.cast<Message>() : _msgs;

    if(distantMessages.isNotEmpty && distantMessages.length > _msgs.length)
    {
      for(int i = _msgs.length; i < distantMessages.length; i++)
        {
         setState(() {
           _msgs.add(distantMessages[i]);
         });
        }
    }
    else
      {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Pas de nouveaux messages.")));
        }
      }

    setState(() => _chargement = false);
    _scrollBas();
  }

  void _scrollBas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  void _envoyer() async{

    setState(() => _chargement = true);

    final messages = Hive.box("UserMessages");

    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    final m = Message(id: DateTime.now().millisecondsSinceEpoch, patientId: Session.id ?? 0, medecinId: widget.medecin.id, expediteur: 'patient', texte: t, dateEnvoi: DateTime.now());

    bool res = await sendMessage(m);

    setState(() => _msgs.add(m));

    if(res == true)
      {
        setState(() => _chargement = false);

        messages.put("MessagesOf${Session.id}And${widget.medecin.id}", _msgs);

        _ctrl.clear();
        _scrollBas();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Message envoyé.")));
        }
      }
    else {

      setState((){_chargement = false; _msgs.remove(m);});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Erreur lors de l'envoi du message.")));
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
          PatientAvatar(nom: widget.medecin.nom, radius: 20, hasBorder: true),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.medecin.nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kTextMain)),
            Text(widget.medecin.specialite, style: const TextStyle(fontSize: 12, color: kTextSub, fontWeight: FontWeight.normal)),
          ]),
        ]),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(2), child: Container(height: 2, color: kTeal)),
      ),
      body: Stack(children: [
        // Fond d'écran
        Positioned.fill(child: chatBackground != null
            ? Image.file(File(chatBackground!), errorBuilder: (_, _, _) => Container(color: const Color(0xFFE8F4F4)))
            : Container(color: const Color(0xFFE8F4F4))),

        Column(children: [
          Expanded(child: _chargement
              ? const Center(child: CircularProgressIndicator(color: kTeal))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: _msgs.length,
                  itemBuilder: (_, i) {
                    final m = _msgs[i];
                    final isPatient = m.expediteur == 'patient';
                    return Align(
                      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isPatient ? kTeal : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isPatient ? 18 : 4),
                            bottomRight: Radius.circular(isPatient ? 4 : 18),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6)],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(m.texte, style: TextStyle(color: isPatient ? Colors.white : kTextMain, fontSize: 14, height: 1.4)),
                          const SizedBox(height: 4),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(_heure(m.dateEnvoi), style: TextStyle(fontSize: 10, color: isPatient ? Colors.white60 : kTextSub)),
                            //if (isPatient) ...[const SizedBox(width: 4), const Icon(Icons.done_all_rounded, size: 13, color: Colors.white60)],
                          ]),
                        ]),
                      ),
                    );
                  },
                )),

          Container(
            color: Colors.white.withOpacity(0.97),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SafeArea(top: false, child: Row(children: [
              Expanded(child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _envoyer(),
                decoration: InputDecoration(
                  hintText: 'Message',
                  fillColor: const Color(0xFFF0F4F4), filled: true,
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