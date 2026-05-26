import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsiveUtils.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Track completed state per notification
  final List<bool> _completed = List.generate(8, (i) => i == 0);

  final List<Map<String, String>> _notifications = List.generate(8, (i) => {
    'title': 'Goods',
    'desc': 'Lorem Ipsum Dolor Sit Amet, Consectetur A.',
    'date': '2024-04-1${i} 24:00:00',
  });

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // ── Background shapes ──────────────────────────────────────
          Positioned(top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.62, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.20))),
          Positioned(top: 0, right: 0,
              child: Transform(alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.36, fit: BoxFit.contain,
                      opacity: const AlwaysStoppedAnimation(0.13)))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.50, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.25))),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Circle back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey[800]!, width: 1.8)),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 15, color: Colors.black),
                        ),
                      ),
                      const Spacer(),
                      Text("Notifications",
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      const Spacer(),
                      // Mail icon
                      // Icon(Icons.mail_outline,
                      //     size: 22, color: Colors.black87),
                      // const SizedBox(width: 10),
                      // // Bell with dot
                      // Stack(
                      //   children: [
                      //     const Icon(Icons.notifications_none,
                      //         size: 22, color: Colors.black87),
                      //     Positioned(
                      //       right: 0, top: 0,
                      //       child: Container(
                      //         width: 7, height: 7,
                      //         decoration: const BoxDecoration(
                      //             color: Colors.orange,
                      //             shape: BoxShape.circle),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(width: 10),
                      // Avatar
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                            "https://randomuser.me/api/portraits/men/32.jpg"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ── Notification list ────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    itemCount: _notifications.length,
                    itemBuilder: (_, i) =>
                        _buildCard(i, fontScale),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index, double fontScale) {
    final notif     = _notifications[index];
    final bool done = _completed[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Goods image box (teal bg) ─────────────────────────
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFB2EBE8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('📦', style: TextStyle(fontSize: 26)),
            ),
          ),

          const SizedBox(width: 12),

          // ── Text content ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif['title']!,
                    style: GoogleFonts.inter(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                const SizedBox(height: 3),
                Text(notif['desc']!,
                    style: GoogleFonts.inter(
                        fontSize: 11 * fontScale,
                        color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(notif['date']!,
                    style: GoogleFonts.inter(
                        fontSize: 10 * fontScale,
                        color: Colors.grey[400])),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Right: mark + button ──────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Mark all as read",
                  style: GoogleFonts.inter(
                      fontSize: 9 * fontScale,
                      color: Colors.grey[400])),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(
                        () => _completed[index] = !_completed[index]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: done
                        ? Colors.green
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    done ? "Completed" : "Mark as Complete",
                    style: GoogleFonts.inter(
                        fontSize: 9 * fontScale,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}