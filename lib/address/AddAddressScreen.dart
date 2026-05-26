import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/appColor.dart';
import '../Utils/responsiveUtils.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _nameController          = TextEditingController();
  final _emailController         = TextEditingController();
  final _detailAddressController = TextEditingController();

  String? _selectedCity;
  String? _selectedDistrict;

  final List<String> _cities = [
    'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
  ];

  final List<String> _districts = [
    'Manhattan', 'Brooklyn', 'Queens', 'Bronx', 'Staten Island',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  bool get _isEnabled =>
      _nameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _selectedCity != null &&
      _selectedDistrict != null &&
      _detailAddressController.text.isNotEmpty;

  // ── Shared input decoration ─────────────────────────────────────────────
  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
          color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Appcolor.secondaryColor, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Circle back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey[800]!, width: 1.8),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 15, color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Add Address",
                    style: GoogleFonts.inter(
                      fontSize: 17 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36), // balance
                ],
              ),
            ),

            // thin divider under header
            Divider(height: 1, thickness: 0.8, color: Colors.grey[200]),

            // ── Form ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _fieldLabel("Full Name", fontScale),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(fontSize: 14 * fontScale),
                      decoration: _inputDeco("Full Name"),
                    ),

                    const SizedBox(height: 18),

                    // Email
                    _fieldLabel("Email", fontScale),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(fontSize: 14 * fontScale),
                      decoration: _inputDeco("Email"),
                    ),

                    const SizedBox(height: 18),

                    // City dropdown
                    _fieldLabel("City", fontScale),
                    const SizedBox(height: 8),
                    _dropdownField(
                      hint: "City",
                      value: _selectedCity,
                      items: _cities,
                      fontScale: fontScale,
                      onChanged: (val) =>
                          setState(() => _selectedCity = val),
                    ),

                    const SizedBox(height: 18),

                    // District dropdown
                    _fieldLabel("District", fontScale),
                    const SizedBox(height: 8),
                    _dropdownField(
                      hint: "District",
                      value: _selectedDistrict,
                      items: _districts,
                      fontScale: fontScale,
                      onChanged: (val) =>
                          setState(() => _selectedDistrict = val),
                    ),

                    const SizedBox(height: 18),

                    // Detail Address (multiline)
                    _fieldLabel("Detail Address", fontScale),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailAddressController,
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(fontSize: 14 * fontScale),
                      decoration: _inputDeco("Enter detail address"),
                    ),

                    const SizedBox(height: 36),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEnabled
                              ? Colors.green
                              : Colors.grey[200],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _isEnabled
                            ? () {
                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          "Confirm",
                          style: GoogleFonts.inter(
                            fontSize: 16 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: _isEnabled
                                ? Colors.white
                                : Colors.grey[500],
                          ),
                        ),
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
    );
  }

  // ── Field label ──────────────────────────────────────────────────────────
  Widget _fieldLabel(String text, double fontScale) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  // ── Dropdown field ───────────────────────────────────────────────────────
  Widget _dropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required double fontScale,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.inter(
                color: Colors.grey[400], fontSize: 14 * fontScale),
          ),
          icon: Icon(Icons.keyboard_arrow_down,
              color: Colors.grey[600], size: 22),
          style: GoogleFonts.inter(
              fontSize: 14 * fontScale, color: Colors.black87),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
