import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/appColor.dart';
import '../Utils/responsiveUtils.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});
  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _cardNumberController = TextEditingController();
  final _expireController     = TextEditingController();
  final _cvvController        = TextEditingController();

  bool _makeDefault = true;
  bool _saveCard    = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expireController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[300]!)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Appcolor.secondaryColor, width: 1.5)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );

  bool get _isEnabled =>
    _cardNumberController.text.replaceAll(' ', '').length >= 16 &&
    _expireController.text.length >= 7 &&
    _cvvController.text.length >= 3;

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // X close button row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[400]!, width: 1.5)),
                      child: const Icon(Icons.close, size: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text("Add credit or debit card",
                      style: GoogleFonts.inter(
                        fontSize: 20 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                    const SizedBox(height: 6),
                    Text(
                      "Your payment details are stored securely.\nBy adding a card, you won't be charged yet.",
                      style: GoogleFonts.inter(
                        fontSize: 12 * fontScale, color: Colors.grey[500])),

                    const SizedBox(height: 24),

                    // Scan my card button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {},
                        child: Text("Scan my card",
                          style: GoogleFonts.inter(
                            fontSize: 15 * fontScale,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Name on card label + field
                    Text("Name on card",
                      style: GoogleFonts.inter(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberFormatter(),
                      ],
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(fontSize: 16 * fontScale,
                        letterSpacing: 2, color: Colors.grey[400]),
                      decoration: _fieldDeco("0000 0000 0000 0000"),
                    ),

                    const SizedBox(height: 20),

                    // Expire + CVV row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Expire date",
                                style: GoogleFonts.inter(
                                  fontSize: 13 * fontScale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _expireController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ExpireDateFormatter(),
                                ],
                                onChanged: (_) => setState(() {}),
                                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                                decoration: _fieldDeco("MM / YYYY"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("CVV",
                                    style: GoogleFonts.inter(
                                      fontSize: 13 * fontScale,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.help_outline,
                                    size: 15, color: Colors.grey[500]),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 4,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly],
                                onChanged: (_) => setState(() {}),
                                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                                decoration: _fieldDeco("123")
                                  .copyWith(counterText: ''),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Make default toggle row
                    _toggleRow(
                      label: "Make this my default card",
                      value: _makeDefault,
                      fontScale: fontScale,
                      onChanged: (v) => setState(() => _makeDefault = v),
                    ),

                    const SizedBox(height: 12),

                    // Save card toggle row
                    _toggleRow(
                      label: "Save this card for next time",
                      value: _saveCard,
                      fontScale: fontScale,
                      onChanged: (v) => setState(() => _saveCard = v),
                      useRadio: true,
                    ),

                    const SizedBox(height: 36),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEnabled ? Colors.green : Colors.green.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                        onPressed: _isEnabled
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Card added successfully!"),
                                  backgroundColor: Colors.green));
                              Navigator.pop(context);
                            }
                          : null,
                        child: Text("Add",
                          style: GoogleFonts.inter(
                            fontSize: 16 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow({
    required String label,
    required bool value,
    required double fontScale,
    required ValueChanged<bool> onChanged,
    bool useRadio = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: GoogleFonts.inter(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w600,
            color: Colors.black)),
        useRadio
          ? GestureDetector(
              onTap: () => onChanged(!value),
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: value ? Colors.green : Colors.grey[400]!,
                    width: 2),
                  color: value ? Colors.green : Colors.white),
                child: value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
              ),
            )
          : Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[300],
            ),
      ],
    );
  }
}

// ── Card number formatter (groups of 4) ──────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

// ── Expire date formatter MM / YYYY ──────────────────────────────────────────
class _ExpireDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 6; i++) {
      if (i == 2) buffer.write(' / ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}
