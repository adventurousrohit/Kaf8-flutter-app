import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Service/api_service.dart';
import '../Utils/appColor.dart';
import '../Utils/primaryButtion.dart';
import '../Utils/responsiveUtils.dart';
import 'loginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController            = TextEditingController();
  final phoneController           = TextEditingController();
  final emailController           = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible        = false;
  bool isConfirmPasswordVisible = false;
  bool isPasswordWrong          = false;
  bool isLoading                = false;

  // Country picker state
  String selectedFlag = '🇫🇷';
  String selectedCode = '+33';

  final List<Map<String, String>> countries = [
    {'flag': '🇫🇷', 'code': '+33',  'name': 'France'},
    {'flag': '🇩🇪', 'code': '+49',  'name': 'Germany'},
    {'flag': '🇧🇪', 'code': '+32',  'name': 'Belgium'},
    {'flag': '🇳🇱', 'code': '+31',  'name': 'Netherlands'},
    {'flag': '🇨🇭', 'code': '+41',  'name': 'Switzerland'},
    {'flag': '🇪🇸', 'code': '+34',  'name': 'Spain'},
    {'flag': '🇮🇹', 'code': '+39',  'name': 'Italy'},
    {'flag': '🇬🇧', 'code': '+44',  'name': 'UK'},
    {'flag': '🇵🇹', 'code': '+351', 'name': 'Portugal'},
    {'flag': '🇵🇱', 'code': '+48',  'name': 'Poland'},
  ];

  @override
  void initState() {
    super.initState();
    nameController.addListener(() => setState(() {}));
    phoneController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: countries.map((c) {
          return ListTile(
            leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
            title: Text('${c['name']} (${c['code']})'),
            onTap: () {
              setState(() {
                selectedFlag = c['flag']!;
                selectedCode = c['code']!;
              });
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _handleRegister() async {
    final fullName        = nameController.text.trim();
    final phone           = phoneController.text.trim();
    final email           = emailController.text.trim();
    final password        = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() => isPasswordWrong = true);
      Get.snackbar("Error", "Passwords do not match",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() { isLoading = true; isPasswordWrong = false; });

    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : "";
    final lastName  = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : " ";

    final response = await ApiService.register(
      firstName: firstName,
      lastName:  lastName,
      fullName:  fullName,
      email:     email,
      password:  password,
      phone:     '$selectedCode$phone',
      role:      "client",
    );

    setState(() => isLoading = false);

    if (response['success'] == true) {
      Get.snackbar("Success", response['message'] ?? "Registration successful",
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAll(() => const LoginScreen());
    } else {
      Get.snackbar("Error", response['message'] ?? "Registration failed",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ── Shared decoration ──────────────────────────────────────────────────────
  InputDecoration _fieldDecoration({
    required String hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool hasError = false,
  }) {
    final fontScale = ResponsiveUtils.fontScale(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
          color: Colors.grey[400], fontSize: 14 * fontScale),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        BorderSide(color: hasError ? Colors.red : Colors.grey[300]!),
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

  @override
  Widget build(BuildContext context) {
    final scale     = ResponsiveUtils.componentScale(context);
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    final bool isEnabled =
        nameController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty &&
            confirmPasswordController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      body: Stack(
        children: [
          // ── Top-left geometric background ────────────────────────────
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

          // ── Bottom-right geometric background ────────────────────────
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

          // ── Main content ─────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ── Top bar: back button + logo centered ─────────────
                  Stack(
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
                                  color: Colors.grey[400]!, width: 1.5),
                              color: Colors.white.withOpacity(0.6),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                size: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      // Logo with blue border box (as in screenshot)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Appcolor.secondaryColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.3),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 65 * scale,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14 * scale),

                  // ── Title + subtitle ──────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Register Yourself",
                          style: GoogleFonts.inter(
                            fontSize: 26 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Welcome Back! You've\nbeen missed",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14 * fontScale,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24 * scale),

                  // ── Full name ─────────────────────────────────────────
                  _label("Full name", fontScale),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.inter(fontSize: 14 * fontScale),
                    decoration: _fieldDecoration(hint: "Enter full name"),
                  ),

                  SizedBox(height: 14 * scale),

                  // ── Phone number ──────────────────────────────────────
                  _label("Phone number", fontScale),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: GoogleFonts.inter(fontSize: 14 * fontScale),
                    decoration: _fieldDecoration(
                      hint: "Mobile number",
                      prefixIcon: GestureDetector(
                        onTap: _showCountryPicker,
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Center(
                                  child: Text(selectedFlag,
                                      style:
                                      const TextStyle(fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                selectedCode,
                                style: GoogleFonts.inter(
                                  fontSize: 14 * fontScale,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.keyboard_arrow_down,
                                  size: 18, color: Colors.grey[600]),
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                width: 1,
                                height: 22,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 14 * scale),

                  // ── Email ─────────────────────────────────────────────
                  _label("Email", fontScale),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(fontSize: 14 * fontScale),
                    decoration: _fieldDecoration(hint: "Enter email"),
                  ),

                  SizedBox(height: 14 * scale),

                  // ── Password ──────────────────────────────────────────
                  _label("Password", fontScale),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    style: GoogleFonts.inter(fontSize: 14 * fontScale),
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

                  SizedBox(height: 14 * scale),

                  // ── Confirm Password ──────────────────────────────────
                  _label("Confirm Password", fontScale),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    style: GoogleFonts.inter(fontSize: 14 * fontScale),
                    decoration: _fieldDecoration(
                      hint: "Re-enter password",
                      hasError: isPasswordWrong,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[500],
                          size: 22,
                        ),
                        onPressed: () => setState(() =>
                        isConfirmPasswordVisible =
                        !isConfirmPasswordVisible),
                      ),
                    ),
                  ),

                  if (isPasswordWrong)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Passwords do not match",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 12 * fontScale),
                      ),
                    ),

                  SizedBox(height: 16 * scale),

                  // ── Terms ─────────────────────────────────────────────
                  RichText(
                    text: TextSpan(
                      text:
                      "By clicking Create account, you agree to the system's ",
                      style: GoogleFonts.inter(
                          fontSize: 13 * fontScale,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400),
                      children: [
                        TextSpan(
                          text: "Terms and policies",
                          style: GoogleFonts.inter(
                            fontSize: 13 * fontScale,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20 * scale),

                  // ── Register button ───────────────────────────────────
                  PrimaryButton(
                    text: 'Register',
                    borderRadius: 30,
                    onPressed: isEnabled ? _handleRegister : null,
                    isDisabled: !isEnabled,
                    isLoading: isLoading,
                  ),

                  SizedBox(height: 16 * scale),

                  // ── Already have account ──────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.to(() => const LoginScreen()),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF60655C),
                            fontSize: 14 * fontScale,
                          ),
                          children: [
                            TextSpan(
                              text: "Login",
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
    );
  }

  Widget _label(String text, double fontScale) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 14 * fontScale,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
  );
}