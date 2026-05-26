import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColorsed {
  static const Color transparent = Colors.transparent;
  static const Color primary = Color(0xFF0077B6);
  static const Color white = Colors.white;
}

class BahamasButton extends StatelessWidget {
  final GestureTapCallback? onTap;
  final double? width;
  final double? height;
  final double? textSize;
  final String buttonText;
  final Color? buttonColor;
  final Color? borderColor;
  final FontWeight? fontWeight;
  final Color textColor; // Ab ye 'Color?' nahi, sirf 'Color' hai (Required ke liye)
  final TextStyle? textStyle;
  final BorderRadius? radius;
  final bool isLoading;
  final Widget? prefixIcon;
  final MainAxisAlignment contentAlignment;

  const BahamasButton({
    super.key,
    required this.onTap,
    this.width,
    this.height,
    this.textSize,
    required this.buttonText,
    this.buttonColor,
    this.borderColor,
    required this.textColor, // Isko yahan 'required' mark kar diya
    this.textStyle,
    this.radius,
    this.isLoading = false,
    this.fontWeight,
    this.prefixIcon,
    this.contentAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 50,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: borderColor ?? AppColorsed.transparent),
          color: buttonColor ?? const Color(0XFF00778B),
          borderRadius: radius ?? BorderRadius.circular(5),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.0,
          ),
        )
            : Row(
          mainAxisAlignment: contentAlignment,
          children: <Widget>[
            if (prefixIcon != null) ...[
              prefixIcon!,
              const SizedBox(width: 8),
            ],
            Text(
              buttonText,
              textAlign: TextAlign.center,
              style: (textStyle ??
                  GoogleFonts.montserrat(
                    fontWeight: fontWeight ?? FontWeight.w600,
                    fontSize: textSize ?? 16,
                  ))
                  .copyWith(
                color: textColor, // Ab ye hamesha aapka diya hua color hi lega
              ),
            ),
          ],
        ),
      ),
    );
  }
}