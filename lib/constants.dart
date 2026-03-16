// lib/constants.dart
import 'package:flutter/material.dart';

// ── Couleurs ─────────────────────────────────────────────────
const Color kTeal = Color(0xFF2EC4C4);
const Color kTealDark = Color(0xFF1A9494);
const Color kTealLight = Color(0xFFE8FAFA);
const Color kBg = Color(0xFFF7FBFB);
const Color kDanger = Color(0xFFE53935);
const Color kDangerLight = Color(0xFFFFEBEE);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kCard = Color(0xFFFFFFFF); // alias
const Color kTextDark = Color(0xFF1A1A2E);
const Color kTextMain = Color(0xFF1A1A2E); // alias
const Color kTextGrey = Color(0xFF6B7280);
const Color kTextSub = Color(0xFF6B7280); // alias
const Color kDivider = Color(0xFFE5F5F5);

// ── Rayons ───────────────────────────────────────────────────
const double kRadius = 18.0;
const double kRadiusSmall = 12.0;
const double kRadiusBtn = 30.0;

// ── État partagé — fond d'écran du chat ─────────────────────
String? chatBackground;

// ── Ombres ───────────────────────────────────────────────────
List<BoxShadow> get kShadow => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
List<BoxShadow> get kShadowSm => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
List<BoxShadow> get kShadowLight => kShadowSm; // alias

// ── Thème global ─────────────────────────────────────────────
ThemeData careTheme() => ThemeData(
      fontFamily: 'Roboto',
      colorScheme:
          const ColorScheme.light(primary: kTeal, secondary: kTealDark),
      scaffoldBackgroundColor: kBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: kTextDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: kTextDark),
        titleTextStyle: TextStyle(
          color: kTextDark,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: Color(0xFFE0EEEE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: Color(0xFFE0EEEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: kTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: kDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: kDanger, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFFB0C4C4), fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kTeal,
          foregroundColor: Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusBtn),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      useMaterial3: false,
    );

// URL API
const String kBaseUrl = "https://care-gsn2.onrender.com/api";
// Endpoints
const String kAuthUrl = "$kBaseUrl/auth";
const String kMedecinUrl = "$kBaseUrl/medecin";
const String kPrescriptionUrl = "$kBaseUrl/prescription";
const String kMessagesUrl = "$kBaseUrl/messages";
const String kCentreSanteUrl = "$kBaseUrl/centre-sante";
const String kLoginUrl = "$kAuthUrl/login";
const String kRegisterUrl = "$kAuthUrl/signup";
// Headers
const Map<String, String> kHeaders = {
  "Content-Type": "application/json",
  "Accept": "application/json",
};
