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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: 1.18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor, width: 1.02),
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
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w400,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
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
                  ? theme.primaryColor
                  : theme.dividerColor.withOpacity(0.1),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 16,
                color: isSelected ? Colors.white : theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
