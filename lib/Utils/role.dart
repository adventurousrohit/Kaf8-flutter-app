// lib/shared_domain/auth/role/role_card.dart

import 'package:kaf8/Utils/responsiveUtils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'appColor.dart';

class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isSelected;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.componentScale(context);
    final fontScale = ResponsiveUtils.fontScale(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.grey.shade300, width: 1.18),
        // border: Border.all(color: const Color(0xFFE4F3FF), width: 1.18),
        // boxShadow: [
        //   BoxShadow(
        //     color: const Color(0x40C5E6FF),
        //     spreadRadius: 5.34,
        //     blurRadius: 17.2,
        //     offset: const Offset(5.34, 5.34),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.02),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Image.asset(
              imagePath,
              width: 40 * scale,
              height: 40 * scale,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18 * fontScale,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2E2E2C),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(width: 24),
          SizedBox(
            width: 24,
            height: 24,
            child: CircleAvatar(
              backgroundColor: isSelected
                  ? Appcolor.primaryColor
                  : const Color(0xFFE6F0FA),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 16,
                color: isSelected ? Colors.white : Appcolor.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
