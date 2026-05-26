import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/Auth/customerstartingscreen.dart';
import 'package:kaf8/Service/api_service.dart';
import 'package:kaf8/setting/BankAccountScreen.dart';
import 'package:kaf8/setting/LanguageScreen.dart';
import 'package:kaf8/setting/NotificationSettingScreen.dart';

import '../Help/favoritelist.dart';
import '../Help/help.dart';
import '../Help/notification.dart';
import '../Utils/appColor.dart';
import '../Utils/responsiveUtils.dart';
import '../profile/myProfile.dart';
import '../address/addressScreen.dart';
import '../home/OrderScreen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // ── Top-left geometric background ──────────────────────────
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/bg_top_left.png',
              width: size.width * 0.65,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              opacity: const AlwaysStoppedAnimation(0.22),
            ),
          ),

          // ── Top-right geometric background ─────────────────────────
          Positioned(
            top: 0,
            right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.38,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.15),
              ),
            ),
          ),

          // ── Bottom-right geometric background ──────────────────────
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg_bottom_right.png',
              width: size.width * 0.60,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              opacity: const AlwaysStoppedAnimation(0.30),
            ),
          ),

          // ── Bottom-left mirror ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.32,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.12),
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── WHITE HEADER ──────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const SizedBox(width: 44), // balance
                      const Spacer(),
                      Text(
                        "Settings",
                        style: GoogleFonts.inter(
                          fontSize: 18 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      // Bell with dot
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => NotificationPage()),
                            child: const Icon(Icons.notifications_none,
                                size: 26, color: Colors.black87),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Get.to(() => const MyProfileScreen()),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                              "https://randomuser.me/api/portraits/men/32.jpg"),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Scrollable body ───────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Avatar area (with bg shapes showing through) ──
                        SizedBox(
                          height: 140,
                          child: Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // White ring
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: GestureDetector(
                                    onTap: () => Get.to(() => const MyProfileScreen()),
                                    child: const CircleAvatar(
                                      radius: 46,
                                      backgroundImage: NetworkImage(
                                          "https://randomuser.me/api/portraits/men/32.jpg"),
                                    ),
                                  ),
                                ),
                                // Green edit button
                                Positioned(
                                  bottom: 0,
                                  right: -2,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── GENERAL section ────────────────────────────
                        _sectionTitle("Gerneral", fontScale),
                        _menuCard([
                          _menuItem(Icons.person_outline,       "My profile",   fontScale, () => Get.to(() => MyProfileScreen())),
                          _menuItem(Icons.location_on_outlined, "My Address",   fontScale, () => Get.to(() => AddressScreens())),
                          _menuItem(Icons.language,             "Language",     fontScale, () => Get.to(() => LanguageScreen())),
                        ]),

                        const SizedBox(height: 20),

                        // ── OTHER ACTIVITY section (blue dashed border) ──
                        _sectionTitle("Other Activity", fontScale),
                        _dashedBorderCard([
                          _menuItem(Icons.account_balance_wallet_outlined, "Bank Account",    fontScale, () => Get.to(() => BankAccountScreen())),
                          _menuItem(Icons.notifications_outlined,          "Notification",    fontScale, () => Get.to(() => NotificationSettingScreen())),
                          _menuItem(Icons.favorite_border,                 "Favourite List",  fontScale, () => Get.to(() => FavoriteList())),
                        ]),

                        const SizedBox(height: 20),

                        // ── HELP AND SUPPORT section ───────────────────
                        _sectionTitle("Help and Support", fontScale),
                        _menuCard([
                          _menuItem(Icons.headset_mic_outlined,  "Live Call &Chat",    fontScale, () {}),
                          _menuItem(Icons.chat_bubble_outline,   "About us",           fontScale, () {}),
                          _menuItem(Icons.description_outlined,  "Terms and policies", fontScale, () {}),
                          _menuItem(Icons.help_outline,          "Privacy Policy",     fontScale, () {}),
                        ]),

                        const SizedBox(height: 20),

                        // ── ACCOUNT section ────────────────────────────
                        _sectionTitle("Account", fontScale),
                        _menuCard([
                          _menuItem(Icons.logout, "Log out", fontScale, () => _showLogoutDialog(context), isLogout: true),
                        ]),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Logout",
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Text(
            "Are you sure you want to logout from the application?",
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.logout();
                Get.offAll(() => const GetStartedScreen());
              },
              child: Text(
                "Logout",
                style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Section title ───────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, double fontScale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15 * fontScale,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  // ── White card wrapping a list of menu items ────────────────────────────────
  Widget _menuCard(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  // ── Blue dashed border card (Other Activity) ────────────────────────────────
  Widget _dashedBorderCard(List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFF2979FF),
          radius: 16,
          dashWidth: 6,
          dashSpace: 4,
          strokeWidth: 1.8,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ),
    );
  }

  // ── Single menu row ─────────────────────────────────────────────────────────
  Widget _menuItem(
      IconData icon,
      String title,
      double fontScale,
      VoidCallback onTap, {
        bool isLogout = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Green circle outline icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15 * fontScale,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.black87 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed border CustomPainter ─────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final extracted = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extracted, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}