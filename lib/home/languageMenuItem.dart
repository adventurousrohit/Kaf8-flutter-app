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
    return
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0XFFF9FAF8),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
        ListTile(
          leading: Image.asset(
            imagePath,
            width: 20,
            height: 20,
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0XFF363A33),
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