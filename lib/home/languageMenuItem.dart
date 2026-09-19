import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageMenuItemWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;


  const LanguageMenuItemWidget({
    super.key,
    required this.imagePath,
    this.trailingText,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child:
        ListTile(
          leading: Image.asset(
            imagePath,
            width: 20,
            height: 20,
            color: isDark ? Colors.white70 : null,
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                trailingText ?? "English",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),          onTap: onTap,
        ),
      );
  }
}