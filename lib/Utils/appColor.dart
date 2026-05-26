// lib/core/Constants/Appcolor.dart

import 'package:flutter/material.dart';

class Appcolor {
  // static const Color secondaryColor = Color.fromRGBO(67, 34, 119, 1);
  static const Color secondaryColor = Color(0xFF00C853);

  static const Color primaryColor = Color(0xFF00C853);
  // static const Color primaryColor = Color(0xFF67C0FB);

  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
  static const Color greyColors = Color(0xFFE8EBE6);
  static const Color errorColor = Colors.redAccent;
  static const Color greenColor = Colors.green;

  static const Color greenDeepColor = Color(0xFF03443C);
  static const Color transparentColor = Colors.transparent;

  // Banner gradient colors
  static const Color bannerPurpleDark = Color(
    0xFF432277,
  ); // #432277 - matches secondaryColor
  static const Color bannerPurpleLight = Color(
    0xFF5E35B1,
  ); // Left side gradient start
  static const Color bannerPurpleMid = Color(
    0xFF7E57C2,
  ); // Left side gradient end


  static const Color bannerBlueLight = Color(
    0xFF81D4FA,
  ); // Right side light blue
  static const Color bannerBluePrimary = Color(
    0xFF67C0FB,
  ); // matches primaryColor
}
