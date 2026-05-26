import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/components/sizeBox.dart';

import '../small-widgets/app_colors.dart';
import 'delivery_textWidget.dart';

class NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }
    return newValue;
  }
}

class DeliveryTextFormField extends StatelessWidget {
  final Color? cursorColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final Color? hintColor;
  final bool showBorder;
  final bool? filled;
  final bool? isDense;
  final TextInputType? keyboardType;
  final bool obscureText;
  final InputBorder? border;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool? readOnly;
  final String? prefixText;
  final String? hintText;
  final TextStyle? hintStyle;
  final AutovalidateMode? autoValidateMode;
  final bool isPassword;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final bool? enabled;
  final int? maxLines;
  final FocusNode? focusNode;
  final Function()? onVisibilityIconTap;
  final void Function()? ontap;
  final TextAlign textAlign;
  final double? radiusTop;
  final double? radiusBottom;
  final String? label;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? contentPadding;

  const DeliveryTextFormField({
    super.key,
    this.cursorColor = AppColors.black,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.keyboardType,
    this.focusNode,
    this.ontap,
    this.readOnly,
    this.obscureText = false,
    this.showBorder = true,
    this.border,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.isDense,
    this.label,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.prefixText,
    this.isPassword = false,
    this.inputFormatters,
    this.contentPadding,
    this.textInputAction,
    this.prefixIcon,
    this.enabled,
    this.maxLines = 1,
    this.hintText,
    this.hintStyle,
    this.onVisibilityIconTap,
    this.fillColor = Colors.white,
    this.filled = true,
    this.hintColor = AppColors.black,
    this.textAlign = TextAlign.start,
    this.radiusTop = 8,
    this.radiusBottom = 8,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (focusNode != null) {
          focusNode!.requestFocus();
        } else if (ontap != null) {
          ontap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hSizedBox,
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 6, bottom: 8),
                child: BahamasTextWidget(
                  text: label!,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackBlue,
                ),
              ),
            // Yahan se TextField start hai
            TextFormField(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black),
              readOnly: readOnly ?? false,
              onTap: ontap,
              textAlign: textAlign,
              controller: controller,
              cursorColor: cursorColor,
              keyboardType: keyboardType,
              obscureText: obscureText,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field cannot be empty';
                }
                if (validator != null) {
                  return validator!(value);
                }
                return null;
              },
              enabled: enabled,
              maxLines: maxLines,
              onChanged: onChanged,
              autovalidateMode: autoValidateMode,
              inputFormatters: [
                NoLeadingSpaceFormatter(),
                if (inputFormatters != null) ...inputFormatters!,
              ],
              textInputAction: textInputAction,
              textAlignVertical: TextAlignVertical.center,
              expands: false,
              decoration: InputDecoration(
                isDense: isDense,
                filled: true,
                fillColor: Colors.white,
                hintText: hintText,
                hintStyle: hintStyle ?? GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                suffixIcon: isPassword
                    ? InkWell(
                  onTap: onVisibilityIconTap,
                  child: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.remove_red_eye_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                )
                    : suffixIcon,
                prefixIcon: prefixIcon,
                prefixText: prefixText,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

                // Normal Border (Grey)
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0XFFE8EBE6), width: 1.5),
                ),

                // Clicked/Focus Border (Green)
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.greyAccent, width: 1.5),
                ),

                // Error Borders
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),

                errorStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}