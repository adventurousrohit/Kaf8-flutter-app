import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsiveUtils.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;

    final List<Map<String, String>> fields = [
      {'label': 'Name',          'value': 'Dang Dinh Bao'},
      {'label': 'Email',         'value': 'dangdinhbao0318@gmail.com'},
      {'label': 'Date of birth', 'value': '07/03/2003'},
      {'label': 'Gender',        'value': 'Male'},
    ];

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
                            border: Border.all(color: Colors.grey[400]!, width: 1.5),
                            color: Colors.white.withOpacity(0.6)),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 15, color: Colors.black),
                        ),
                      ),
                      const Spacer(),
                      Text("Personal Information",
                        style: GoogleFonts.inter(
                            fontSize: 17 * fontScale,
                            fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: List.generate(fields.length, (i) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(fields[i]['label']!,
                                              style: GoogleFonts.inter(
                                                  fontSize: 12 * fontScale,
                                                  color: Colors.grey[500])),
                                            const SizedBox(height: 4),
                                            Text(fields[i]['value']!,
                                              style: GoogleFonts.inter(
                                                  fontSize: 15 * fontScale,
                                                  color: Colors.black87)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right,
                                          color: Colors.grey, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              if (i < fields.length - 1)
                                const Divider(height: 1, thickness: 0.8,
                                    indent: 16, endIndent: 16),
                            ],
                          );
                        }),
                      ),
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
