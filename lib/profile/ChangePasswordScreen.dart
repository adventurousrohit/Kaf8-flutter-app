import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Auth/loginScreen.dart';
import '../Service/api_service.dart';
import '../Utils/appColor.dart';
import '../Utils/responsiveUtils.dart';
import 'EnterEmailScreen.dart';

class ChangePasswordScreen extends StatefulWidget {
  /// When called from Profile (logged in), leave email empty → shows current-password flow.
  /// When called from forgot-password flow, pass the email → shows reset-code flow.
  final String email;
  const ChangePasswordScreen({super.key, this.email = ''});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Authenticated flow fields
  final _currentPasswordController = TextEditingController();

  // Both flows
  final _newPasswordController     = TextEditingController();
  final _confirmController         = TextEditingController();

  // Forgot-password flow only
  final _codeController = TextEditingController();

  bool _currentVisible = false;
  bool _newVisible     = false;
  bool _confirmVisible = false;
  bool _isLoading      = false;

  bool get _isAuthFlow => widget.email.isEmpty;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(() => setState(() {}));
    _newPasswordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool get _isEnabled {
    if (_isAuthFlow) {
      return _currentPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty &&
          _confirmController.text.isNotEmpty;
    } else {
      return _codeController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty &&
          _confirmController.text.isNotEmpty;
    }
  }

  InputDecoration _fieldDeco(String hint, bool visible, VoidCallback toggle,
      {IconData prefixIconData = Icons.lock_outline}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: Icon(prefixIconData, size: 18, color: Colors.grey[500]),
      suffixIcon: IconButton(
        icon: Icon(
            visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 18,
            color: Colors.grey[500]),
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
          borderSide: BorderSide(color: Appcolor.secondaryColor, width: 1.5)),
    );
  }

  Future<void> _handleSubmit() async {
    final newPw   = _newPasswordController.text;
    final confirm = _confirmController.text;

    if (newPw != confirm) {
      Get.snackbar("Error", "Passwords do not match",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (newPw.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> response;
    if (_isAuthFlow) {
      response = await ApiService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: newPw,
      );
    } else {
      response = await ApiService.resetPassword(
        email: widget.email,
        code: _codeController.text.trim(),
        newPassword: newPw,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(
          isAuthFlow: _isAuthFlow,
          onReturn: () {
            Navigator.of(context).pop();
            if (_isAuthFlow) {
              Navigator.pop(context);
            } else {
              Get.offAll(() => const LoginScreen());
            }
          },
        ),
      );
    } else {
      Get.snackbar(
        "Error",
        response['message']?.toString() ?? "Failed to change password",
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
          Positioned(
              top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.60, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.18))),
          Positioned(
              top: 0, right: 0,
              child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.36, fit: BoxFit.contain,
                      opacity: const AlwaysStoppedAnimation(0.13)))),
          Positioned(
              bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.55, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.28))),

          SafeArea(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
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
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 15, color: Colors.black),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _isAuthFlow ? "Change Password" : "Reset Password",
                        style: GoogleFonts.inter(
                            fontSize: 17 * fontScale, fontWeight: FontWeight.w600),
                      ),
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

                        if (_isAuthFlow) ...[
                          // ── Authenticated flow: current password ────
                          _label("Current Password", fontScale),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _currentPasswordController,
                            obscureText: !_currentVisible,
                            style: GoogleFonts.inter(fontSize: 14 * fontScale),
                            decoration: _fieldDeco(
                                "Enter current password", _currentVisible,
                                () => setState(() => _currentVisible = !_currentVisible)),
                          ),
                          const SizedBox(height: 18),
                        ] else ...[
                          // ── Forgot-password flow: reset code ────────
                          _label("Reset Code", fontScale),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inter(fontSize: 14 * fontScale),
                            decoration: InputDecoration(
                              hintText: "Enter 6-digit code from email",
                              hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[400], fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              prefixIcon: Icon(Icons.pin_outlined,
                                  size: 18, color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Appcolor.secondaryColor, width: 1.5)),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        _label("New Password", fontScale),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: !_newVisible,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale),
                          decoration: _fieldDeco(
                              "Enter new password", _newVisible,
                              () => setState(() => _newVisible = !_newVisible)),
                        ),

                        const SizedBox(height: 18),

                        _label("Confirm Password", fontScale),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmController,
                          obscureText: !_confirmVisible,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale),
                          decoration: _fieldDeco(
                              "Re-enter new password", _confirmVisible,
                              () => setState(
                                  () => _confirmVisible = !_confirmVisible)),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isEnabled ? Colors.green : Colors.grey[300],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: (_isEnabled && !_isLoading)
                                ? _handleSubmit
                                : null,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text(
                                    _isAuthFlow
                                        ? "Change Password"
                                        : "Reset Password",
                                    style: GoogleFonts.inter(
                                        fontSize: 16 * fontScale,
                                        fontWeight: FontWeight.w600,
                                        color: _isEnabled
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

  Widget _label(String text, double fontScale) => Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w500,
            color: Colors.black87),
      );
}

class _SuccessDialog extends StatelessWidget {
  final VoidCallback onReturn;
  final bool isAuthFlow;
  const _SuccessDialog({required this.onReturn, required this.isAuthFlow});

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
            Container(
              width: 60, height: 60,
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              isAuthFlow ? "Password Changed" : "Password Reset",
              style: GoogleFonts.inter(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              isAuthFlow
                  ? "Your password has been successfully updated."
                  : "Your password has been successfully reset. Please log in with your new password.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13 * fontScale, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                onPressed: onReturn,
                child: Text(
                  isAuthFlow ? "Done" : "Back to Login",
                  style: GoogleFonts.inter(
                      fontSize: 15 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
