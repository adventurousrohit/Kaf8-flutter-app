import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsiveUtils.dart';
import 'AddAddressScreen.dart';

class AddressScreens extends StatefulWidget {
  const AddressScreens({super.key});

  @override
  State<AddressScreens> createState() => _AddressScreensState();
}

class _AddressScreensState extends State<AddressScreens> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _addresses = [
    {'name': 'John galliano', 'phone': '+1 3712 3789', 'address': 'NYC, Broadway ave 79'},
    {'name': 'John galliano', 'phone': '+1 3712 3789', 'address': 'NYC, Broadway ave 79'},
    {'name': 'John galliano', 'phone': '+1 3712 3789', 'address': 'NYC, Broadway ave 79'},
  ];

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // ── Top-left geometric background ──────────────────────────
          Positioned(
            top: 0, left: 0,
            child: Image.asset(
              'assets/images/bg_top_left.png',
              width: size.width * 0.62,
              fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.20),
            ),
          ),
          // ── Top-right ──────────────────────────────────────────────
          Positioned(
            top: 0, right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.36,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.13),
              ),
            ),
          ),
          // ── Bottom-right ───────────────────────────────────────────
          Positioned(
            bottom: 0, right: 0,
            child: Image.asset(
              'assets/images/bg_bottom_right.png',
              width: size.width * 0.50,
              fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.25),
            ),
          ),

          // ── Main content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Circle back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
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
                        "Address",
                        style: GoogleFonts.inter(
                          fontSize: 17 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      // Plus button
                      GestureDetector(
                        onTap: () => Get.to(() => const AddAddressScreen()),
                        child: const Icon(Icons.add,
                            size: 24, color: Colors.black),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Address list ─────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final addr = _addresses[index];
                      final bool selected = _selectedIndex == index;

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: text + Change button
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      addr['name']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 16 * fontScale,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      addr['phone']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13 * fontScale,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      addr['address']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13 * fontScale,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Green Change pill button
                                    GestureDetector(
                                      onTap: () => Get.to(
                                              () => const AddAddressScreen()),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "Change",
                                          style: GoogleFonts.inter(
                                            fontSize: 13 * fontScale,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Right: radio / checkmark
                              selected
                                  ? Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    size: 14, color: Colors.white),
                              )
                                  : Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.grey[400]!,
                                      width: 1.5),
                                ),
                              ),
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