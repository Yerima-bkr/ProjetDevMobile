// lib/screens/patient/chat_patient_screen.dart  — Écran 12
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../widgets/patient_avatar.dart';

class ChatBotScreen extends StatefulWidget {

  const ChatBotScreen({super.key});
  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _chargement = true;
  List<BotMessage> _msgs = [];

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {

    final botMessages = Hive.box("BotMessages");

    if(botMessages.isEmpty)
      {
        _msgs = [
          BotMessage(id: DateTime.now().millisecondsSinceEpoch, texte: ""
              "Voici les questions auxquelles je peux repondre : "
              "\n"
              "1 : Qui sommes nous ?\n"
              "2 : A quoi sert le logiciel CARE ?\n"
              "3 : Les services à travers CARE sont-ils gratuits ?\n"
              "\n"
              "Envoyer le numéro correspondant à votre question.\n"
              "\n"
              "NB : Tout autre message sera ignoré, je ne suis qu'un bot...\n"
              "", expediteur: "Bot", dateEnvoi: DateTime.now()),

        ];

        botMessages.put("ListOfBotMessages", _msgs);
      }
    else
      {
        _msgs = botMessages.get("ListOfBotMessages").cast<BotMessage>();
      }

    // TODO: _msgs = await DatabaseService.getMessages(Session.id!, widget.medecin.id);
    //await Future.delayed(const Duration(milliseconds: 300));

    // ════════════════════════════════════════════════════════
    setState(() => _chargement = false);
    _scrollBas();
  }

  void _scrollBas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  void _envoyer() {

    final botMessages = Hive.box("BotMessages");

    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    final m = BotMessage(id: DateTime.now().millisecondsSinceEpoch, expediteur: 'patient', texte: t, dateEnvoi: DateTime.now());

    setState(() => _msgs.add(m));


    //Future.delayed(const Duration(seconds: 2), (){})

      if(t.contains('1'))
      {
        _msgs.add(
            BotMessage(id: DateTime.now().millisecondsSinceEpoch, texte: ""
                "CARE est un logiciel mobile dévéloppé par un groupe d'élève de l'institut universitaire de technologie de ngaoundere, \n"
                "dans le cadre du cours de développement mobile."
                "", expediteur: "Bot", dateEnvoi: DateTime.now()));
      }
      else if (t.contains('2'))
      {
        _msgs.add(
            BotMessage(id: DateTime.now().millisecondsSinceEpoch, texte: ""
                "CARE est un logiciel mobile permettant à ses utilisateurs de bénéficier d'un suivi professionnel de leur état de santé, \n"
                "à travers les différents personnels soignant mis à leur disposition, avec qui ils peuvent échanger à travers un chat."
                "", expediteur: "Bot", dateEnvoi: DateTime.now()));

      }
      else if (t.contains('3'))
      {
        _msgs.add(
            BotMessage(id: DateTime.now().millisecondsSinceEpoch, texte: ""
                "Tout à fait, CARE est un service gratuit dépendant de la bonne volonté des personnels soignant avec qui vous pouvez échanger."
                "", expediteur: "Bot", dateEnvoi: DateTime.now()));

      }
      else
      {
        _msgs.add(
            BotMessage(id: DateTime.now().millisecondsSinceEpoch, texte: ""
                "Voici les questions auxquelles je peux repondre : "
                "\n"
                "1 : Qui sommes nous ?\n"
                "2 : A quoi sert le logiciel CARE ?\n"
                "3 : Les services à travers CARE sont-ils gratuits ?\n"
                "\n"
                "Envoyer le numéro correspondant à votre question.\n"
                "\n"
                "NB : Tout autre message sera ignoré, je ne suis qu'un bot...\n"
                "", expediteur: "Bot", dateEnvoi: DateTime.now()));

      }

      botMessages.put("ListOfBotMessages", _msgs);

    _ctrl.clear();
    _scrollBas();

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
          PatientAvatar(nom: "CareBot", radius: 20, hasBorder: true),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("CareBot", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kTextMain)),
            Text("Assistant", style: const TextStyle(fontSize: 12, color: kTextSub, fontWeight: FontWeight.normal)),
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