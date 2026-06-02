import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/home/settingScreen.dart';
import 'package:kaf8/profile/myProfile.dart';

import '../Utils/responsiveUtils.dart';
import '../home/OrderScreen.dart';
import '../driverHome/driverHomePage.dart';
import '../setting/settingScreen2.dart';
import 'HomePage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

class BottomNavItem {
  final IconData icon;
  final String label;
  final int index;

  BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN HOME PAGE (Shell)
// ─────────────────────────────────────────────────────────────────────────────

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;
  final PageController _controller = PageController();

  List<Widget> _getScreens() => [
    const HomePage(),
    const OrdersScreen(),
    const SettingScreen(),
    const MyProfileScreen(),
  ];

  List<BottomNavItem> _getNavItems() => [
    BottomNavItem(icon: Icons.home_rounded,          label: 'Home',     index: 0),
    BottomNavItem(icon: Icons.receipt_long_outlined, label: 'Bookings', index: 1),
    BottomNavItem(icon: Icons.settings_outlined,     label: 'setting', index: 2),
    BottomNavItem(icon: Icons.person_outline,        label: 'profile',  index: 3),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale     = ResponsiveUtils.componentScale(context);
    final fontScale = ResponsiveUtils.fontScale(context);
    final screens   = _getScreens();
    final navItems  = _getNavItems();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(), // disable swipe — nav controls it
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: screens,
      ),
      bottomNavigationBar: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildBottomNavBar(navItems, scale, fontScale, theme),
            )
          : null,
    );
  }

  // ── Green pill bottom nav ──────────────────────────────────────────────────
  Widget _buildBottomNavBar(
      List<BottomNavItem> navItems,
      double scale,
      double fontScale,
      ThemeData theme,
      ) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10 * scale, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.green,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.green).withOpacity(0.40),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          final bool isSelected = _currentIndex == item.index;
          return GestureDetector(
            onTap: () {
              _controller.jumpToPage(item.index);
              setState(() => _currentIndex = item.index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 14 : 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.20))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 24 * scale,
                    color: isSelected ? (isDark ? Colors.green : Colors.white) : (isDark ? Colors.white54 : Colors.white60),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 11 * fontScale,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? (isDark ? Colors.green : Colors.white) : (isDark ? Colors.white54 : Colors.white60),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// keep old name alias so existing Get.offAll(() => const BaseScreen()) still compiles
typedef Mainhomepage = BaseScreen;