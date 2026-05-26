import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEAF4FB), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Caller avatar ──────────────────────────────────
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.green.withOpacity(0.4), width: 4),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.green.withOpacity(0.15),
                                blurRadius: 30,
                                spreadRadius: 10)
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(
                              'https://randomuser.me/api/portraits/men/33.jpg'),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Name ──────────────────────────────────────────
                      Text(
                        'Rao Zulqurnain',
                        style: GoogleFonts.inter(
                            fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),

                      // ── Duration ─────────────────────────────────────
                      Text(
                        '02:25',
                        style: GoogleFonts.inter(
                            fontSize: 16, color: Colors.grey[500]),
                      ),

                      const SizedBox(height: 60),

                      // ── Action buttons ────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _callBtn(
                              icon: Icons.volume_up_outlined,
                              color: Colors.grey[200]!,
                              iconColor: Colors.black87,
                              onTap: () {}),
                          const SizedBox(width: 24),
                          _callBtn(
                              icon: Icons.mic_none_outlined,
                              color: Colors.grey[200]!,
                              iconColor: Colors.black87,
                              onTap: () {}),
                          const SizedBox(width: 24),
                          _callBtn(
                              icon: Icons.call_end,
                              color: Colors.red,
                              iconColor: Colors.white,
                              onTap: () => Navigator.of(context).pop(),
                              size: 60),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 10),
          Text('Call',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _callBtn({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    double size = 52,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: size * 0.42),
      ),
    );
  }
}
