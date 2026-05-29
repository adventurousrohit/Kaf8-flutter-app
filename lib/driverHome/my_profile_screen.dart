import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../Controller/user_profile_controller.dart';
import '../Service/api_service.dart';
import '../Utils/appColor.dart';
import '../Utils/avatar_widget.dart';
import '../Utils/responsiveUtils.dart';
import '../profile/ChangePasswordScreen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _firstNameController      = TextEditingController();
  final _lastNameController       = TextEditingController();
  final _phoneController          = TextEditingController();
  final _locationController       = TextEditingController();
  final _licenseController        = TextEditingController();
  final _serviceAreaController    = TextEditingController();
  final _bioController            = TextEditingController();

  bool _loading        = true;
  bool _saving         = false;
  bool _uploadingPhoto = false;
  String? _avatarUrl;
  String _displayName  = '';
  String _email        = '';


  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final res = await ApiService.getProfile();
    if (!mounted) return;
    if (res['success'] == true && res['data'] is Map) {
      final d = res['data'] as Map;
      final fullName  = d['fullName']?.toString() ?? '';
      final firstName = d['firstName']?.toString() ?? '';
      final lastName  = d['lastName']?.toString() ?? '';
      _displayName = fullName.isNotEmpty ? fullName : '$firstName $lastName'.trim();

      _firstNameController.text   = firstName;
      _lastNameController.text    = lastName;
      _phoneController.text       = d['phone']?.toString() ?? '';
      _locationController.text    = d['location']?.toString() ?? '';
      _email                      = d['email']?.toString() ?? '';
      _avatarUrl                  = d['avatar']?.toString();

      final tp = d['TransporterProfile'];
      if (tp is Map) {
        _licenseController.text     = tp['driverLicenseNumber']?.toString() ?? '';
        _serviceAreaController.text = tp['serviceArea']?.toString() ?? '';
        _bioController.text         = tp['bio']?.toString() ?? '';

      }
    }
    setState(() => _loading = false);
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await ImagePicker().pickImage(
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
        setState(() => _avatarUrl = url);
        // Sync the global controller so every screen using it reflects the new photo
        Get.find<UserProfileController>().refreshProfile();
      }
    } else {
      Get.snackbar("Error",
          res['message']?.toString() ?? "Failed to upload photo",
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final firstName = _firstNameController.text.trim();
    final lastName  = _lastNameController.text.trim();

    final userRes = await ApiService.updateProfile({
      'firstName': firstName,
      'lastName':  lastName,
      'fullName':  '$firstName $lastName'.trim(),
      'phone':     _phoneController.text.trim(),
      'location':  _locationController.text.trim(),
    });

    final tpRes = await ApiService.updateTransporterProfile({
      'driverLicenseNumber': _licenseController.text.trim(),
      'serviceArea':         _serviceAreaController.text.trim(),
      'bio':                 _bioController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _saving = false);

    if (userRes['success'] == true && tpRes['success'] == true) {
      Get.snackbar("Saved", "Profile updated successfully",
          backgroundColor: Colors.green, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      Navigator.pop(context);
    } else {
      final msg = userRes['message']?.toString() ?? tpRes['message']?.toString() ?? "Update failed";
      Get.snackbar("Error", msg,
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _licenseController.dispose();
    _serviceAreaController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {bool readOnly = false, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
      filled: true,
      fillColor: readOnly ? Colors.grey[50] : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: prefix,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Appcolor.secondaryColor, width: 1.5)),
    );
  }

  Widget _fieldLabel(String text, double fontScale) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 13 * fontScale,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
      );

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
                              border: Border.all(color: Colors.grey[400]!, width: 1.5)),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 15, color: Colors.black),
                        ),
                      ),
                      const Spacer(),
                      Text("My Profile",
                        style: GoogleFonts.inter(
                            fontSize: 17 * fontScale,
                            fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),

                              // Avatar
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
                                          ? const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: CircularProgressIndicator(strokeWidth: 2))
                                          : ClipOval(
                                              child: AvatarWidget(
                                                avatarUrl: _avatarUrl,
                                                name: _displayName,
                                                radius: 42,
                                              ),
                                            ),
                                    ),
                                    Positioned(
                                      bottom: 0, right: 0,
                                      child: GestureDetector(
                                        onTap: _uploadingPhoto ? null : _pickAndUploadAvatar,
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

                              // First name
                              _fieldLabel("First Name", fontScale),
                              TextField(
                                controller: _firstNameController,
                                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                                decoration: _inputDecoration("First name"),
                              ),

                              const SizedBox(height: 14),

                              // Last name
                              _fieldLabel("Last Name", fontScale),
                              TextField(
                                controller: _lastNameController,
                                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                                decoration: _inputDecoration("Last name"),
                              ),

                              const SizedBox(height: 14),

                              // Phone
                              _fieldLabel("Phone Number", fontScale),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
                                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                                decoration: _inputDecoration("Phone number"),
                              ),

                              const SizedBox(height: 14),

                              // Location
                              _fieldLabel("Your Location", fontScale),
                              TextField(
                                controller: _locationController,
                                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                                decoration: _inputDecoration("City / area",
                                    prefix: Icon(Icons.my_location_outlined,
                                        size: 20, color: Colors.grey[500])),
                              ),

                              const SizedBox(height: 14),

                              // Email (read-only)
                              _fieldLabel("Email", fontScale),
                              TextField(
                                readOnly: true,
                                controller: TextEditingController(text: _email),
                                style: GoogleFonts.inter(
                                    fontSize: 14 * fontScale,
                                    color: Colors.grey[500]),
                                decoration: _inputDecoration("Email", readOnly: true),
                              ),

                              const SizedBox(height: 20),

                              // ── Driver-specific fields ────────────────
                              _sectionHeader("Driver Details", fontScale),
                              const SizedBox(height: 12),

                              // Driver license number
                              _fieldLabel("Driver License Number", fontScale),
                              TextField(
                                controller: _licenseController,
                                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                                decoration: _inputDecoration("License number"),
                              ),

                              const SizedBox(height: 14),

                              // Service area
                              _fieldLabel("Service Area", fontScale),
                              TextField(
                                controller: _serviceAreaController,
                                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                                decoration: _inputDecoration("e.g. Paris, Lyon, Marseille"),
                              ),

                              const SizedBox(height: 14),

                              // Bio / Note
                              _fieldLabel("About / Note (Optional)", fontScale),
                              TextField(
                                controller: _bioController,
                                maxLines: 3,
                                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                                decoration: _inputDecoration(
                                    "Short service presentation or welcome message..."),
                              ),

                              const SizedBox(height: 20),

                              // Change password
                              GestureDetector(
                                onTap: () => Get.to(() => const ChangePasswordScreen()),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.lock_outline,
                                          color: Appcolor.secondaryColor, size: 20),
                                      const SizedBox(width: 12),
                                      Text("Change Password",
                                          style: GoogleFonts.inter(
                                              fontSize: 14 * fontScale,
                                              fontWeight: FontWeight.w500,
                                              color: Appcolor.secondaryColor)),
                                      const Spacer(),
                                      Icon(Icons.chevron_right,
                                          color: Colors.grey[400], size: 20),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Save button
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
                                    _saving ? "Saving..." : "Save Changes",
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

  Widget _sectionHeader(String title, double fontScale) => Text(
    title,
    style: GoogleFonts.inter(
        fontSize: 15 * fontScale,
        fontWeight: FontWeight.w700,
        color: Colors.black87),
  );

}
