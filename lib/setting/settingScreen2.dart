import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/Auth/customerstartingscreen.dart';
import 'package:kaf8/Service/api_service.dart';
import 'package:kaf8/setting/BankAccountScreen.dart';
import 'package:kaf8/setting/LanguageScreen.dart';
import 'package:kaf8/setting/NotificationSettingScreen.dart';

import '../Controller/user_profile_controller.dart';
import '../Controller/theme_controller.dart';
import '../Help/favoritelist.dart';
import '../Help/helpchat.dart';
import '../Help/notification.dart';
import '../Utils/avatar_widget.dart';
import '../Utils/responsiveUtils.dart';
import '../home/menuItemScreen.dart';
import '../profile/myProfile.dart';
import '../address/addressScreen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<UserProfileController>();
    final themeCtrl = Get.find<ThemeController>();
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Top-left geometric background ──────────────────────────
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/bg_top_left.png',
              width: size.width * 0.65,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.22),
            ),
          ),

          // ── Top-right geometric background ─────────────────────────
          Positioned(
            top: 0,
            right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.38,
                fit: BoxFit.contain,
                opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.15),
              ),
            ),
          ),

          // ── Bottom-right geometric background ──────────────────────
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg_bottom_right.png',
              width: size.width * 0.60,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.30),
            ),
          ),

          // ── Bottom-left mirror ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.32,
                fit: BoxFit.contain,
                opacity: AlwaysStoppedAnimation(isDark ? 0.03 : 0.12),
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── WHITE HEADER ──────────────────────────────────
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const SizedBox(width: 44),
                      const Spacer(),
                      Text(
                        'settings_title'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 18 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      // Bell with dot
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => NotificationPage()),
                            child: Icon(Icons.notifications_none,
                                size: 26, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Small header avatar
                      Obx(() => GestureDetector(
                        onTap: () => Get.to(() => const MyProfileScreen()),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.green.shade600,
                          backgroundImage: profileCtrl.avatarUrl != null
                              ? NetworkImage(profileCtrl.avatarUrl!)
                              : null,
                          child: profileCtrl.avatarUrl == null
                              ? Text(
                                  _initials(profileCtrl.displayName),
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                )
                              : null,
                        ),
                      )),
                    ],
                  ),
                ),

                // ── Scrollable body ───────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Avatar area ──
                        Obx(() {
                          final name = profileCtrl.displayName;
                          return SizedBox(
                            height: name.isNotEmpty ? 160 : 140,
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // White ring
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.cardColor,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: GestureDetector(
                                      onTap: () => Get.to(() => const MyProfileScreen()),
                                      child: AvatarWidget(
                                        avatarUrl: profileCtrl.avatarUrl,
                                        name: name,
                                        radius: 46,
                                      ),
                                    ),
                                  ),
                                  // Green edit button
                                  Positioned(
                                    bottom: 0,
                                    right: -2,
                                    child: GestureDetector(
                                      onTap: () => Get.to(() => const MyProfileScreen()),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.edit,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        Obx(() {
                          final name = profileCtrl.displayName;
                          if (name.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Center(
                              child: Text(
                                name,
                                style: GoogleFonts.inter(
                                    fontSize: 16 * fontScale,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodyLarge?.color),
                              ),
                            ),
                          );
                        }),

                        // ── GENERAL section ────────────────────────────
                        _sectionTitle('general'.tr, fontScale, theme),
                        _menuCard(theme, [
                          _menuItem(Icons.person_outline,       'my_profile'.tr,   fontScale, theme, () => Get.to(() => MyProfileScreen())),
                          _menuItem(Icons.location_on_outlined, 'my_address'.tr,   fontScale, theme, () => Get.to(() => AddressScreens())),
                          _menuItem(Icons.language,             'language'.tr,     fontScale, theme, () => Get.to(() => LanguageScreen())),
                          // Dark Mode Toggle
                          Obx(() => MenuSwitchWidget(
                            icon: themeCtrl.themeMode.value == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode_outlined,
                            title: 'dark_mode'.tr,
                            value: themeCtrl.themeMode.value == ThemeMode.dark,
                            onChanged: (val) => themeCtrl.toggleTheme(),
                          )),
                        ]),

                        const SizedBox(height: 20),

                        // ── OTHER ACTIVITY section ──
                        _sectionTitle('other_activity'.tr, fontScale, theme),
                        _menuCard(theme, [
                          _menuItem(Icons.account_balance_wallet_outlined, 'bank_account'.tr,   fontScale, theme, () => Get.to(() => BankAccountScreen())),
                          _menuItem(Icons.notifications_outlined,          'notification'.tr,   fontScale, theme, () => Get.to(() => NotificationSettingScreen())),
                          _menuItem(Icons.favorite_border,                 'favourite_list'.tr, fontScale, theme, () => Get.to(() => FavoriteList())),
                        ]),

                        const SizedBox(height: 20),

                        // ── HELP AND SUPPORT section ───────────────────
                        _sectionTitle('help_support'.tr, fontScale, theme),
                        _menuCard(theme, [
                          _menuItem(Icons.headset_mic_outlined,  'live_chat'.tr,       fontScale, theme, () => Get.to(() => const HelpChatScreen())),
                          _menuItem(Icons.chat_bubble_outline,   'about_us'.tr,         fontScale, theme, () => Get.to(() => _StaticInfoScreen(title: 'about_us'.tr,         content: _kAboutUs))),
                          _menuItem(Icons.description_outlined,  'terms_policies'.tr,  fontScale, theme, () => Get.to(() => _StaticInfoScreen(title: 'terms_policies'.tr,  content: _kTerms))),
                          _menuItem(Icons.help_outline,          'privacy_policy'.tr,  fontScale, theme, () => Get.to(() => _StaticInfoScreen(title: 'privacy_policy'.tr,  content: _kPrivacy))),
                        ]),

                        const SizedBox(height: 20),

                        // ── ACCOUNT section ────────────────────────────
                        _sectionTitle('account'.tr, fontScale, theme),
                        _menuCard(theme, [
                          _menuItem(Icons.logout, 'log_out'.tr, fontScale, theme, () => _showLogoutDialog(context, profileCtrl), isLogout: true),
                        ]),

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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _showLogoutDialog(BuildContext context, UserProfileController profileCtrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'logout_title'.tr,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'logout_confirm'.tr,
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'cancel'.tr,
                style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                profileCtrl.clearProfile();
                await ApiService.logout();
                Get.offAll(() => const GetStartedScreen());
              },
              child: Text(
                'logout'.tr,
                style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Section title ───────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, double fontScale, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15 * fontScale,
          fontWeight: FontWeight.w700,
          color: theme.textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  // ── White card wrapping a list of menu items ────────────────────────────────
  Widget _menuCard(ThemeData theme, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  // ── Single menu row ─────────────────────────────────────────────────────────
  Widget _menuItem(
      IconData icon,
      String title,
      double fontScale,
      ThemeData theme,
      VoidCallback onTap, {
        bool isLogout = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Green circle outline icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15 * fontScale,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Static content strings ──────────────────────────────────────────────────

const _kAboutUs = '''
KAF8 is a European logistics marketplace that connects people who need to send parcels with trusted independent transporters.

Founded to make last-mile delivery faster, simpler, and more transparent, KAF8 lets you place an order in seconds, track your parcel live on the map, and pay securely — all from your phone.

Our network of verified transporters covers France and is expanding across Europe. Whether you need to ship a document, a piece of furniture, or a pallet, KAF8 has a vehicle for every job.

Contact us: support@kaf8.fr
''';

const _kTerms = '''
Terms & Policies — KAF8

1. Service
KAF8 provides a platform connecting customers with independent transporters. KAF8 is not itself a carrier.

2. User Responsibilities
Users must provide accurate pickup and delivery addresses. Prohibited items (flammable, illegal, or hazardous goods) may not be shipped.

3. Cancellations
Orders may be cancelled before a transporter is assigned. Once accepted, cancellation fees may apply.

4. Payments
All payments are processed securely via Stripe. KAF8 does not store full card details.

5. Liability
KAF8's liability is limited to the declared value of the parcel, up to the maximum stated in your order.

6. Changes to Terms
KAF8 reserves the right to update these terms at any time. Continued use of the app constitutes acceptance of the updated terms.
''';

const _kPrivacy = '''
Privacy Policy — KAF8

1. Data We Collect
We collect your name, email, phone number, and delivery addresses to operate the service. Location data is collected during active deliveries only.

2. How We Use Your Data
Your data is used to match orders with transporters, process payments, and improve the service. We do not sell personal data to third parties.

3. Data Storage
Data is stored on secure servers within the European Union and is protected in accordance with GDPR.

4. Your Rights
You have the right to access, correct, or delete your personal data at any time. Contact support@kaf8.fr to exercise these rights.

5. Cookies
Our app does not use browser cookies. We use local storage solely for session management.

6. Contact
For privacy-related requests: privacy@kaf8.fr
''';

// ── Simple static info screen ───────────────────────────────────────────────

class _StaticInfoScreen extends StatelessWidget {
  final String title;
  final String content;
  const _StaticInfoScreen({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.60, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.18))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.50, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.22))),
          SafeArea(
            child: Column(
              children: [
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? Colors.white24 : Colors.grey[800]!, width: 1.8)),
                          child: Icon(Icons.arrow_back_ios_new,
                              size: 15, color: theme.iconTheme.color),
                        ),
                      ),
                      const Spacer(),
                      Text(title,
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
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))]),
                      child: Text(
                        content.trim(),
                        style: GoogleFonts.inter(
                            fontSize: 14 * fontScale,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                            height: 1.7),
                      ),
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
}
