import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/responsiveUtils.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const List<Map<String, dynamic>> _languages = [
    {'name': 'English',   'locale': Locale('en', 'US'), 'flag': '🇬🇧'},
    {'name': 'Français',  'locale': Locale('fr', 'FR'), 'flag': '🇫🇷'},
    {'name': 'Español',   'locale': Locale('es', 'ES'), 'flag': '🇪🇸'},
    {'name': 'Português', 'locale': Locale('pt', 'PT'), 'flag': '🇵🇹'},
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('locale_code');
    if (saved == null) return;
    final idx = _languages.indexWhere((l) {
      final loc = l['locale'] as Locale;
      return '${loc.languageCode}_${loc.countryCode}' == saved;
    });
    if (idx != -1 && mounted) setState(() => _selectedIndex = idx);
  }

  Future<void> _confirm() async {
    final selected = _languages[_selectedIndex];
    final locale = selected['locale'] as Locale;
    final localeCode = '${locale.languageCode}_${locale.countryCode}';

    Get.updateLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', localeCode);

    Get.back();
    Get.snackbar(
      'language_saved'.tr,
      selected['name'] as String,
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

    // Split into current + others
    final currentLang = _languages[_selectedIndex];
    final otherLangs = _languages
        .asMap()
        .entries
        .where((e) => e.key != _selectedIndex)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.60, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.18))),
          Positioned(top: 0, right: 0,
              child: Transform(alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.36, fit: BoxFit.contain,
                      opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.12)))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.50, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.22))),

          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _circleBack(context, theme),
                      const Spacer(),
                      Text('language_title'.tr,
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleLarge?.color)),
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
                        Text('used_language'.tr,
                            style: GoogleFonts.inter(
                                fontSize: 15 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color)),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8, offset: const Offset(0, 2))],
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
                        Text('other_languages'.tr,
                            style: GoogleFonts.inter(
                                fontSize: 15 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color)),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            children: otherLangs.asMap().entries.map((entry) {
                              final listIdx = entry.key;
                              final e = entry.value;
                              return Column(
                                children: [
                                  _languageRow(
                                    lang: e.value,
                                    isSelected: false,
                                    fontScale: fontScale,
                                    onTap: () => setState(() => _selectedIndex = e.key),
                                    theme: theme,
                                  ),
                                  if (listIdx < otherLangs.length - 1)
                                    Divider(height: 1, thickness: 0.7,
                                        indent: 16, endIndent: 16, color: theme.dividerColor),
                                ],
                              );
                            }).toList(),
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
                                    borderRadius: BorderRadius.circular(30))),
                            onPressed: _confirm,
                            child: Text('confirm'.tr,
                                style: GoogleFonts.inter(
                                    fontSize: 16 * fontScale,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
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
        width: 36, height: 36,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.grey[800]!, width: 1.8)),
        child: Icon(Icons.arrow_back_ios_new, size: 15, color: theme.iconTheme.color),
      ),
    );
  }

  Widget _languageRow({
    required Map<String, dynamic> lang,
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
            Text(lang['flag'] as String,
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(lang['name'] as String,
                  style: GoogleFonts.inter(
                      fontSize: 15 * fontScale,
                      color: isSelected ? theme.textTheme.bodyLarge?.color : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontWeight: isSelected
                          ? FontWeight.w600 : FontWeight.w400)),
            ),
            isSelected
                ? Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 13, color: Colors.white))
                : Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.grey[400]!, width: 1.5))),
          ],
        ),
      ),
    );
  }
}
