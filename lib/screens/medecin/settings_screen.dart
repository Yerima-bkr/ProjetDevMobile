// lib/screens/medecin/settings_screen.dart
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../widgets/care_bottom_nav.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deconnexion(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        title: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(color: kTextSub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler', style: TextStyle(color: kTextSub))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kDanger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusBtn))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (ok == true) {
      Session.deconnecter();
      if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(children: [
            const Column(children: [
              SizedBox(height: 10),
              Icon(Icons.water_drop, size: 60, color: kTeal),
              Text('CARE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kTeal, letterSpacing: 8)),
            ]),
            const SizedBox(height: 6),
            Text(Session.nom ?? '', style: const TextStyle(color: kTextSub, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 28),
            ...[
              {'icon': Icons.manage_accounts_outlined, 'label': 'Gestion de compte'},
              {'icon': Icons.notifications_none_rounded, 'label': 'Notifications'},
              {'icon': Icons.palette_outlined, 'label': 'Apparence'},
              {'icon': Icons.lock_outline_rounded, 'label': 'Sécurité'},
              {'icon': Icons.info_outline_rounded, 'label': 'À propos de CARE'},
            ].map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
              child: ListTile(
                leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(10)),
                    child: Icon(item['icon'] as IconData, color: kTeal, size: 20)),
                title: Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: kTextMain)),
                trailing: const Icon(Icons.chevron_right_rounded, color: kTextSub),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
                onTap: () {},
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: kDangerLight, foregroundColor: kDanger,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)), elevation: 0),
                onPressed: () => _deconnexion(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: CareBottomNav(currentIndex: 2, onTap: (i) { if (i == 0) Navigator.pop(context); }),
    );
  }
}