import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/Auth/customerstartingscreen.dart';
import 'package:kaf8/Service/api_service.dart';
import 'package:kaf8/home/deleteAccount.dart';
import '../../../small-widgets/app_assets.dart';
import '../Auth/RoleSelectionScreen.dart';
import '../Controller/theme_controller.dart';
import '../module/userProfileScreen/getx/languageController.dart';
import '../module/userProfileScreen/getx/switchController.dart';
import 'languageMenuItem.dart';
import 'languageScreen.dart';
import 'menuItemScreen.dart';

class SettingScreens extends StatelessWidget {
  const SettingScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController langController = Get.put(LanguageController());
    final SwitchController switchController = Get.put(SwitchController());
    final themeController = Get.find<ThemeController>();
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
        title: Text(
          "Setting",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: theme.textTheme.titleLarge?.color),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("General",style: GoogleFonts.poppins(fontSize: 12,
                  fontWeight: FontWeight.w600,color: isDark ? Colors.white70 : const Color(0XFF70756B)),
              ),
              const SizedBox(height: 9,),
              MenuItemWidget(imagePath:  AppAssets.switchAccount, title: "Switch Account",
                  onTap:()=> print("switch Account")
              ),
              const SizedBox(height: 9,),
              Obx(() => LanguageMenuItemWidget(
                imagePath: AppAssets.language,
                title: "Language",
                trailingText: langController.selectedLanguage.value,
                onTap: () {
                   Get.to(LanguageScreens());

                },
              )),
               const SizedBox(height: 10,),
              Obx(() => MenuSwitchWidget(
                icon: Icons.dark_mode,
                title: "dark_mode".tr,
                value: themeController.themeMode.value == ThemeMode.dark,
                onChanged: (val) => themeController.toggleTheme(),
              )),
              const SizedBox(height: 10,),
              Text("Others",style: GoogleFonts.poppins(fontSize: 12,
                  fontWeight: FontWeight.w600,color: isDark ? Colors.white70 : const Color(0XFF70756B)),
              ),
              const SizedBox(height: 9,),
              MenuItemWidget(imagePath:  AppAssets.privacy, title: "Privacy Policy",
                  onTap:()=> print("policy")
              ),
              const SizedBox(height: 9,),
              MenuItemWidget(imagePath:  AppAssets.support, title: "Customer Support",
                  onTap:()=> print("support")
              ),
              const SizedBox(height: 9,),
              MenuItemWidget(imagePath:  AppAssets.terms, title: "Terms & Conditions",
                  onTap:()=> print("terms")
              ),
              const SizedBox(height: 10,),
              Text("Danger Actions",style: GoogleFonts.poppins(fontSize: 12,
                  fontWeight: FontWeight.w600,color: isDark ? Colors.white70 : const Color(0XFF70756B)),
              ),
              const SizedBox(height: 9,),
              MenuItemWidget(imagePath:  AppAssets.delete, title: "Delete Account",
                onTap: () => Get.to(const Deleteaccount()),

    ),
              const SizedBox(height: 9,),
              MenuItemWidget(imagePath:  AppAssets.logouts, title: "Log out",
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: theme.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// TITLE
                                Text(
                                  "Are you sure?",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textTheme.titleLarge?.color,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                /// SUBTITLE
                                Text(
                                  "Are you sure, you want to log out from this account?",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                /// BUTTONS
                                Row(
                                  children: [

                                    /// CANCEL
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 45,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: theme.textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    /// LOGOUT
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          await ApiService.logout();
                                          Get.offAll(() => const GetStartedScreen());
                                        },

                                        child: Container(
                                          height: 45,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFE4572E),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            "Log out",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
