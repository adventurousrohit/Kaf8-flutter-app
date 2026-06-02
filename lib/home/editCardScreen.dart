import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/delivery_textfiled.dart';
import '../../../small-widgets/app_colors.dart';
import '../module/userProfileScreen/getx/switchController.dart';

class EditCardScreen extends StatelessWidget {
  const EditCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SwitchController switchController = Get.put(SwitchController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(Icons.arrow_back_ios, color: theme.iconTheme.color, size: 18),
              const SizedBox(width: 4),
              Text(
                "Back",
                style: GoogleFonts.poppins(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        title: Text("Edit a card ",style: GoogleFonts.poppins(fontWeight: FontWeight.bold,fontSize: 17, color: theme.textTheme.titleLarge?.color),),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
            onPressed: () {},
          ),        ],
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Set as default",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Obx(
                        () => Switch(
                      value: switchController.isDefault.value,
                      onChanged: (val) {
                        switchController.toggleDefault(val);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0XFF00C853),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(thickness: 1, color: theme.dividerColor),
            ),
            const SizedBox(height: 12),
            DeliveryTextFormField(hintText: "Daniel Jones",hintStyle:GoogleFonts.poppins(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 13),),
            const SizedBox(height: 12),
            DeliveryTextFormField(hintText: "1234 5678 9012 3456",hintStyle:GoogleFonts.poppins(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 13)),
            const SizedBox(height: 12),
            DeliveryTextFormField(hintText: "07 / 26",hintStyle:GoogleFonts.poppins(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 13)),
            const SizedBox(height: 12),
            DeliveryTextFormField(hintText: "123",hintStyle:GoogleFonts.poppins(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 13)),
            const SizedBox(height: 153),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  "Save",
                  style: GoogleFonts.inter(
                    fontSize: 18.52,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
