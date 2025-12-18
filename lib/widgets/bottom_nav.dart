import 'package:flutter/material.dart';

import '../theme/app_color.dart';

enum NavigationPage {
  dashboard,
  contracts,
  payments,
  claims,
  profile,
}

class BottomNav extends StatelessWidget {
  final NavigationPage currentPage;
  final Function(NavigationPage) onNavigate;

  const BottomNav({
    super.key,
    required this.currentPage,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(
        id: NavigationPage.dashboard,
        label: 'Accueil',
        icon: Icons.home_rounded,
      ),
      _NavItem(
        id: NavigationPage.contracts,
        label: 'Contrats',
        icon: Icons.description_rounded,
      ),
      _NavItem(
        id: NavigationPage.payments,
        label: 'Paiements',
        icon: Icons.credit_card_rounded,
      ),
      _NavItem(
        id: NavigationPage.claims,
        label: 'Réclamations',
        icon: Icons.warning_rounded,
      ),
      _NavItem(
        id: NavigationPage.profile,
        label: 'Profil',
        icon: Icons.person_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(
            color: AppColors.gray200,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final isActive = currentPage == item.id;
              return _NavButton(
                item: item,
                isActive: isActive,
                onTap: () => onNavigate(item.id),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final NavigationPage id;
  final String label;
  final IconData icon;

  const _NavItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.blue50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                item.icon,
                size: 24,
                color: isActive ? AppColors.blue600 : AppColors.gray500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.blue600 : AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}