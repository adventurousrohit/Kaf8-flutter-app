import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';
import '../Utils/responsiveUtils.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});
  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState
    extends State<NotificationSettingScreen> {

  bool _loading = true;
  bool _saving  = false;

  bool _receiveAll = false;
  bool _prompts    = true;
  bool _calls      = true;
  bool _orders     = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final res = await ApiService.getNotificationSettings();
    if (!mounted) return;
    if (res['success'] == true && res['data'] is Map) {
      final d = res['data'] as Map;
      setState(() {
        _prompts    = d['prompts'] == true;
        _calls      = d['calls']   == true;
        _orders     = d['orders']  == true;
        _receiveAll = _prompts && _calls && _orders;
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final res = await ApiService.updateNotificationSettings({
      'receiveAll': _receiveAll,
      'prompts':    _prompts,
      'calls':      _calls,
      'orders':     _orders,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (res['success'] == true) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message']?.toString() ?? "Failed to save"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _onReceiveAllChanged(bool val) {
    setState(() {
      _receiveAll = val;
      _prompts = val;
      _calls   = val;
      _orders  = val;
    });
  }

  void _updateReceiveAll() {
    setState(() => _receiveAll = _prompts && _calls && _orders);
  }

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
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _circleBack(context, theme),
                      const Spacer(),
                      Text("Notification settings",
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
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _notifRow(
                                label: "Receive all notifications",
                                value: _receiveAll,
                                fontScale: fontScale,
                                theme: theme,
                                onChanged: _onReceiveAllChanged,
                              ),
                              const SizedBox(height: 20),
                              _notifRow(
                                label: "Prompts",
                                value: _prompts,
                                fontScale: fontScale,
                                theme: theme,
                                onChanged: (v) { _prompts = v; _updateReceiveAll(); },
                              ),
                              const SizedBox(height: 20),
                              _notifRow(
                                label: "Calls",
                                value: _calls,
                                fontScale: fontScale,
                                theme: theme,
                                onChanged: (v) { _calls = v; _updateReceiveAll(); },
                              ),
                              const SizedBox(height: 20),
                              _notifRow(
                                label: "Orders",
                                value: _orders,
                                fontScale: fontScale,
                                theme: theme,
                                onChanged: (v) { _orders = v; _updateReceiveAll(); },
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30))),
                                  onPressed: _saving ? null : _save,
                                  child: Text(_saving ? "Saving..." : "Confirm",
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

  Widget _notifRow({
    required String label,
    required bool value,
    required double fontScale,
    required ThemeData theme,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: GoogleFonts.inter(
            fontSize: 14 * fontScale,
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87),
            fontWeight: FontWeight.w400)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.green,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: theme.brightness == Brightness.dark ? Colors.white24 : Colors.grey[300],
        ),
      ],
    );
  }
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
