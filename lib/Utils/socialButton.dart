// lib/shared_domain/auth/widgets/social_button.dart

import 'package:kaf8/Utils/responsiveUtils.dart';

import 'package:flutter/material.dart';

import 'appColor.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String assetPath;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final double borderRadius;

  const SocialButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.backgroundColor,
    required this.onPressed,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.componentScale(context);
    final fontScale = ResponsiveUtils.fontScale(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            width: 50 * scale,
            height: 50 * scale,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 14 * fontScale,
              color: Appcolor.whiteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}