import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/driverHome/driverHomePage.dart';

import '../profile/EnterEmailScreen.dart';
import '../Service/api_service.dart';
import '../Service/fcm_service.dart';
import '../Utils/appColor.dart';
import '../Utils/primaryButtion.dart';
import '../Utils/responsiveUtils.dart';
import '../Utils/socialButton.dart';
import '../home/mainhomepage.dart';
import '../ServiceHome/mainHomePage.dart' as serviceHome;
import 'RegisterScreenuser.dart';
import 'driverRegistrationScreen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, this.role = 'customer'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isPasswordWrong = false;
  bool isLoading = false;

  void _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter email",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Please enter a valid email",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (password.isEmpty) {
      Get.snackbar("Error", "Please enter password",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() {
      isLoading = true;
      isPasswordWrong = false;
    });

    final response = await ApiService.login(
      email: email,
      password: password,
    );

    setState(() => isLoading = false);

    if (response['success'] == true) {
      Get.snackbar("Success", response['message'] ?? "Login successful",
          backgroundColor: Colors.green, colorText: Colors.white);

      // Upload FCM token now that auth token is saved
      FcmService.uploadCurrentToken();

      final role = await ApiService.getUserRole();
      if (role == "client") {
        Get.offAll(() => const BaseScreen());
      } else if (role == "transporter") {
        Get.offAll(() => const DriverHomeScreen());
      } else if (role == "serviceProvider" || role == "administrator") {
        Get.offAll(() => const serviceHome.BaseScreen());
      } else {
        Get.offAll(() => const BaseScreen());
      }
    } else {
      setState(() => isPasswordWrong = true);
      Get.snackbar("Error", response['message'] ?? "Login failed",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final scale = ResponsiveUtils.componentScale(context);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isEnabled =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;

    InputDecoration _fieldDecoration({
      required String hint,
      Widget? suffixIcon,
      Widget? prefixIcon,
      bool hasError = false,
    }) {
      return InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: Colors.grey[400],
          fontSize: 14 * fontScale,
        ),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : (isDark ? Colors.white10 : Colors.grey[300]!),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Appcolor.secondaryColor,
            width: 1.5,
          ),
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/bg_top_left.png',
              width: size.width * 0.67,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.2),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg_bottom_right.png',
              width: size.width * 0.45,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.4),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: isDark ? Colors.white24 : Colors.grey[400]!, width: 1.5),
                              color: theme.cardColor.withOpacity(0.6),
                            ),
                            child: Icon(Icons.arrow_back_ios_new,
                                size: 16, color: theme.iconTheme.color),
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 100 * scale,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  "Login",
                  style: GoogleFonts.inter(
                    fontSize: 26 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Welcome Back! You've\nbeen missed",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14 * fontScale,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 24 * scale),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: GoogleFonts.inter(
                            fontSize: 14 * fontScale,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale, color: theme.textTheme.bodyLarge?.color),
                          decoration: _fieldDecoration(
                            hint: "Enter your email",
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        Text(
                          "Password",
                          style: GoogleFonts.inter(
                            fontSize: 14 * fontScale,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale, color: theme.textTheme.bodyLarge?.color),
                          decoration: _fieldDecoration(
                            hint: "Enter password",
                            hasError: isPasswordWrong,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[500],
                                size: 22,
                              ),
                              onPressed: () => setState(
                                      () => isPasswordVisible = !isPasswordVisible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => Get.to(() => const EnterEmailScreen()),
                          child: Text(
                            "Forgot password?",
                            style: GoogleFonts.inter(
                              fontSize: 13 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: Appcolor.secondaryColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 28 * scale),
                        PrimaryButton(
                          text: 'Login',
                          onPressed: isEnabled ? _handleLogin : null,
                          isDisabled: !isEnabled,
                          isLoading: isLoading,
                        ),
                        SizedBox(height: 20 * scale),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    thickness: 1, color: theme.dividerColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Text(
                                "or",
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                  fontSize: 14 * fontScale,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    thickness: 1, color: theme.dividerColor)),
                          ],
                        ),
                        SizedBox(height: 16 * scale),
                        SocialButton(
                          text: "Continue with Google",
                          assetPath: 'assets/icons/google_icon.png',
                          backgroundColor: const Color(0xFF5384EE),
                          onPressed: () {
                            Get.snackbar(
                              "Coming Soon",
                              "Google login will be available in a future update",
                              backgroundColor: Colors.grey[800],
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                        ),
                        SizedBox(height: 20 * scale),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              if (widget.role == 'driver') {
                                Get.to(() => const DriverRegistration());
                              } else {
                                Get.to(() => const RegisterScreen());
                              }
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Do not have an account? ",
                                style: GoogleFonts.inter(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  fontSize: 14 * fontScale,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Register",
                                    style: GoogleFonts.inter(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14 * fontScale,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
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
}
