import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';
import '../Utils/appColor.dart';
import '../Utils/responsiveUtils.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _labelController         = TextEditingController();
  final _detailAddressController = TextEditingController();

  String? _selectedCity;
  String? _selectedRegion;

  final List<String> _cities = [
    'Paris', 'Lyon', 'Marseille', 'Toulouse', 'Nice',
    'Bordeaux', 'Nantes', 'Strasbourg', 'Lille', 'Rennes',
  ];

  final List<String> _regions = [
    'Île-de-France', 'Auvergne-Rhône-Alpes', 'Provence-Alpes-Côte d\'Azur',
    'Occitanie', 'Nouvelle-Aquitaine', 'Bretagne', 'Normandie',
    'Grand Est', 'Hauts-de-France', 'Pays de la Loire',
  ];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _labelController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  bool get _isEnabled =>
      !_isSubmitting &&
      _labelController.text.isNotEmpty &&
      _selectedCity != null &&
      _detailAddressController.text.isNotEmpty;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final response = await ApiService.createAddress({
      "label": _labelController.text.trim(),
      "city": _selectedCity,
      "region": _selectedRegion,
      "detailAddress": _detailAddressController.text.trim(),
      "country": "France",
    });
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (response['success'] == true) {
      Get.back(result: true);
      return;
    }
    Get.snackbar(
      "Error",
      response['message']?.toString() ?? "Failed to save address",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

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
                    // Label
                    _fieldLabel("Label (e.g. Home, Work)", fontScale),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _labelController,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(fontSize: 14 * fontScale),
                      decoration: _inputDeco("Home, Office..."),
                    ),

                    const SizedBox(height: 18),

                    // City dropdown
                    _fieldLabel("City", fontScale),
                    const SizedBox(height: 8),
                    _dropdownField(
                      hint: "Select city",
                      value: _selectedCity,
                      items: _cities,
                      fontScale: fontScale,
                      onChanged: (val) =>
                          setState(() => _selectedCity = val),
                    ),

                    const SizedBox(height: 18),

                    // Region dropdown
                    _fieldLabel("Region (optional)", fontScale),
                    const SizedBox(height: 8),
                    _dropdownField(
                      hint: "Select region",
                      value: _selectedRegion,
                      items: _regions,
                      fontScale: fontScale,
                      onChanged: (val) =>
                          setState(() => _selectedRegion = val),
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
                            ? _submit
                            : null,
                        child: Text(
                          _isSubmitting ? "Saving..." : "Confirm",
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
