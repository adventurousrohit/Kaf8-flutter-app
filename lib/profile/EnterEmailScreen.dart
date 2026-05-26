import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // Background shapes
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
                  // color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.grey[400]!, width: 1.5),
                            color: Colors.white.withOpacity(0.6)),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 15, color: Colors.black),
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

                        // Email label
                        Text("Email",
                          style: GoogleFonts.inter(
                              fontSize: 14 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                        const SizedBox(height: 8),

                        // Email field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale),
                          decoration: InputDecoration(
                            hintText: "Enter email",
                            hintStyle: GoogleFonts.inter(
                                color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                BorderSide(color: Colors.grey[300]!)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Appcolor.secondaryColor,
                                    width: 1.5)),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Success message (shown after tapping Continue)
                        if (_linkSent) ...[
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  "Password reset link has been sent to your email.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      fontSize: 13 * fontScale,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Please check mail box or spam:",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      fontSize: 13 * fontScale,
                                      color: Colors.black87),
                                ),
                                Text(
                                  "dinh*******@gmail.com",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      fontSize: 13 * fontScale,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Continue button
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
                            onPressed: () {
                              if (_emailController.text.isNotEmpty) {
                                setState(() => _linkSent = true);
                                Future.delayed(
                                    const Duration(seconds: 2), () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const ChangePasswordScreen()),
                                  );
                                });
                              }
                            },
                            child: Text("Continue",
                              style: GoogleFonts.inter(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.w600,
                                  color: _emailController.text.isNotEmpty
                                      ? Colors.white
                                      : Colors.grey[600])),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // SMS fallback
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Haven't receive the email? ",
                              style: GoogleFonts.inter(
                                  fontSize: 13 * fontScale,
                                  color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: "Sant OTP via SMS",
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
