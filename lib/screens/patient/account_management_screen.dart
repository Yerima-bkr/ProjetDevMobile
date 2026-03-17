// lib/screens/patient/account_management_screen.dart  — Écran 18
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models.dart';
import '../auth/login_screen.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});
  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  late final TextEditingController _nomCtrl;
  late final TextEditingController _emailCtrl;
  final _mdpCtrl  = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _mdpVisible  = false;
  bool _confVisible = false;
  bool _loading     = false;
  String? _erreur;
  String? _succes;

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec les données de la session
    _nomCtrl   = TextEditingController(text: Session.nom ?? '');
    _emailCtrl = TextEditingController(text: Session.email ?? '');
  }

  Future<void> _modifier() async {
    final nom  = _nomCtrl.text.trim();
    final email= _emailCtrl.text.trim();
    final mdp  = _mdpCtrl.text.trim();
    final conf = _confCtrl.text.trim();

    if (nom.isEmpty || email.isEmpty) { setState(() => _erreur = 'Nom et email obligatoires.'); return; }
    if (mdp.isNotEmpty && mdp != conf) { setState(() => _erreur = 'Les mots de passe ne correspondent pas.'); return; }
    if (mdp.isNotEmpty && mdp.length < 6) { setState(() => _erreur = 'Mot de passe trop court (6 min).'); return; }

    setState(() { _loading = true; _erreur = null; _succes = null; });

    // ════════════════════════════════════════════════════════
    // TODO: await DatabaseService.modifierPatient(Session.id, nom, email, mdp.isEmpty ? null : mdp);
    await Future.delayed(const Duration(milliseconds: 700));
    Session.connecter(id: Session.id!, nom: nom, email: email, role: Session.role!);
    // ════════════════════════════════════════════════════════

    setState(() { _loading = false; _succes = 'Compte mis à jour avec succès ✓'; _mdpCtrl.clear(); _confCtrl.clear(); });
  }

  Future<void> _supprimer() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        title: const Text('Supprimer le compte', style: TextStyle(fontWeight: FontWeight.w800, color: kDanger)),
        content: const Text('Cette action est irréversible.\nVoulez-vous vraiment supprimer votre compte ?', style: TextStyle(color: kTextSub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler', style: TextStyle(color: kTextSub))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kDanger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusBtn))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // TODO: await DatabaseService.supprimerPatient(Session.id);
      Session.deconnecter();
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  @override
  void dispose() { _nomCtrl.dispose(); _emailCtrl.dispose(); _mdpCtrl.dispose(); _confCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, leading: const BackButton(), elevation: 0,
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: kDivider))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('👋 Content de vous revoir!', style: TextStyle(color: kTextSub, fontSize: 13)),
            const SizedBox(height: 4),
            Text(Session.nom ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextMain)),
            const SizedBox(height: 32),

            // Champs
            TextField(controller: _nomCtrl, textInputAction: TextInputAction.next, decoration: const InputDecoration(hintText: 'Nom')),
            const SizedBox(height: 14),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: const InputDecoration(hintText: 'Email')),
            const SizedBox(height: 14),
            TextField(
              controller: _mdpCtrl, obscureText: !_mdpVisible, textInputAction: TextInputAction.next,
              decoration: InputDecoration(hintText: 'Nouveau Mot de passe', suffixIcon: IconButton(
                icon: Icon(_mdpVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: kTextSub),
                onPressed: () => setState(() => _mdpVisible = !_mdpVisible),
              )),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confCtrl, obscureText: !_confVisible, textInputAction: TextInputAction.done, onSubmitted: (_) => _modifier(),
              decoration: InputDecoration(hintText: 'Confirmer le Mot de passe', suffixIcon: IconButton(
                icon: Icon(_confVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: kTextSub),
                onPressed: () => setState(() => _confVisible = !_confVisible),
              )),
            ),

            if (_erreur != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: kDangerLight, borderRadius: BorderRadius.circular(kRadiusSmall)),
                child: Row(children: [const Icon(Icons.error_outline, color: kDanger, size: 16), const SizedBox(width: 8), Expanded(child: Text(_erreur!, style: const TextStyle(color: kDanger, fontSize: 13)))]),
              ),
            ],
            if (_succes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(kRadiusSmall)),
                child: Row(children: [const Icon(Icons.check_circle_outline, color: kTeal, size: 16), const SizedBox(width: 8), Expanded(child: Text(_succes!, style: const TextStyle(color: kTealDark, fontSize: 13, fontWeight: FontWeight.w600)))]),
              ),
            ],
            const SizedBox(height: 32),

            Row(children: [
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kDanger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusBtn)), padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _supprimer,
                child: const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              )),
              const SizedBox(width: 14),
              Expanded(child: ElevatedButton(
                onPressed: _loading ? null : _modifier,
                child: _loading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Text('Modifier'),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}