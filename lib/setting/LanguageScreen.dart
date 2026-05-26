import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsiveUtils.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // "Used language" section — first is selected by default
  int _usedSelected = 0;
  final List<String> _usedLanguages = ['English', 'English'];

  // "Other languages" section — none selected by default
  int? _otherSelected;
  final List<String> _otherLanguages = ['English', 'English', 'English'];

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
                      opacity: const AlwaysStoppedAnimation(0.12)))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.50, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.22))),

          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _circleBack(context),
                      const Spacer(),
                      Text("Language",
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.8),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        // ── Used language ──────────────────────────────
                        Text("Used language",
                            style: GoogleFonts.inter(
                                fontSize: 15 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            children: List.generate(
                                _usedLanguages.length, (i) => Column(
                              children: [
                                _languageRow(
                                  label: _usedLanguages[i],
                                  isSelected: _usedSelected == i,
                                  fontScale: fontScale,
                                  onTap: () => setState(
                                          () => _usedSelected = i),
                                ),
                                if (i < _usedLanguages.length - 1)
                                  const Divider(height: 1, thickness: 0.7,
                                      indent: 16, endIndent: 16),
                              ],
                            )),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Other languages ────────────────────────────
                        Text("Other languages",
                            style: GoogleFonts.inter(
                                fontSize: 15 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            children: List.generate(
                                _otherLanguages.length, (i) => Column(
                              children: [
                                _languageRow(
                                  label: _otherLanguages[i],
                                  isSelected: _otherSelected == i,
                                  fontScale: fontScale,
                                  onTap: () => setState(
                                          () => _otherSelected = i),
                                ),
                                if (i < _otherLanguages.length - 1)
                                  const Divider(height: 1, thickness: 0.7,
                                      indent: 16, endIndent: 16),
                              ],
                            )),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Confirm button ─────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Language saved: ${_usedLanguages[_usedSelected]}"),
                                      backgroundColor: Colors.green));
                              Navigator.pop(context);
                            },
                            child: Text("Confirm",
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

  Widget _circleBack(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[800]!, width: 1.8)),
        child: const Icon(Icons.arrow_back_ios_new, size: 15, color: Colors.black),
      ),
    );
  }

  Widget _languageRow({
    required String label,
    required bool isSelected,
    required double fontScale,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Radio circle
            isSelected
                ? Container(
                width: 22, height: 22,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 13, color: Colors.white))
                : Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.grey[400]!, width: 1.5))),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15 * fontScale,
                    color: isSelected ? Colors.black : Colors.grey[500],
                    fontWeight: isSelected
                        ? FontWeight.w500 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}