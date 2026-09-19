import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../Controller/user_profile_controller.dart';
import '../Service/api_service.dart';
import '../Utils/appColor.dart';
import '../Utils/avatar_widget.dart';
import '../Utils/responsiveUtils.dart';

class PersonalEditingScreen extends StatefulWidget {
  const PersonalEditingScreen({super.key});

  @override
  State<PersonalEditingScreen> createState() => _PersonalEditingScreenState();
}

class _PersonalEditingScreenState extends State<PersonalEditingScreen> {
  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _saving        = false;
  bool _uploadingPhoto = false;
  String? _localAvatarUrl;

  late final UserProfileController _profileCtrl;

  @override
  void initState() {
    super.initState();
    _profileCtrl = Get.find<UserProfileController>();
    _populateFromController();
  }

  void _populateFromController() {
    final p = _profileCtrl.profile.value;
    if (p == null) return;
    _nameController.text  = _profileCtrl.displayName;
    _emailController.text = p['email']?.toString() ?? '';
    _phoneController.text = p['phone']?.toString() ?? '';
    _localAvatarUrl = _profileCtrl.avatarUrl;
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    final res = await ApiService.uploadAvatar(picked.path);
    if (!mounted) return;
    setState(() => _uploadingPhoto = false);

    if (res['success'] == true) {
      final url = res['data']?['avatarUrl']?.toString();
      if (url != null) {
        setState(() => _localAvatarUrl = url);
        await _profileCtrl.refreshProfile();
      }
    } else {
      Get.snackbar('error'.tr,
          res['message']?.toString() ?? "Failed to upload photo",
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final res = await ApiService.updateProfile({
      'fullName': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (res['success'] == true) {
      await _profileCtrl.refreshProfile();
      if (!mounted) return;
      Get.snackbar('saved'.tr, 'profile_updated'.tr,
          backgroundColor: Colors.green, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      Navigator.pop(context);
    } else {
      Get.snackbar('error'.tr, res['message']?.toString() ?? 'update_failed'.tr,
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, ThemeData theme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          Positioned(top: 0, left: 0,
            child: Image.asset('assets/images/bg_top_left.png',
              width: size.width * 0.60, fit: BoxFit.contain,
              opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.18))),
          Positioned(top: 0, right: 0,
            child: Transform(alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset('assets/images/bg_bottom_right.png',
                width: size.width * 0.36, fit: BoxFit.contain,
                opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.13)))),
          Positioned(bottom: 0, right: 0,
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
                            border: Border.all(color: isDark ? Colors.white24 : Colors.grey[400]!, width: 1.5)),
                          child: Icon(Icons.arrow_back_ios_new,
                              size: 15, color: theme.iconTheme.color),
                        ),
                      ),
                      const Spacer(),
                      Text('edit_profile_title'.tr,
                        style: GoogleFonts.inter(
                            fontSize: 17 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.titleLarge?.color)),
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
                        const SizedBox(height: 10),

                        // ── Avatar with edit button ────────────────
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 90, height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Appcolor.secondaryColor,
                                      width: 2.5)),
                                child: _uploadingPhoto
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 2)
                                    : ClipOval(
                                        child: AvatarWidget(
                                          avatarUrl: _localAvatarUrl,
                                          name: _nameController.text,
                                          radius: 42,
                                        ),
                                      ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: GestureDetector(
                                  onTap: _uploadingPhoto
                                      ? null
                                      : _pickAndUploadAvatar,
                                  child: Container(
                                    width: 26, height: 26,
                                    decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.edit,
                                        size: 13, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Full name
                        Text('full_name_label'.tr,
                          style: GoogleFonts.inter(
                              fontSize: 13 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale, color: theme.textTheme.bodyLarge?.color),
                          decoration: _inputDecoration('full_name_label'.tr, theme),
                        ),

                        const SizedBox(height: 14),

                        // Email (read-only)
                        Text('email'.tr,
                          style: GoogleFonts.inter(
                              fontSize: 13 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          readOnly: true,
                          style: GoogleFonts.inter(
                              fontSize: 14 * fontScale,
                              color: Colors.grey[500]),
                          decoration: _inputDecoration('email'.tr, theme),
                        ),

                        const SizedBox(height: 14),

                        // Phone
                        Text('phone_label'.tr,
                          style: GoogleFonts.inter(
                              fontSize: 13 * fontScale,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.inter(fontSize: 14 * fontScale, color: theme.textTheme.bodyLarge?.color),
                          decoration: _inputDecoration('phone_label'.tr, theme),
                        ),

                        const SizedBox(height: 30),

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
                            onPressed: _saving ? null : _save,
                            child: Text(
                              _saving ? 'saving'.tr : 'save_changes'.tr,
                              style: GoogleFonts.inter(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
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
