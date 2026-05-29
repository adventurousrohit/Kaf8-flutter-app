import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaf8/Auth/loginScreen.dart';

import '../Service/api_service.dart';
import '../Utils/appColor.dart';
import '../Utils/primaryButtion.dart';
import '../Utils/responsiveUtils.dart';

class DriverRegistration extends StatefulWidget {
  const DriverRegistration({super.key});

  @override
  State<DriverRegistration> createState() => _DriverRegistrationState();
}

class _DriverRegistrationState extends State<DriverRegistration> {
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  final _phoneController     = TextEditingController();
  final _emailController     = TextEditingController();
  final _passwordController  = TextEditingController();
  final _noteController      = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading       = false;

  // Country picker
  String _selectedFlag = '🇫🇷';
  String _selectedCode = '+33';

  // Files
  File? _profileImage;

  final List<Map<String, String>> _countries = [
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

  bool get _isEnabled =>
      _firstNameController.text.trim().isNotEmpty &&
          _lastNameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _firstNameController, _lastNameController, _phoneController,
      _emailController, _passwordController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameController, _lastNameController, _phoneController,
      _emailController, _passwordController, _noteController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _profileImage = File(picked.path));
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _countries.map((c) => ListTile(
          leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
          title: Text('${c['name']} (${c['code']})'),
          onTap: () {
            setState(() {
              _selectedFlag = c['flag']!;
              _selectedCode = c['code']!;
            });
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _handleRegister() async {
    if (!GetUtils.isEmail(_emailController.text.trim())) {
      Get.snackbar("Error", "Enter valid email",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    setState(() => _isLoading = true);

    final response = await ApiService.register(
      firstName:    _firstNameController.text.trim(),
      lastName:     _lastNameController.text.trim(),
      fullName:     '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      email:        _emailController.text.trim(),
      password:     _passwordController.text.trim(),
      phone:        '$_selectedCode${_phoneController.text.trim()}',
      avatar:       _profileImage?.path,
      availability: true,
      role:         "transporter",
    );

    setState(() => _isLoading = false);

    if (response['success'] == true) {
      Get.snackbar("Success",
          response['message'] ?? "Registration successful",
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAll(() => const LoginScreen());
    } else {
      Get.snackbar("Error",
          response['message'] ?? "Registration failed",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ── Shared field decoration ─────────────────────────────────────────────
  InputDecoration _deco(String hint, {Widget? prefix, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefix,
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Appcolor.secondaryColor, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Top-left geometric background ──────────────────────────
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
          // ── Bottom-right lavender/purple shape ─────────────────────
          Positioned(
            bottom: 0, right: 0,
            child: Image.asset(
              'assets/images/bg_bottom_right.png',
              width: size.width * 0.60,
              fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.30),
            ),
          ),
          Positioned(
            bottom: 0, left: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.35,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.15),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── HERO SECTION (light blue with shapes + logo) ───
                  SizedBox(
                    height: 220,
                    child: Stack(
                      children: [
                        // Light blue background
                        Container(
                          width: double.infinity,
                          height: 220,
                        ),
                        Positioned.fill(
                          child: Column(
                            children: [
                              // Back button row
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.grey[700]!,
                                            width: 1.8),
                                        color: Colors.white
                                            .withOpacity(0.5),
                                      ),
                                      child: const Icon(
                                          Icons.arrow_back_ios_new,
                                          size: 15,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),

                              // Logo
                              Image.asset(
                                'assets/images/logo.png',
                                width: 60,
                                height: 60,
                              ),
                              const SizedBox(height: 6),

                              // Title
                              Text("Register Yourself",
                                  style: GoogleFonts.inter(
                                    fontSize: 20 * fontScale,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  )),
                              const SizedBox(height: 4),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'Register yourself on ',
                                  style: GoogleFonts.inter(
                                      fontSize: 12 * fontScale,
                                      color: Colors.grey[600]),
                                  children: [
                                    TextSpan(
                                      text: '"KAF8"',
                                      style: GoogleFonts.inter(
                                          fontSize: 12 * fontScale,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text:
                                      ' and become a\nmember to start mission',
                                      style: GoogleFonts.inter(
                                          fontSize: 12 * fontScale,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── PROFILE PICTURE UPLOAD ─────────────────────────
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickProfileImage,
                          child: Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey[300]!, width: 1.5),
                              boxShadow: [BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8)],
                            ),
                            child: _profileImage != null
                                ? ClipOval(
                                child: Image.file(
                                    _profileImage!,
                                    fit: BoxFit.cover))
                                : Icon(Icons.camera_alt_outlined,
                                size: 28,
                                color: Colors.grey[500]),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Upload Profile Picture",
                            style: GoogleFonts.inter(
                              fontSize: 13 * fontScale,
                              color: Colors.black87,
                            )),
                      ],
                    ),
                  ),

                  // ── FORM FIELDS ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // First name
                        _label("First name", fontScale),
                        const SizedBox(height: 6),
                        TextField(
                            controller: _firstNameController,
                            style: GoogleFonts.inter(fontSize: 14 * fontScale),
                            decoration: _deco("Enter full name")),
                        const SizedBox(height: 14),

                        // Last name
                        _label("Last name", fontScale),
                        const SizedBox(height: 6),
                        TextField(
                            controller: _lastNameController,
                            style: GoogleFonts.inter(fontSize: 14 * fontScale),
                            decoration: _deco("Enter full name")),
                        const SizedBox(height: 14),

                        // Phone number with country picker
                        _label("Phone number", fontScale),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly],
                          style: GoogleFonts.inter(fontSize: 14 * fontScale),
                          decoration: _deco(
                            "Mobile number",
                            prefix: GestureDetector(
                              onTap: _showCountryPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 26, height: 16,
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                          BorderRadius.circular(3)),
                                      child: Center(child: Text(
                                          _selectedFlag,
                                          style: const TextStyle(
                                              fontSize: 11))),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(_selectedCode,
                                        style: GoogleFonts.inter(
                                            fontSize: 14 * fontScale,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                    const SizedBox(width: 2),
                                    Icon(Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Colors.grey[600]),
                                    Container(
                                        margin: const EdgeInsets.only(
                                            left: 6),
                                        width: 1, height: 20,
                                        color: Colors.grey[300]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Email
                        _label("Email", fontScale),
                        const SizedBox(height: 6),
                        TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(fontSize: 14 * fontScale),
                            decoration: _deco("Enter email")),
                        const SizedBox(height: 14),

                        // Password
                        _label("Password", fontScale),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale),
                          decoration: _deco(
                            "Enter password",
                            suffix: IconButton(
                              icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: Colors.grey[500]),
                              onPressed: () => setState(
                                      () => _passwordVisible =
                                  !_passwordVisible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Add Note (Optional)
                        _label("Add Note (Optional)", fontScale),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _noteController,
                            maxLines: 4,
                            style: GoogleFonts.inter(fontSize: 13 * fontScale),
                            decoration: _deco(
                                "Write short service presentation or welcome message here...")),
                        const SizedBox(height: 20),

                        // Terms text
                        Text(
                          "By clicking Create account, you agree to the system's Terms and policies",
                          style: GoogleFonts.inter(
                              fontSize: 12 * fontScale,
                              color: Colors.grey[600]),
                        ),

                        const SizedBox(height: 20),

                        // Register button
                        PrimaryButton(
                          text: 'Register',
                          borderRadius: 30,
                          onPressed: _isEnabled ? _handleRegister : null,
                          isDisabled: !_isEnabled,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 16),

                        // Already have account
                        Center(
                          child: GestureDetector(
                            onTap: () => Get.to(() => const LoginScreen()),
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: GoogleFonts.inter(
                                    fontSize: 13 * fontScale,
                                    color: Colors.grey[600]),
                                children: [
                                  TextSpan(
                                    text: "Login",
                                    style: GoogleFonts.inter(
                                        fontSize: 13 * fontScale,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green),
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
        fontSize: 13 * fontScale,
        fontWeight: FontWeight.w500,
        color: Colors.black87),
  );
}