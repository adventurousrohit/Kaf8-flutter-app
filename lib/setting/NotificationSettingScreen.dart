import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsiveUtils.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});
  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState
    extends State<NotificationSettingScreen> {

  bool _receiveAll = false;
  bool _prompts    = true;
  bool _calls      = true;
  bool _orders     = true;

  // When "receive all" is toggled, sync all others
  void _onReceiveAllChanged(bool val) {
    setState(() {
      _receiveAll = val;
      _prompts = val;
      _calls   = val;
      _orders  = val;
    });
  }

  // When any sub-toggle changes, update "receive all" state
  void _updateReceiveAll() {
    setState(() {
      _receiveAll = _prompts && _calls && _orders;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // Background shapes
          Positioned(top: 0, left: 0,
            child: Image.asset('assets/images/bg_top_left.png',
              width: size.width * 0.60, fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.18))),
          Positioned(top: 0, right: 0,
            child: Transform(alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset('assets/images/bg_bottom_right.png',
                width: size.width * 0.36, fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.12)))),
          Positioned(bottom: 0, right: 0,
            child: Image.asset('assets/images/bg_bottom_right.png',
              width: size.width * 0.50, fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.22))),

          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _circleBack(context),
                      const Spacer(),
                      Text("Notification setting",
                        style: GoogleFonts.inter(
                          fontSize: 17 * fontScale,
                          fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.8),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // ── Toggle rows ──────────────────────────────
                        _notifRow(
                          label: "Receive all notifications",
                          value: _receiveAll,
                          fontScale: fontScale,
                          onChanged: _onReceiveAllChanged,
                        ),
                        const SizedBox(height: 20),

                        _notifRow(
                          label: "Prompts",
                          value: _prompts,
                          fontScale: fontScale,
                          onChanged: (v) {
                            _prompts = v;
                            _updateReceiveAll();
                          },
                        ),
                        const SizedBox(height: 20),

                        _notifRow(
                          label: "Calls",
                          value: _calls,
                          fontScale: fontScale,
                          onChanged: (v) {
                            _calls = v;
                            _updateReceiveAll();
                          },
                        ),
                        const SizedBox(height: 20),

                        _notifRow(
                          label: "Orders",
                          value: _orders,
                          fontScale: fontScale,
                          onChanged: (v) {
                            _orders = v;
                            _updateReceiveAll();
                          },
                        ),

                        const Spacer(),

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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Notification settings saved!"),
                                  backgroundColor: Colors.green));
                              Navigator.pop(context);
                            },
                            child: Text("Confirm",
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
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: GoogleFonts.inter(
            fontSize: 14 * fontScale,
            color: Colors.black87,
            fontWeight: FontWeight.w400)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.green,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey[300],
        ),
      ],
    );
  }
}

Widget _circleBack(BuildContext context) {
  return GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[800]!, width: 1.8)),
      child: const Icon(Icons.arrow_back_ios_new, size: 15, color: Colors.black),
    ),
  );
}
