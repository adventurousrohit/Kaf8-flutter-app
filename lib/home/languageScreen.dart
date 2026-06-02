import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../module/userProfileScreen/getx/languageController.dart';

class LanguageScreens extends StatelessWidget {
  LanguageScreens({super.key});

  final LanguageController controller = Get.find();
  final List<String> languages = [
    "English",
    "Hindi",
    "Sanskrit",
    "Urdu",
    "French",
    "Spanish",
    "Chinese",
    "Japanese",
    "Korean",
  ];

  @override
  Widget build(BuildContext context) {
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
              Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : const Color(0XFF60655C),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          "Language",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right:15),
            child: Center(
              child: Text(
                "Save",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0XFF00C853),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          return Obx(
            () => Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  languages[index],
                  style: GoogleFonts.poppins(fontSize: 15,fontWeight: FontWeight.w400, color: theme.textTheme.bodyLarge?.color),
                ),
                trailing: Icon(
                  controller.selectedLanguage.value == languages[index]
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked,
                  color:
                      controller.selectedLanguage.value == languages[index]
                          ? const Color(0XFF00C853)
                          : Colors.grey.shade400,
                ),
                onTap: () {
                  controller.updateLanguage(languages[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
