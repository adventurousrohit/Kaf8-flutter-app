import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/appColor.dart';
import '../Utils/responsiveUtils.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController     = TextEditingController();
  final _newPasswordController     = TextEditingController();
  final _reenterPasswordController = TextEditingController();

  bool _oldVisible     = false;
  bool _newVisible     = false;
  bool _reenterVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _pwDecoration(String hint, bool visible,
      VoidCallback toggle) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: Icon(Icons.lock_outline,
          size: 18, color: Colors.grey[500]),
      suffixIcon: IconButton(
        icon: Icon(
          visible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 18, color: Colors.grey[500]),
        onPressed: toggle,
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: Appcolor.secondaryColor, width: 1.5)),
    );
  }

  void _handleContinue() {
    final oldPw   = _oldPasswordController.text;
    final newPw   = _newPasswordController.text;
    final reenter = _reenterPasswordController.text;

    if (oldPw.isEmpty || newPw.isEmpty || reenter.isEmpty) return;
    if (newPw != reenter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Passwords don't match"),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        code: "03456****",
        onReturn: () {
          Navigator.of(context)
            ..pop() // close dialog
            ..pop(); // go back
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;

    final bool isEnabled =
        _oldPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _reenterPasswordController.text.isNotEmpty;

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
                  color: Colors.white,
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
                      Text("Change Password",
                        style: GoogleFonts.inter(
                            fontSize: 17 * fontScale,
                            fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Old password
                        Text("Old password",
                          style: GoogleFonts.inter(
                              fontSize: 14 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _oldPasswordController,
                          obscureText: !_oldVisible,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.inter(fontSize: 14 * fontScale),
                          decoration: _pwDecoration(
                            "enter password", _oldVisible,
                                () => setState(() => _oldVisible = !_oldVisible)),
                        ),

                        const SizedBox(height: 18),

                        // New password
                        Text("New password",
                          style: GoogleFonts.inter(
                              fontSize: 14 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: !_newVisible,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.inter(fontSize: 14 * fontScale),
                          decoration: _pwDecoration(
                            "enter password", _newVisible,
                                () => setState(() => _newVisible = !_newVisible)),
                        ),

                        const SizedBox(height: 18),

                        // Reenter password
                        Text("Roenter password",
                          style: GoogleFonts.inter(
                              fontSize: 14 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _reenterPasswordController,
                          obscureText: !_reenterVisible,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.inter(fontSize: 14 * fontScale),
                          decoration: _pwDecoration(
                            "enter password", _reenterVisible,
                                () => setState(
                                    () => _reenterVisible = !_reenterVisible)),
                        ),

                        const SizedBox(height: 40),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEnabled
                                  ? Colors.green
                                  : Colors.grey[300],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: isEnabled ? _handleContinue : null,
                            child: Text("Continue",
                              style: GoogleFonts.inter(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.w600,
                                  color: isEnabled
                                      ? Colors.white
                                      : Colors.grey[600])),
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
}

// ── Success Dialog ────────────────────────────────────────────────────────────

class _SuccessDialog extends StatelessWidget {
  final String code;
  final VoidCallback onReturn;

  const _SuccessDialog({required this.code, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green check circle
            Container(
              width: 60, height: 60,
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),

            // Code
            Text(code,
              style: GoogleFonts.inter(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
            const SizedBox(height: 8),

            Text("Your password has successfully changed",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13 * fontScale,
                  color: Colors.grey[600])),
            const SizedBox(height: 24),

            // Return button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: onReturn,
                child: Text("Return",
                  style: GoogleFonts.inter(
                      fontSize: 15 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
