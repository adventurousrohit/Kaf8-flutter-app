import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/Auth/customerstartingscreen.dart';
import 'package:kaf8/Service/api_service.dart';
import '../Controller/user_profile_controller.dart';
import '../Controller/theme_controller.dart';
import '../Utils/avatar_widget.dart';
import 'my_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<UserProfileController>();
    final themeCtrl = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFF2ECC40),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Obx(() => Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  AvatarWidget(
                    avatarUrl: profileCtrl.avatarUrl,
                    name: profileCtrl.displayName,
                    radius: 24,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileCtrl.displayName.isNotEmpty ? profileCtrl.displayName : 'Driver',
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                      Text(
                        profileCtrl.profile.value?['email']?.toString() ?? '',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ],
              ),
            )),

            // ── White card ───────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Group 1
                    _settingsGroup(theme, [
                      _SettingItem(
                        icon: Icons.person_outline,
                        label: 'My profile',
                        onTap: () => Get.to(() => const DriverProfileScreen()),
                      ),
                      _SettingItem(
                        icon: Icons.circle_outlined,
                        label: 'Online Offline',
                        trailing: Switch(
                          value: _isOnline,
                          onChanged: (v) => setState(() => _isOnline = v),
                          activeColor: Colors.green,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onTap: null,
                      ),
                      _SettingItem(
                        icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                        label: 'dark_mode'.tr,
                        trailing: Obx(() => Switch(
                          value: themeCtrl.themeMode.value == ThemeMode.dark,
                          onChanged: (v) => themeCtrl.toggleTheme(),
                          activeColor: Colors.green,
                        )),
                        onTap: null,
                      ),
                      _SettingItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notification',
                        onTap: () {
                          // Get.to(() => NotificationScreen());
                        },
                      ),
                      _SettingItem(
                        icon: Icons.bar_chart_outlined,
                        label: 'Statistics',
                        onTap: () {
                          // Get.to(() => StatisticsScreen());
                        },
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Group 2
                    _settingsGroup(theme, [
                      _SettingItem(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () {},
                      ),
                      _SettingItem(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        onTap: () {},
                      ),
                      _SettingItem(
                        icon: Icons.info_outline,
                        label: 'About us',
                        onTap: () {},
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Logout
                    _settingsGroup(theme, [
                      _SettingItem(
                        icon: Icons.logout,
                        label: 'Log out',
                        onTap: () => _showLogoutDialog(context),
                        isLast: true,
                        iconColor: Colors.red,
                        labelColor: Colors.red,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                Get.find<UserProfileController>().clearProfile();
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

  Widget _settingsGroup(ThemeData theme, List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((e) => _buildTile(theme, e.value, e.key < items.length - 1))
            .toList(),
      ),
    );
  }

  Widget _buildTile(ThemeData theme, _SettingItem item, bool showDivider) {
    return Column(
      children: [
        ListTile(
          onTap: item.onTap,
          leading: Icon(item.icon,
              color: item.iconColor ?? Colors.grey[600], size: 22),
          title: Text(item.label,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: item.labelColor ?? theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
          trailing: item.trailing ??
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        ),
        if (showDivider)
          Divider(
              height: 1,
              indent: 54,
              endIndent: 16,
              color: theme.dividerColor),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isLast;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.isLast = false,
    this.iconColor,
    this.labelColor,
  });
}
