import "package:flutter/material.dart";
import "../constants.dart";


class BotButton extends StatelessWidget{

  const BotButton({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(heroTag: 'bot', backgroundColor: kTeal, elevation: 4, mini: true, onPressed: () {Navigator.pushNamed(context, '/patient/bot');}, child: const Icon(Icons.smart_toy_rounded, color: Colors.white)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: kShadowLight),
              child: const Text('Vous avez une question ?', style: TextStyle(fontSize: 12, color: kTextSub))),
          const SizedBox(width: 8),
        ]));
  }
    }



