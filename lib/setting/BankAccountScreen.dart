import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsiveUtils.dart';
import 'AddAccountScreen.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});
  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _cards = [
    {'bank': 'BCA (Bank Central Asia)', 'number': '•••• •••• •••• 87652'},
    {'bank': 'BCA (Bank Central Asia)', 'number': '•••• •••• •••• 87652'},
    {'bank': 'BCA (Bank Central Asia)', 'number': '•••• •••• •••• 87652'},
    {'bank': 'BCA (Bank Central Asia)', 'number': '•••• •••• •••• 87652'},
  ];

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
              opacity: const AlwaysStoppedAnimation(0.25))),

          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _circleBack(context),
                      const Spacer(),
                      Text("Bank Account",
                        style: GoogleFonts.inter(
                          fontSize: 17 * fontScale,
                          fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Get.to(() => const AddAccountScreen()),
                        child: const Icon(Icons.add, size: 24, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.8),

                // Card list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    itemCount: _cards.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.8, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      final bool selected = _selectedIndex == index;
                      return InkWell(
                        onTap: () => setState(() => _selectedIndex = index),
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              // VISA logo
                              Container(
                                width: 48, height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1F71),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: Text("VISA",
                                  style: GoogleFonts.inter(
                                    fontSize: 11 * fontScale,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(card['bank']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 14 * fontScale,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                                    const SizedBox(height: 3),
                                    Text(card['number']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 12 * fontScale,
                                        color: Colors.grey[500],
                                        letterSpacing: 1)),
                                  ],
                                ),
                              ),
                              // Radio / checkmark
                              selected
                                ? Container(
                                    width: 24, height: 24,
                                    decoration: const BoxDecoration(
                                      color: Colors.green, shape: BoxShape.circle),
                                    child: const Icon(Icons.check, size: 14, color: Colors.white))
                                : Container(
                                    width: 24, height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey[400]!, width: 1.5))),
                            ],
                          ),
                        ),
                      );
                    },
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
