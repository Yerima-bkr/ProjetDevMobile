// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import '../../constants.dart';
// ignore: unused_import
import '../../models.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _mdpVisible = false;
  bool _confVisible = false;
  String? _erreur;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _mdpCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
        _erreur = null;
      });

      final success = await ApiService.register(
        _nomCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _mdpCtrl.text.trim(),
      );

      setState(() => _loading = false);

      if (success) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        setState(() {
          _erreur = "Erreur lors de l'inscription";
        });
      }
    }
  }

  // FONCTION CORRIGÉE : hint et ctrl sont maintenant des paramètres nommés
  Widget field({
    required String hint,
    required TextEditingController ctrl,
    required String? Function(String?) validator,
    bool obscure = false,
    bool showToggle = false,
    VoidCallback? onToggle,
    TextInputAction action = TextInputAction.next,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      textInputAction: action,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: kTextSub),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CareLogoInscr(),
                  const SizedBox(height: 40),

                  // Appel de la fonction avec les paramètres nommés
                  field(
                    hint: "Nom complet",
                    ctrl: _nomCtrl,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Nom requis" : null,
                  ),
                  const SizedBox(height: 16),

                  field(
                    hint: "Email",
                    ctrl: _emailCtrl,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Email requis";
                      if (!v.contains('@')) return "Email invalide";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  field(
                    hint: "Mot de passe",
                    ctrl: _mdpCtrl,
                    obscure: !_mdpVisible,
                    showToggle: true,
                    onToggle: () => setState(() => _mdpVisible = !_mdpVisible),
                    validator: (v) =>
                        v != null && v.length < 6 ? "6 caractères min." : null,
                  ),
                  const SizedBox(height: 16),

                  field(
                    hint: "Confirmer le mot de passe",
                    ctrl: _confirmCtrl,
                    obscure: !_confVisible,
                    showToggle: true,
                    onToggle: () =>
                        setState(() => _confVisible = !_confVisible),
                    action: TextInputAction.done,
                    validator: (v) {
                      if (v != _mdpCtrl.text) {
                        return "Les mots de passe diffèrent";
                      }
                      return null;
                    },
                  ),

                  if (_erreur != null) ...[
                    const SizedBox(height: 16),
                    Text(_erreur!, style: const TextStyle(color: kDanger)),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _creer,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("S'INSCRIRE"),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Déjà un compte ? Se connecter",
                        style: TextStyle(color: kTeal)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CareLogoInscr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF80E8E8), kTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.water_drop, color: Colors.white, size: 40),
      ),
      const SizedBox(height: 10),
      const Text('CARE',
          style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: kTeal,
              letterSpacing: 10)),
    ]);
  }
}
