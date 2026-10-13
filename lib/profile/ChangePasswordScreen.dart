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

  InputDecoration _fieldDeco(String hint, bool visible, VoidCallback toggle, ThemeData theme,
      {IconData prefixIconData = Icons.lock_outline}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: theme.cardColor,
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
          borderSide: BorderSide(color: theme.dividerColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Appcolor.secondaryColor, width: 1.5)),
    );
  }

  Future<void> _handleSubmit() async {
    final newPw   = _newPasswordController.text;
    final confirm = _confirmController.text;

    if (newPw != confirm) {
      Get.snackbar('error'.tr, 'auth_password_mismatch'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (newPw.length < 6) {
      Get.snackbar('error'.tr, 'auth_password_too_short'.tr,
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
        'error'.tr,
        response['message']?.toString() ?? 'auth_failed_change_password'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
              top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.60, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.18))),
          Positioned(
              top: 0, right: 0,
              child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.36, fit: BoxFit.contain,
                      opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.13)))),
          Positioned(
              bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.55, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.28))),

          SafeArea(
            child: Column(
              children: [
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? Colors.white24 : Colors.grey[400]!, width: 1.5),
                              color: theme.cardColor.withOpacity(0.6)),
                          child: Icon(Icons.arrow_back_ios_new,
                              size: 15, color: theme.iconTheme.color),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _isAuthFlow
                            ? 'auth_change_password'.tr
                            : 'auth_reset_password'.tr,
                        style: GoogleFonts.inter(
                            fontSize: 17 * fontScale, fontWeight: FontWeight.w600, color: theme.textTheme.titleLarge?.color),
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
                          _label('auth_current_password'.tr, fontScale, theme),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _currentPasswordController,
                            obscureText: !_currentVisible,
                            style: GoogleFonts.inter(fontSize: 14 * fontScale, color: theme.textTheme.bodyLarge?.color),
                            decoration: _fieldDeco(
                                'auth_enter_current_password'.tr, _currentVisible,
                                () => setState(() => _currentVisible = !_currentVisible), theme),
                          ),
                          const SizedBox(height: 18),
                        ] else ...[
                          // ── Forgot-password flow: reset code ────────
                          _label('auth_reset_code'.tr, fontScale, theme),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inter(fontSize: 14 * fontScale, color: theme.textTheme.bodyLarge?.color),
                            decoration: InputDecoration(
                              hintText: 'auth_reset_code_email_hint'.tr,
                              hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[400], fontSize: 14),
                              filled: true,
                              fillColor: theme.cardColor,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              prefixIcon: Icon(Icons.pin_outlined,
                                  size: 18, color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: theme.dividerColor)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: theme.dividerColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Appcolor.secondaryColor, width: 1.5)),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        _label('auth_new_password'.tr, fontScale, theme),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: !_newVisible,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale, color: theme.textTheme.bodyLarge?.color),
                          decoration: _fieldDeco(
                              'auth_enter_new_password'.tr, _newVisible,
                              () => setState(() => _newVisible = !_newVisible), theme),
                        ),

                        const SizedBox(height: 18),

                        _label('auth_confirm_password'.tr, fontScale, theme),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmController,
                          obscureText: !_confirmVisible,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale, color: theme.textTheme.bodyLarge?.color),
                          decoration: _fieldDeco(
                              'auth_reenter_new_password'.tr, _confirmVisible,
                              () => setState(
                                  () => _confirmVisible = !_confirmVisible), theme),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isEnabled ? Colors.green : (isDark ? Colors.white10 : Colors.grey[300]),
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
                                        ? 'auth_change_password'.tr
                                        : 'auth_reset_password'.tr,
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

  Widget _label(String text, double fontScale, ThemeData theme) => Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87)),
      );
}

class _SuccessDialog extends StatelessWidget {
  final VoidCallback onReturn;
  final bool isAuthFlow;
  const _SuccessDialog({required this.onReturn, required this.isAuthFlow});

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
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
              isAuthFlow
                  ? 'auth_password_changed'.tr
                  : 'auth_password_reset'.tr,
              style: GoogleFonts.inter(
                  fontSize: 18 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color),
            ),
            const SizedBox(height: 8),
            Text(
              isAuthFlow
                  ? 'auth_password_updated'.tr
                  : 'auth_password_reset_success'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13 * fontScale, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
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
                  isAuthFlow ? 'auth_done'.tr : 'auth_back_to_login'.tr,
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
