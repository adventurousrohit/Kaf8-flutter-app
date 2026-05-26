import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Auth/customerstartingscreen.dart';
import '../Help/help.dart';
import '../Service/api_service.dart';
import '../Utils/responsiveUtils.dart';
import 'ChangePasswordScreen.dart';
import 'PersonalEditingScreen.dart';
import 'PersonalInformationScreen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // ── Background shapes ──────────────────────────────────────
          Positioned(
            top: 0, left: 0,
            child: Image.asset('assets/images/bg_top_left.png',
                width: size.width * 0.60,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.18)),
          ),
          Positioned(
            top: 0, right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.36,
                  fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.13)),
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Image.asset('assets/images/bg_bottom_right.png',
                width: size.width * 0.55,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.28)),
          ),

          // ── Main content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (Navigator.canPop(context))
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.black, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      Text("Profile",
                          style: GoogleFonts.inter(
                              fontSize: 18 * fontScale,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Menu list card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            children: [
                              _menuRow("Personal Information", fontScale,
                                      () => Get.to(() => const PersonalInformationScreen())),
                              _divider(),
                              _menuRow("Personal Editing", fontScale,
                                      () => Get.to(() => const PersonalEditingScreen())),
                              _divider(),
                              _menuRow("Change Password", fontScale,
                                      () => Get.to(() => const ChangePasswordScreen())),
                              _divider(),
                              _menuRow("Help", fontScale, () => Get.to(() => const HelpScreen())),
                            ],
                          ),
                        ),

                        // const Spacer(),

                        const SizedBox(height: 50),
                        // Logout button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () => _showLogoutDialog(context),
                            child: Text("Logout",
                                style: GoogleFonts.inter(
                                    fontSize: 16 * fontScale,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                        ),
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

  Widget _menuRow(String title, double fontScale, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 15 * fontScale,
                    color: Colors.black87)),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 0.8, indent: 16, endIndent: 16);

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
}