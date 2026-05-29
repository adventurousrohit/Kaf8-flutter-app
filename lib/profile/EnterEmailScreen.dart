import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';
import '../Utils/appColor.dart';
import '../Utils/responsiveUtils.dart';
import 'ChangePasswordScreen.dart';

class EnterEmailScreen extends StatefulWidget {
  const EnterEmailScreen({super.key});

  @override
  State<EnterEmailScreen> createState() => _EnterEmailScreenState();
}

class _EnterEmailScreenState extends State<EnterEmailScreen> {
  final _emailController = TextEditingController();
  bool _linkSent = false;
  bool _isLoading = false;
  String _maskedEmail = '';

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}*@$domain';
    return '${name.substring(0, 2)}${'*' * (name.length - 2)}@$domain';
  }

  void _handleContinue() async {
    final email = _emailController.text.trim();

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Please enter a valid email address",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.forgotPassword(email: email);

    setState(() => _isLoading = false);

    if (response['success'] == true) {
      setState(() {
        _linkSent = true;
        _maskedEmail = _maskEmail(email);
      });
    } else {
      Get.snackbar(
        "Error",
        response['message'] ?? "Failed to send reset code",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          Positioned(top: 0, left: 0,
            child: Image.asset('assets/images/bg_top_left.png',
              width: size.width * 0.60, fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.18))),
          Positioned(top: 0, right: 0,
            child: Transform(alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset('assets/images/bg_bottom_right.png',
                width: size.width * 0.36, fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.13)))),
          Positioned(bottom: 0, right: 0,
            child: Image.asset('assets/images/bg_bottom_right.png',
              width: size.width * 0.55, fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.28))),

          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[400]!, width: 1.5),
                            color: Colors.white.withOpacity(0.6)),
                          child: const Icon(Icons.arrow_back_ios_new, size: 15, color: Colors.black),
                        ),
                      ),
                      const Spacer(),
                      Text("Enter Email",
                        style: GoogleFonts.inter(
                            fontSize: 17 * fontScale,
                            fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        Text("Email",
                          style: GoogleFonts.inter(
                              fontSize: 14 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                        const SizedBox(height: 8),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_linkSent,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale),
                          decoration: InputDecoration(
                            hintText: "Enter email",
                            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Appcolor.secondaryColor, width: 1.5)),
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (_linkSent) ...[
                          Center(
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
                                const SizedBox(height: 10),
                                Text(
                                  "A reset code has been sent to:",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(fontSize: 13 * fontScale, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _maskedEmail,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      fontSize: 14 * fontScale,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 16),
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
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChangePasswordScreen(
                                            email: _emailController.text.trim(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text("Enter Reset Code",
                                      style: GoogleFonts.inter(
                                          fontSize: 16 * fontScale,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _emailController.text.isNotEmpty
                                    ? Colors.green
                                    : Colors.grey[300],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: (_emailController.text.isNotEmpty && !_isLoading)
                                  ? _handleContinue
                                  : null,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Text("Continue",
                                      style: GoogleFonts.inter(
                                          fontSize: 16 * fontScale,
                                          fontWeight: FontWeight.w600,
                                          color: _emailController.text.isNotEmpty
                                              ? Colors.white
                                              : Colors.grey[600])),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Haven't received the email? ",
                              style: GoogleFonts.inter(fontSize: 13 * fontScale, color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: "Send OTP via SMS",
                                  style: GoogleFonts.inter(
                                      fontSize: 13 * fontScale,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
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
