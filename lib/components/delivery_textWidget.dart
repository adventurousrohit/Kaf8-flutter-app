import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../small-widgets/app_colors.dart';

class BahamasTextWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration decoration;
  final double? letterSpacing;
  final double? height;
  final TextDirection? textDirection;
  final TextStyle? styleOverride;

  const BahamasTextWidget({
    Key? key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration = TextDecoration.none,
    this.letterSpacing,
    this.height,
    this.textDirection,
    this.styleOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? theme.textTheme.bodyMedium?.color ?? AppColors.blackBlue,
      decoration: decoration,
      letterSpacing: letterSpacing,
      height: height,
    );

    return Text(
      text,
      style: styleOverride ?? defaultStyle,
      textAlign: textAlign ?? TextAlign.center,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: textDirection,
    );
  }
}
