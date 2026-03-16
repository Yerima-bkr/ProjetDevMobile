// lib/screens/patient/auth_screen.dart  — Écran 17
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'account_management_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _mdpCtrl   = TextEditingController();
  bool _loading    = false;
  bool _mdpVisible = false;
  String? _erreur;

  Future<void> _authentifier() async {
    final email = _emailCtrl.text.trim();
    final mdp   = _mdpCtrl.text.trim();
    if (email.isEmpty || mdp.isEmpty) {
      setState(() => _erreur = 'Veuillez remplir tous les champs.'); return;
    }
    setState(() { _loading = true; _erreur = null; });

    // ════════════════════════════════════════════════════════
    // TODO:
    // final ok = await DatabaseService.verifierIdentite(email, mdp);
    // if (!ok) {
    //   setState(() { _loading = false; _erreur = 'Identifiants incorrects.'; });
    //   return;
    // }
    await Future.delayed(const Duration(milliseconds: 700));
    // ════════════════════════════════════════════════════════

    setState(() => _loading = false);
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AccountManagementScreen()));
  }

  @override
  void dispose() { _emailCtrl.dispose(); _mdpCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, leading: IconButton(icon: const Icon(Icons.arrow_back, color: kTextMain), onPressed: () => Navigator.pop(context)), elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Logo
              const Icon(Icons.water_drop, size: 64, color: kTeal),
              const Text('CARE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kTeal, letterSpacing: 8)),
              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Est ce bien vous ? 😳', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextMain)),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _mdpCtrl,
                obscureText: !_mdpVisible,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _authentifier(),
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
                    const Icon(Icons.error_outline, color: kDanger, size: 16), const SizedBox(width: 8),
                    Expanded(child: Text(_erreur!, style: const TextStyle(color: kDanger, fontSize: 13))),
                  ]),
                ),
              ],
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _authentifier,
                  child: _loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('S\'authentifier'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}