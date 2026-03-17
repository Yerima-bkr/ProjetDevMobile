// lib/widgets/care_bottom_nav.dart
import 'package:flutter/material.dart';
import '../constants.dart';

// ── Médecin — 3 onglets ──────────────────────────────────────
class CareBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CareBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _NavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        _NavItem(icon: Icons.home_outlined,      activeIcon: Icons.home_rounded,      label: 'Accueil'),
        _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Prescriptions'),
        _NavItem(icon: Icons.settings_outlined,   activeIcon: Icons.settings_rounded,  label: 'Paramètres'),
      ],
    );
  }
}

// ── Patient — 4 onglets ──────────────────────────────────────
class CareBottomNavPatient extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CareBottomNavPatient({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _NavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,           label: 'Accueil'),
        _NavItem(icon: Icons.person_search_outlined,  activeIcon: Icons.person_search_rounded,  label: 'Médecins'),
        _NavItem(icon: Icons.assignment_outlined,     activeIcon: Icons.assignment_rounded,     label: 'Prescriptions'),
        _NavItem(icon: Icons.settings_outlined,       activeIcon: Icons.settings_rounded,       label: 'Paramètres'),
      ],
    );
  }
}

// ── Widget interne ────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _NavBar({required this.currentIndex, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kTeal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item    = items[i];
              final actif   = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: actif
                            ? BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(30),
                              )
                            : null,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Icon(
                          actif ? item.activeIcon : item.icon,
                          color: Colors.white,
                          size: actif ? 26 : 22,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}