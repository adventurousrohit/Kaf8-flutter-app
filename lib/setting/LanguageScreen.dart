import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/responsiveUtils.dart';
import '../module/userProfileScreen/getx/languageController.dart';

class LanguageModel {
  final String name;
  final String flag;
  final Locale locale;
  final String code;

  const LanguageModel({
    required this.name,
    required this.flag,
    required this.locale,
    required this.code,
  });
}

const List<LanguageModel> kSupportedLanguages = [
  LanguageModel(name: 'English',   flag: '🇬🇧', locale: Locale('en', 'US'), code: 'en_US'),
  LanguageModel(name: 'Français',  flag: '🇫🇷', locale: Locale('fr', 'FR'), code: 'fr_FR'),
  LanguageModel(name: 'Español',   flag: '🇪🇸', locale: Locale('es', 'ES'), code: 'es_ES'),
  LanguageModel(name: 'Português', flag: '🇵🇹', locale: Locale('pt', 'PT'), code: 'pt_PT'),
];

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('locale_code');
    int foundIdx = -1;

    if (savedCode != null) {
      foundIdx = kSupportedLanguages.indexWhere(
        (l) => l.code == savedCode || l.locale.languageCode == savedCode,
      );
    }

    if (foundIdx == -1) {
      final currentLoc = Get.locale;
      if (currentLoc != null) {
        foundIdx = kSupportedLanguages.indexWhere(
          (l) => l.locale.languageCode == currentLoc.languageCode,
        );
      }
    }

    if (foundIdx != -1 && mounted) {
      setState(() => _selectedIndex = foundIdx);
    }
  }

  Future<void> _confirm() async {
    final selected = kSupportedLanguages[_selectedIndex];

    Get.updateLocale(selected.locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', selected.code);

    if (Get.isRegistered<LanguageController>()) {
      Get.find<LanguageController>().updateLanguage(selected.name);
    } else {
      Get.put(LanguageController(), permanent: true).updateLanguage(selected.name);
    }

    Get.back();
    Get.snackbar(
      'language_saved'.tr,
      selected.name,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentLang = kSupportedLanguages[_selectedIndex];
    final otherLangs = <MapEntry<int, LanguageModel>>[];
    for (int i = 0; i < kSupportedLanguages.length; i++) {
      if (i != _selectedIndex) {
        otherLangs.add(MapEntry(i, kSupportedLanguages[i]));
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/bg_top_left.png',
              width: size.width * 0.60,
              fit: BoxFit.contain,
              opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.18),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.36,
                fit: BoxFit.contain,
                opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg_bottom_right.png',
              width: size.width * 0.50,
              fit: BoxFit.contain,
              opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.22),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _circleBack(context, theme),
                      const Spacer(),
                      Text(
                        'language_title'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 17 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 0.8, color: theme.dividerColor),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        // ── Used language ──────────────────────────────
                        Text(
                          'used_language'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 15 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _languageRow(
                            lang: currentLang,
                            isSelected: true,
                            fontScale: fontScale,
                            onTap: null,
                            theme: theme,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Other languages ────────────────────────────
                        Text(
                          'other_languages'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 15 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: List.generate(otherLangs.length, (index) {
                              final originalIdx = otherLangs[index].key;
                              final langItem = otherLangs[index].value;
                              return Column(
                                children: [
                                  _languageRow(
                                    lang: langItem,
                                    isSelected: false,
                                    fontScale: fontScale,
                                    onTap: () => setState(
                                      () => _selectedIndex = originalIdx,
                                    ),
                                    theme: theme,
                                  ),
                                  if (index < otherLangs.length - 1)
                                    Divider(
                                      height: 1,
                                      thickness: 0.7,
                                      indent: 16,
                                      endIndent: 16,
                                      color: theme.dividerColor,
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Confirm button ─────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _confirm,
                            child: Text(
                              'confirm'.tr,
                              style: GoogleFonts.inter(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBack(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white24
                : Colors.grey[800]!,
            width: 1.8,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 15,
          color: theme.iconTheme.color,
        ),
      ),
    );
  }

  Widget _languageRow({
    required LanguageModel lang,
    required bool isSelected,
    required double fontScale,
    required VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                lang.name,
                style: GoogleFonts.inter(
                  fontSize: 15 * fontScale,
                  color: isSelected
                      ? theme.textTheme.bodyLarge?.color
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 13, color: Colors.white),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.grey[400]!,
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
