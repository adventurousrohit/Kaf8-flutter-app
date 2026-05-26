import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

const List<_NotifItem> _notifications = [
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

class DriverNotificationScreen extends StatelessWidget {
  const DriverNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _notifications.length,
                itemBuilder: (context, index) =>
                    _NotifCard(item: _notifications[index]),
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
          Text('Notifications',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          const Icon(Icons.email_outlined, size: 22, color: Colors.black87),
          const SizedBox(width: 12),
          Stack(
            children: [
              const Icon(Icons.notifications_none,
                  size: 26, color: Colors.black87),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 17,
            backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/32.jpg'),
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  const _NotifCard({required this.item});

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
        color: Colors.white,
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
                            fontSize: 14, fontWeight: FontWeight.w700)),
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
                        color: Colors.grey[500],
                        height: 1.4)),
                const SizedBox(height: 4),
                Text(item.time,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
