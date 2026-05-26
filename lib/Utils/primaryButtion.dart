// lib/shared_domain/auth/widgets/primary_button.dart

import 'package:flutter/material.dart';
import 'package:kaf8/Utils/responsiveUtils.dart';
import 'appColor.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isLoading;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);

    return ElevatedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: Appcolor.secondaryColor,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : Text(
        text,
        style: TextStyle(
          fontSize: 16 * fontScale,
          color: Appcolor.whiteColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}