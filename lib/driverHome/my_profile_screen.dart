import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '************');
  final _locationCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _obscurePassword = true;
  String? _vehicleFileName = 'Motobike.png';

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildAvatar(),
                    const SizedBox(height: 28),
                    _label('First name'),
                    _inputField('Enter First Name', _firstNameCtrl),
                    const SizedBox(height: 14),
                    _label('Last name'),
                    _inputField('Enter Last Name', _lastNameCtrl),
                    const SizedBox(height: 14),
                    _label('Phone number'),
                    _inputField('Phone', _phoneCtrl,
                        obscure: false, keyboardType: TextInputType.phone),
                    const SizedBox(height: 14),
                    _label('Your Location'),
                    _locationField(),
                    const SizedBox(height: 14),
                    _label('Email'),
                    _inputField('Enter email', _emailCtrl,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _label('Password'),
                    _passwordField(),
                    const SizedBox(height: 14),
                    _label('Upload Vehicle Image'),
                    _vehicleUpload(),
                    const SizedBox(height: 14),
                    _label('Add Note (Optional)'),
                    _noteField(),
                    const SizedBox(height: 12),
                    Text(
                      'By clicking Create account, you agree to the website\'s Terms\nand policies',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 24),
                    _buildButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.menu, size: 24, color: Colors.black87),
          const SizedBox(width: 14),
          Text('Profile',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          Stack(
            children: [
              const Icon(Icons.notifications_none,
                  size: 26, color: Colors.black87),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 17,
            backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/32.jpg'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.green.withOpacity(0.4), width: 3),
            ),
            child: const CircleAvatar(
              radius: 44,
              backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/32.jpg'),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }

  Widget _inputField(
    String hint,
    TextEditingController ctrl, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: _inputDecoration(hint),
    );
  }

  Widget _locationField() {
    return TextField(
      controller: _locationCtrl,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: _inputDecoration('').copyWith(
        prefixIcon: const Icon(Icons.location_on_outlined,
            color: Colors.grey, size: 20),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: _inputDecoration('Enter password').copyWith(
        suffixIcon: GestureDetector(
          onTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _vehicleUpload() {
    return GestureDetector(
      onTap: () {
        // image picker logic here
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  color: Colors.grey, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_vehicleFileName ?? 'Choose file',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  Text('JPEG / PNG / PDF',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteField() {
    return TextField(
      controller: _noteCtrl,
      maxLines: 4,
      style: GoogleFonts.inter(fontSize: 13),
      decoration: _inputDecoration(
              'Write short service presentation or welcome\nmessage here...')
          .copyWith(
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text('Edit',
                style: GoogleFonts.inter(
                    fontSize: 15, color: Colors.black87)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
            ),
            child: Text('Save',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.green, width: 1.5),
      ),
    );
  }
}
