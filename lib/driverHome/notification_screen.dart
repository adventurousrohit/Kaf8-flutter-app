import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/user_profile_controller.dart';
import '../Service/api_service.dart';
import '../Utils/avatar_widget.dart';

class _NotifItem {
  final String title;
  final String body;
  final String time;
  final String type; // 'goods' | 'vehicle' | 'delivery'
  const _NotifItem(
      {required this.title,
      required this.body,
      required this.time,
      required this.type});
}

class DriverNotificationScreen extends StatefulWidget {
  const DriverNotificationScreen({super.key});

  @override
  State<DriverNotificationScreen> createState() => _DriverNotificationScreenState();
}

class _DriverNotificationScreenState extends State<DriverNotificationScreen> {
  List<_NotifItem> _notifications = _notificationsFallback;
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
    final data = response['data'];
    _error = null;
    if (response['success'] == true && data is List && data.isNotEmpty) {
      _notifications = data.cast<Map>().map((item) {
        final map = Map<String, dynamic>.from(item);
        final type = (map['type'] ?? "system").toString();
        return _NotifItem(
          title: (map['title'] ?? "Notification").toString(),
          body: (map['message'] ?? "").toString(),
          time: (map['createdAt'] ?? "").toString(),
          type: type.contains("order") ? "goods" : "vehicle",
        );
      }).toList();
    } else if (response['success'] == true) {
      _notifications = [];
    } else {
      _notifications = [];
      _error = response['message']?.toString() ?? 'Unable to load notifications';
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, theme),
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
                                'No notifications yet',
                                style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                              ),
                            )
                  : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _notifications.length,
                itemBuilder: (context, index) =>
                    _NotifCard(item: _notifications[index], theme: theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
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
          Text('Notifications',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
          const Spacer(),
          // Icon(Icons.email_outlined, size: 22, color: theme.iconTheme.color),
          // const SizedBox(width: 12),
          // Stack(
          //   children: [
          //     Icon(Icons.notifications_none,
          //         size: 26, color: isDark ? Colors.white70 : Colors.black87),
          //     Positioned(
          //       right: 0,
          //       top: 0,
          //       child: Container(
          //         width: 7,
          //         height: 7,
          //         decoration: const BoxDecoration(
          //             color: Colors.orange, shape: BoxShape.circle),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(width: 10),
          Obx(() {
            final ctrl = Get.find<UserProfileController>();
            return AvatarWidget(
              avatarUrl: ctrl.avatarUrl,
              name: ctrl.displayName,
              radius: 17,
            );
          }),
        ],
      ),
    );
  }
}

const List<_NotifItem> _notificationsFallback = [
  _NotifItem(
      title: 'Goods',
      body: 'Lorem ipsum dolor sit amet Consectetur Adipiscing elit.',
      time: '09:41 AM',
      type: 'goods'),
  _NotifItem(
      title: 'Vehicle',
      body: 'Lorem ipsum dolor sit amet Consectetur Adipiscing elit.',
      time: '09:20 AM',
      type: 'vehicle'),
  _NotifItem(
      title: 'Goods',
      body: 'Lorem ipsum dolor sit amet Consectetur Adipiscing elit.',
      time: '08:55 AM',
      type: 'goods'),
  _NotifItem(
      title: 'Goods',
      body: 'Lorem ipsum dolor sit amet Consectetur Adipiscing elit.',
      time: '08:30 AM',
      type: 'goods'),
  _NotifItem(
      title: 'Vehicle',
      body: 'Lorem ipsum dolor sit amet Consectetur Adipiscing elit.',
      time: '07:10 AM',
      type: 'vehicle'),
  _NotifItem(
      title: 'Goods',
      body: 'Lorem ipsum dolor sit amet Consectetur Adipiscing elit.',
      time: '06:45 AM',
      type: 'goods'),
];

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  final ThemeData theme;
  const _NotifCard({required this.item, required this.theme});

  Color get _iconBg =>
      item.type == 'goods' ? Colors.green : Colors.blue.shade100;

  IconData get _icon =>
      item.type == 'goods' ? Icons.inventory_2_outlined : Icons.directions_car_outlined;

  Color get _statusColor =>
      item.type == 'vehicle' ? Colors.blue : Colors.green;

  String get _statusLabel =>
      item.type == 'vehicle' ? 'New status' : 'Accepted';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _iconBg.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _iconBg, size: 24),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.title,
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_statusLabel,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: _statusColor,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.body,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        height: 1.4)),
                const SizedBox(height: 4),
                Text(item.time,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
