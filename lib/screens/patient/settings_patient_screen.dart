// lib/screens/patient/settings_patient_screen.dart  — Écran 16
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../widgets/care_bottom_nav.dart';
import '../auth/login_screen.dart';
import 'patient_home_screen.dart';
import 'doctors_screen.dart';
import 'prescriptions_patient_screen.dart';
import 'auth_screen.dart';

class SettingsPatientScreen extends StatefulWidget {
  const SettingsPatientScreen({super.key});
  @override
  State<SettingsPatientScreen> createState() => _SettingsPatientScreenState();
}

class _SettingsPatientScreenState extends State<SettingsPatientScreen> {
  bool _fondOuvert = false;

  void _onNav(int i) {
    switch (i) {
      case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PatientHomeScreen())); break;
      case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DoctorsScreen())); break;
      case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PrescriptionsPatientScreen())); break;
    }
  }

  Future<void> _deconnexion() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        title: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(color: kTextSub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler', style: TextStyle(color: kTextSub))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kDanger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusBtn))),
              onPressed: () => Navigator.pop(context, true), child: const Text('Déconnexion')),
        ],
      ),
    );
    if (ok == true) {
      // TODO: await AuthService.logout();
      Session.deconnecter();
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Paramètres', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextMain)),
            const SizedBox(height: 24),

            // Logo
            const Center(child: Column(children: [
              Icon(Icons.water_drop, size: 60, color: kTeal),
              Text('CARE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kTeal, letterSpacing: 8)),
            ])),
            const SizedBox(height: 28),

            // Gestion de compte
            Container(
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
              child: ListTile(
                leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.manage_accounts_outlined, color: kTeal, size: 20)),
                title: const Text('Gestion de compte', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: kTextMain)),
                trailing: const Icon(Icons.chevron_right_rounded, color: kTextSub),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
              ),
            ),
            const SizedBox(height: 10),

            // Fond d'écran du chat
            Container(
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(kRadius), boxShadow: kShadowLight),
              child: Column(children: [
                ListTile(
                  leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.brush_outlined, color: kTeal, size: 20)),
                  title: const Text('Fond d\'écran du chat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: kTextMain)),
                  trailing: GestureDetector(
                    onTap: () => setState(() => _fondOuvert = !_fondOuvert),
                    child: AnimatedRotation(
                      turns: _fondOuvert ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.play_arrow_rounded, color: kTeal, size: 26),
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
                  onTap: () => setState(() => _fondOuvert = !_fondOuvert),
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _fondOuvert ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(children: [
                      const Divider(color: kDivider),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kRadiusSmall),
                        child: chatBackground != null
                            ? Image.asset(chatBackground!, height: 160, width: double.infinity, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(height: 160, color: const Color(0xFFE8F4F4), child: const Center(child: Icon(Icons.image_outlined, size: 40, color: kTextSub))))
                            : Container(height: 160, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFE8F4F4), borderRadius: BorderRadius.circular(kRadiusSmall)),
                                child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.wallpaper_rounded, size: 40, color: kTeal),
                                  SizedBox(height: 8),
                                  Text('Fond par défaut', style: TextStyle(color: kTealDark, fontWeight: FontWeight.w600)),
                                ]))),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: kTeal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusBtn)), padding: const EdgeInsets.symmetric(vertical: 14)),
                          // TODO: utiliser image_picker pour choisir depuis la galerie
                          onPressed: () {
                            setState(() => chatBackground = null);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text('Fond remis par défaut'),
                              backgroundColor: kTeal, behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSmall)),
                            ));
                          },
                          icon: const Icon(Icons.image_search_rounded, color: kTeal),
                          label: const Text('Changer le fond d\'écran', style: TextStyle(color: kTeal, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  ) : const SizedBox.shrink(),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // Déconnexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: kDangerLight, foregroundColor: kDanger,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)), elevation: 0),
                onPressed: _deconnexion,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ]),
        ),
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
      bottomNavigationBar: CareBottomNavPatient(currentIndex: 3, onTap: _onNav),
    );
  }
}