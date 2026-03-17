// lib/screens/auth/register_screen.dart  — Écran 2
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomCtrl     = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _mdpCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading     = false;
  bool _mdpVisible  = false;
  bool _confVisible = false;
  String? _erreur;

  Future<void> _creer() async {
    final nom  = _nomCtrl.text.trim();
    final email= _emailCtrl.text.trim();
    final mdp  = _mdpCtrl.text.trim();
    final conf = _confirmCtrl.text.trim();

    if (nom.isEmpty || email.isEmpty || mdp.isEmpty || conf.isEmpty) {
      setState(() => _erreur = 'Veuillez remplir tous les champs.'); return;
    }
    if (mdp != conf) {
      setState(() => _erreur = 'Les mots de passe ne correspondent pas.'); return;
    }
    if (mdp.length < 6) {
      setState(() => _erreur = 'Mot de passe trop court (6 caractères min).'); return;
    }
    setState(() { _loading = true; _erreur = null; });

    // ════════════════════════════════════════════════════════
    // TODO: await DatabaseService.creerPatient(nom, email, mdp);
    await Future.delayed(const Duration(milliseconds: 800));
    Session.connecter(id: 1, nom: nom, email: email, role: RoleUtilisateur.patient);
    // ════════════════════════════════════════════════════════

    setState(() => _loading = false);
    if (mounted) Navigator.pushReplacementNamed(context, '/accueil');
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _emailCtrl.dispose();
    _mdpCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Widget _field(String hint, TextEditingController ctrl, {
    bool obscure = false, bool showToggle = false, bool showConf = false,
    VoidCallback? onToggle, TextInputAction action = TextInputAction.next,
    VoidCallback? onSubmit,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      textInputAction: action,
      onSubmitted: onSubmit != null ? (_) => onSubmit() : null,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: kTextSub),
                onPressed: onToggle,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(children: [
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF80E8E8), kTeal], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.water_drop, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 10),
                  const Text('CARE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kTeal, letterSpacing: 10)),
                ]),
                const SizedBox(height: 40),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Créer un Compte', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextMain)),
                ),
                const SizedBox(height: 24),

                _field('Nom', _nomCtrl),
                const SizedBox(height: 14),
                _field('Email', _emailCtrl),
                const SizedBox(height: 14),
                _field('Mot de passe', _mdpCtrl, obscure: !_mdpVisible, showToggle: true, onToggle: () => setState(() => _mdpVisible = !_mdpVisible)),
                const SizedBox(height: 14),
                _field('Confirmer le Mot de passe', _confirmCtrl, obscure: !_confVisible, showToggle: true, showConf: true, onToggle: () => setState(() => _confVisible = !_confVisible), action: TextInputAction.done, onSubmit: _creer),

                if (_erreur != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: kDangerLight, borderRadius: BorderRadius.circular(kRadiusSmall)),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: kDanger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_erreur!, style: const TextStyle(color: kDanger, fontSize: 13))),
                    ]),
                  ),
                ],
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _creer,
                    child: _loading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Créer'),
                  ),
                ),
                const SizedBox(height: 24),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Déjà un compte ? ', style: TextStyle(color: kTextSub, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Connexion', style: TextStyle(color: kTeal, fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}