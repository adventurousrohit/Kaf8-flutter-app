import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallScreen extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  final String? duration;

  const CallScreen({
    super.key,
    this.name,
    this.avatarUrl,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayName = name ?? 'Rao Zulqurnain';
    final displayAvatar = avatarUrl ?? 'https://randomuser.me/api/portraits/men/33.jpg';
    final displayDuration = duration ?? '02:25';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, theme),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor]
                        : [const Color(0xFFEAF4FB), Colors.white],
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
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(displayAvatar),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Name ──────────────────────────────────────────
                      Text(
                        displayName,
                        style: GoogleFonts.inter(
                            fontSize: 24, fontWeight: FontWeight.w800, color: theme.textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 8),

                      // ── Duration ─────────────────────────────────────
                      Text(
                        displayDuration,
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
                              color: isDark ? Colors.white10 : Colors.grey[200]!,
                              iconColor: theme.iconTheme.color!,
                              onTap: () {}),
                          const SizedBox(width: 24),
                          _callBtn(
                              icon: Icons.mic_none_outlined,
                              color: isDark ? Colors.white10 : Colors.grey[200]!,
                              iconColor: theme.iconTheme.color!,
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

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back_ios_new,
                size: 20, color: theme.iconTheme.color),
          ),
          const SizedBox(width: 10),
          Text('Call',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
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
