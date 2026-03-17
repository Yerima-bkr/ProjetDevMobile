// lib/screens/auth/login_screen.dart  — Écran 1
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _mdpCtrl   = TextEditingController();
  bool _loading    = false;
  bool _mdpVisible = false;
  String? _erreur;
  late AnimationController _animCtrl;
  late Animation<double>    _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  Future<void> _connexion() async {
    final email = _emailCtrl.text.trim();
    final mdp   = _mdpCtrl.text.trim();
    if (email.isEmpty || mdp.isEmpty) {
      setState(() => _erreur = 'Veuillez remplir tous les champs.');
      return;
    }
    setState(() { _loading = true; _erreur = null; });

    // ════════════════════════════════════════════════════════
    // TODO: remplacer par l'appel réel de ton amie :
    //
    // final res = await DatabaseService.login(email, mdp);
    // if (res == null) {
    //   setState(() { _loading = false; _erreur = 'Identifiants incorrects.'; });
    //   return;
    // }
    // Session.connecter(
    //   id:    res['id'],
    //   nom:   res['nom'],
    //   email: res['email'],
    //   role:  res['role'] == 'medecin'
    //            ? RoleUtilisateur.medecin
    //            : RoleUtilisateur.patient,
    // );
    //
    // Simulation temporaire par l'email :
    await Future.delayed(const Duration(milliseconds: 800));
    final estMedecin = email.toLowerCase().contains('dr.') ||
                       email.toLowerCase().contains('medecin') ||
                       email.toLowerCase().contains('docteur');
    Session.connecter(
      id:    1,
      nom:   estMedecin ? 'Dr. Rousgou Djansé Igor' : 'Rousgou Djansé Igor',
      email: email,
      role:  estMedecin ? RoleUtilisateur.medecin : RoleUtilisateur.patient,
    );
    // ════════════════════════════════════════════════════════

    setState(() => _loading = false);
    if (mounted) Navigator.pushReplacementNamed(context, '/accueil');
  }

  @override
  void dispose() { _animCtrl.dispose(); _emailCtrl.dispose(); _mdpCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  _CareLogo(),
                  const SizedBox(height: 48),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Connexion à votre Compte',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextMain),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Email
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(height: 14),

                  // Mot de passe
                  TextField(
                    controller: _mdpCtrl,
                    obscureText: !_mdpVisible,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _connexion(),
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(_mdpVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: kTextSub),
                        onPressed: () => setState(() => _mdpVisible = !_mdpVisible),
                      ),
                    ),
                  ),

                  if (_erreur != null) ...[
                    const SizedBox(height: 10),
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
                      onPressed: _loading ? null : _connexion,
                      child: _loading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Connexion'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Pas de compte ? ', style: TextStyle(color: kTextSub, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Créer', style: TextStyle(color: kTeal, fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo réutilisable ────────────────────────────────────────
class _CareLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 80, height: 80,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF80E8E8), kTeal], begin: Alignment.topLeft, end: Alignment.bottomRight),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.water_drop, color: Colors.white, size: 40),
      ),
      const SizedBox(height: 10),
      const Text(
        'CARE',
        style: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w900, color: kTeal,
          letterSpacing: 10,
        ),
      ),
    ]);
  }
}