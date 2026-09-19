import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';
import '../Utils/responsiveUtils.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<bool> _completed = [];
  final List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getNotifications();
    if (!mounted) return;
    final raw = response['data'];
    _error = null;
    if (response['success'] == true && raw is List) {
      _notifications
        ..clear()
        ..addAll(raw.cast<Map>().map((e) => Map<String, dynamic>.from(e)));
      _completed
        ..clear()
        ..addAll(_notifications.map((e) => e['read'] == true));
    } else {
      _notifications.clear();
      _completed.clear();
      _error = response['message']?.toString() ?? 'Unable to load notifications';
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background shapes ──────────────────────────────────────
          Positioned(top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.62, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.20))),
          Positioned(top: 0, right: 0,
              child: Transform(alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.36, fit: BoxFit.contain,
                      opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.13)))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.50, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.25))),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  color: theme.appBarTheme.backgroundColor,
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
                                  color: isDark ? Colors.white24 : Colors.grey[800]!, width: 1.8)),
                          child: Icon(Icons.arrow_back_ios_new,
                              size: 15, color: theme.iconTheme.color),
                        ),
                      ),
                      const Spacer(),
                      Text("Notifications",
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleLarge?.color)),
                      const Spacer(),
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Text(
                                _error!,
                                style: GoogleFonts.inter(color: Colors.red),
                              ),
                            )
                          : _notifications.isEmpty
                              ? Center(
                                  child: Text(
                                    "No notifications yet",
                                    style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                                  ),
                                )
                              : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    itemCount: _notifications.length,
                    itemBuilder: (_, i) =>
                        _buildCard(i, fontScale, theme),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index, double fontScale, ThemeData theme) {
    final notif     = _notifications[index];
    final bool done = _completed[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
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
              color: const Color(0xFFB2EBE8).withOpacity(theme.brightness == Brightness.dark ? 0.2 : 1.0),
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
                Text((notif['title'] ?? "Notification").toString(),
                    style: GoogleFonts.inter(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 3),
                Text((notif['message'] ?? "").toString(),
                    style: GoogleFonts.inter(
                        fontSize: 11 * fontScale,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text((notif['createdAt'] ?? "").toString(),
                    style: GoogleFonts.inter(
                        fontSize: 10 * fontScale,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
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
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
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
                        : theme.dividerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    done ? "Completed" : "Mark as Complete",
                    style: GoogleFonts.inter(
                        fontSize: 9 * fontScale,
                        fontWeight: FontWeight.w500,
                        color: done ? Colors.white : theme.textTheme.bodySmall?.color),
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