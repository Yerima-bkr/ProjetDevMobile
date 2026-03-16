import 'package:flutter/material.dart';
import '../../constants.dart';
// ignore: unused_import
import '../../models.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Clé pour la validation du formulaire
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();

  bool _loading = false;
  bool _mdpVisible = false;
  String? _erreur;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _mdpCtrl.dispose();
    super.dispose();
  }

  Future<void> _connexion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
        _erreur = null;
      });

      // Simulation de l'appel API
      bool succes = await ApiService.login(_emailCtrl.text, _mdpCtrl.text);

      if (succes && mounted) {
        // Si la connexion réussit, on va vers l'accueil
        Navigator.pushReplacementNamed(context, '/accueil');
      } else {
        // Si elle échoue, on arrête le chargement et on affiche une erreur
        setState(() {
          _loading = false;
          _erreur = "Identifiants incorrects ou serveur injoignable.";
        });
      }
    }
  }

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
              child: Form(
                key: _formKey, // Liaison de la clé
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CareLogo(),
                    const SizedBox(height: 48),

                    // Champ Email avec validation
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "L'email est requis";
                        }
                        if (!value.contains('@')) {
                          return "Format d'email invalide";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Champ Mot de passe avec validation
                    TextFormField(
                      controller: _mdpCtrl,
                      obscureText: !_mdpVisible,
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_mdpVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () =>
                              setState(() => _mdpVisible = !_mdpVisible),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Le mot de passe est requis";
                        }
                        if (value.length < 6) {
                          return "Minimum 6 caractères";
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
                        onPressed: _loading ? null : _connexion,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("SE CONNECTER"),
                      ),
                    ),

                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: const Text("Pas encore de compte ? S'inscrire",
                          style: TextStyle(color: kTeal)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CareLogo extends StatelessWidget {
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
      const Text(
        'CARE',
        style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: kTeal,
            letterSpacing: 10),
      ),
    ]);
  }
}
