import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ServiceHome/HomePage.dart';
import '../Utils/responsiveUtils.dart';
import '../home/OrderScreen.dart';
import '../setting/settingScreen2.dart';
import '../profile/myProfile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

class BottomNavItem {
  final String imagePath;
  final String labelKey;
  final String defaultLabel;
  final int index;

  BottomNavItem({
    required this.imagePath,
    required this.labelKey,
    required this.defaultLabel,
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
    const MyProfileScreen()
  ];

  List<BottomNavItem> _getNavItems() => [
    BottomNavItem(
      imagePath: 'assets/bottomBarImages/HomeIcon.png',
      labelKey: 'home',
      defaultLabel: 'Home',
      index: 0,
    ),
    BottomNavItem(
      imagePath: 'assets/bottomBarImages/BookingIcon.png',
      labelKey: 'booking',
      defaultLabel: 'Booking',
      index: 1,
    ),
    BottomNavItem(
      imagePath: 'assets/bottomBarImages/SettingIcon.png',
      labelKey: 'settings_title',
      defaultLabel: 'Setting',
      index: 2,
    ),
    BottomNavItem(
      imagePath: 'assets/bottomBarImages/ProfileIcon.png',
      labelKey: 'profile',
      defaultLabel: 'Profile',
      index: 3,
    ),
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
    final theme     = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: screens,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          28,
          0,
          28,
          bottomInset > 0 ? bottomInset + 8 : 16,
        ),
        child: _buildBottomNavBar(navItems, scale, fontScale, theme),
      ),
    );
  }

  // ── Green pill bottom nav with Icons + Text Labels ─────────────────────────
  Widget _buildBottomNavBar(
      List<BottomNavItem> navItems,
      double scale,
      double fontScale,
      ThemeData theme,
      ) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * scale, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.green,
        borderRadius: BorderRadius.circular(36),
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
          final String labelText = item.labelKey.tr.isNotEmpty && item.labelKey.tr != item.labelKey
              ? item.labelKey.tr
              : item.defaultLabel;

          return GestureDetector(
            onTap: () {
              _controller.jumpToPage(item.index);
              setState(() => _currentIndex = item.index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 12 * scale : 8 * scale,
                vertical: 6 * scale,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.25))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    item.imagePath,
                    width: 40 * scale,
                    height: 42 * scale,
                    color: isSelected
                        ? (isDark ? Colors.green : Colors.white)
                        : (isDark ? Colors.white54 : Colors.white60),
                  ),
                  Text(
                    labelText,
                    style: GoogleFonts.inter(
                      fontSize: 11 * fontScale,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? (isDark ? Colors.green : Colors.white)
                          : (isDark ? Colors.white54 : Colors.white60),
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
