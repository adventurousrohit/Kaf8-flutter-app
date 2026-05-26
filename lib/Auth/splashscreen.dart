import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../small-widgets/app_assets.dart';
import '../../small-widgets/app_colors.dart';
import '../Service/api_service.dart';
import '../ServiceHome/mainHomePage.dart';
import '../driverHome/driverHomePage.dart';
import 'onBoarding.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    debugPrint("🕒 Checking login status...");
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 3));

    final token = await ApiService.getAccessToken();
    final role = await ApiService.getUserRole();
    
    debugPrint("🔑 Stored Token: ${token != null ? 'EXISTS' : 'NULL'}");
    debugPrint("👤 Stored Role: $role");

    if (token != null && token.isNotEmpty) {
      if (role == "client") {
        debugPrint("🚀 Navigating to Transporter Home");
        Get.offAll(() => const DriverHomeScreen());
      } else if (role == "transporter" || role == "administrator" || role == null) {
        debugPrint("🚀 Navigating to Client Home (Role: $role)");
        Get.offAll(() => const BaseScreen());
      } else {
        debugPrint("🚀 Unknown role, going to OnBoardings");
        Get.offAll(() => const OnBoardings());
      }
    } else {
      debugPrint("🚀 Navigating to OnBoardings");
      Get.offAll(() => const OnBoardings());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              AppAssets.logo,
              width: 206,
              height: 210,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "The European Delivery Gateway ",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenAccent,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Image.asset(
                      AppAssets.truckLogo,
                      width: 37.88,
                      height: 37.44,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}