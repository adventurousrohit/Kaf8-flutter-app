import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/appColor.dart';
import '../Utils/primaryButtion.dart';
import '../Utils/responsiveUtils.dart';
import '../Utils/socialButton.dart';
import 'RegisterScreenuser.dart';
import 'loginScreen.dart';
import 'driverRegistrationScreen.dart';

class GetStartedScreen extends StatefulWidget {
  final String role;
  const GetStartedScreen({super.key, this.role = 'customer'});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.componentScale(context);
    final padding = ResponsiveUtils.paddingScale(context) * 20;
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;

    final isDriver = widget.role == 'driver';

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8), // light blue base
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Appcolor.secondaryColor,
        ),
      )
          : Stack(
        children: [
          // ── Top-left geometric image ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/bg_top_left.png',
              width: size.width * 0.67,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              opacity: const AlwaysStoppedAnimation(0.2),
            ),
          ),

          // ── Bottom-right geometric image ──────────────────────────
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg_bottom_right.png',
              width: size.width * 0.45,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              opacity: const AlwaysStoppedAnimation(0.4),
            ),
          ),

          // ── Main scrollable content ───────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20 * scale),

                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 110 * scale,
                  ),

                  SizedBox(height: 18 * scale),

                  // Title
                  Text(
                    isDriver ? "Service Provider" : "Let's Get Started",
                    style: GoogleFonts.inter(
                      fontSize: 26 * fontScale,
                      fontWeight: FontWeight.w700,
                      color: Appcolor.secondaryColor,
                    ),
                  ),

                  SizedBox(height: 8 * scale),

                  // Subtitle (underlined like in screenshot)
                  Text(
                    isDriver
                        ? 'Join the fleet and start delivering'
                        : 'Create an account or login\nto explore about our app',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14 * fontScale,
                      color: Colors.black,
                      // decoration: TextDecoration.underline,
                      decorationColor: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 28 * scale),

                  // Truck image
                  Image.asset(
                    'assets/images/truck.png',
                    height: 170 * scale,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: 36 * scale),

                  // ── Login Button ──────────────────────────────────
                  PrimaryButton(
                    text: 'Login',
                    borderRadius: 30,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(role: widget.role),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20 * scale),

                  // ── Divider "or" ──────────────────────────────────
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(thickness: 1, color: Colors.grey),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14 * fontScale,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(thickness: 1, color: Colors.grey),
                      ),
                    ],
                  ),

                  SizedBox(height: 18 * scale),

                  // ── Google ────────────────────────────────────────
                  SocialButton(
                    text: "Continue with Google",
                    assetPath: 'assets/icons/google_icon.png',
                    backgroundColor: const Color(0xFF5384EE),
                    borderRadius: 30,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),

                  // ── Facebook ──────────────────────────────────────
                  SocialButton(
                    text: "Continue with Facebook",
                    assetPath: 'assets/icons/facebook_icon.png',
                    backgroundColor: const Color(0xFF415792),
                    borderRadius: 30,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),

                  // ── Apple ─────────────────────────────────────────
                  SocialButton(
                    text: "Continue with Apple",
                    assetPath: 'assets/icons/apple_icon.png',
                    backgroundColor: Colors.black,
                    borderRadius: 30,
                    onPressed: () {},
                  ),

                  SizedBox(height: 20 * scale),

                  // ── Register row ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Do not have an account? ",
                        style: GoogleFonts.inter(
                          fontSize: 14 * fontScale,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF60655C),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (widget.role == 'driver') {
                            Get.to(() => const DriverRegistration());
                          } else {
                            Get.to(() => const RegisterScreen());
                          }
                        },
                        child: Text(
                          "Register",
                          style: GoogleFonts.inter(
                            fontSize: 14 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}