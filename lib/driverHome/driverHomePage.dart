import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/Auth/customerstartingscreen.dart';
import 'package:kaf8/Service/api_service.dart';
import 'package:kaf8/driverHome/my_profile_screen.dart';
import 'package:kaf8/driverHome/orders_screen.dart';

import '../Help/help.dart';
import '../Help/notification.dart';
import '../ServiceHome/Statistics.dart';
import '../Utils/responsiveUtils.dart';
import '../home/OrderScreen.dart';
import '../profile/myProfile.dart';
import '../setting/LanguageScreen.dart';
import 'notification_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VEHICLE GRID DATA
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleItem {
  final String emoji;
  final String label;
  const _VehicleItem(this.emoji, this.label);
}

const List<_VehicleItem> _vehicleItems = [
  _VehicleItem('🚲', 'Bicycle'),
  _VehicleItem('🏍️', 'Motorcycle'),
  _VehicleItem('🛵', 'Scooter'),
  _VehicleItem('🚗', 'Car'),
  _VehicleItem('🚚', 'Van'),
  _VehicleItem('🚌', 'MiniBus'),
  _VehicleItem('🚛', 'Truck'),
  _VehicleItem('🚜', 'Breakdown\nVehicle'),
];

// ─────────────────────────────────────────────────────────────────────────────
// REVIEW MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewItem {
  final String name;
  final String avatar;
  final double rating;
  final String time;
  final String text;
  const _ReviewItem({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.time,
    required this.text,
  });
}

const List<_ReviewItem> _reviews = [
  _ReviewItem(
    name: 'Sarah T.',
    avatar: 'https://randomuser.me/api/portraits/women/44.jpg',
    rating: 5,
    time: '1 hour ago',
    text: 'I had an urgent delivery to make, and the driver assigned to me was exceptional. '
        'John was prompt, courteous, and kept me updated throughout the entire process.',
  ),
  _ReviewItem(
    name: 'Sarah T.',
    avatar: 'https://randomuser.me/api/portraits/women/44.jpg',
    rating: 5,
    time: '1 hour ago',
    text: 'His motorbike was in great condition, and the delivery was smooth and on time. '
        'Highly recommend!',
  ),
  _ReviewItem(
    name: 'Sarah T.',
    avatar: 'https://randomuser.me/api/portraits/women/44.jpg',
    rating: 4,
    time: '2 hours ago',
    text: 'Great service overall. Very professional and punctual driver.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// DRIVER HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();

  int _currentBannerIndex = 0;
  bool _showReviews = false;
  bool _isOnline = true;

  final String _currentAddress = 'Embassy of the USA';

  final int _newRequests     = 10;
  final int _activeRequests  = 10;
  final int _pendingRequests = 5;
  final int _jobsCompleted   = 230;

  final List<Map<String, String>> _banners = [
    {'title': 'Get Ready\nMove On',        'sub': 'Make it your own 🚚'},
    {'title': 'Trusted Drivers\nNearby.',  'sub': 'Reliable every time 🏍️'},
    {'title': 'Best Service\nGuaranteed.', 'sub': 'On time, every time 📦'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Open drawer ────────────────────────────────────────────────────────────
  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEAF4FB),

      // ── GREEN NAVIGATION DRAWER ─────────────────────────────────────────
      drawer: _buildDrawer(context),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 12),
                  _buildBanner(size),
                  const SizedBox(height: 10),
                  _buildPageDots(),
                  const SizedBox(height: 18),
                  _buildStatGrid(),
                  const SizedBox(height: 18),
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  _showReviews ? _buildReviewsList() : _buildVehicleGrid(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── DRAWER ─────────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Drawer(
      width: size.width * 0.85,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // ── Background polygon shapes ──────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _DrawerBgPainter()),
            ),

            // ── Content ───────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Driver profile header ────────────────────
                    Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2.5),
                          ),
                          child: const CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(
                                'https://randomuser.me/api/portraits/men/32.jpg'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Driver 01",
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(height: 2),
                            Text("driver01@gmail.com",
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.85))),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Card 1: General ──────────────────────────
                    _drawerCard([
                      _drawerItem(
                        icon: Icons.person_outline,
                        label: "My profile",
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => DriverProfileScreen());
                        },
                      ),
                      _drawerDivider(),
                      // Online / Offline with toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.green, width: 1.5)),
                              child: const Icon(
                                  Icons.local_shipping_outlined,
                                  size: 18,
                                  color: Colors.green),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text("Online Offline",
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                            ),
                            Transform.scale(
                              scale: 0.85,
                              child: Switch(
                                value: _isOnline,
                                onChanged: (v) =>
                                    setState(() => _isOnline = v),
                                activeColor: Colors.white,
                                activeTrackColor: Colors.green,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _drawerDivider(),
                      _drawerItem(
                        icon: Icons.notifications_outlined,
                        label: "Notification",
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const DriverNotificationScreen());
                        },
                      ),
                      _drawerDivider(),
                      _drawerItem(
                        icon: Icons.bar_chart_outlined,
                        label: "Statistics",
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => StatisticsScreen());
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // ── Card 2: Support ──────────────────────────
                    _drawerCard([
                      _drawerItem(
                        icon: Icons.headset_mic_outlined,
                        label: "Help & Support",
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const HelpScreen());
                        },
                      ),
                      _drawerDivider(),
                      _drawerItem(
                        icon: Icons.language_outlined,
                        label: "Language",
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const LanguageScreen());
                        },
                      ),
                      _drawerDivider(),
                      _drawerItem(
                        icon: Icons.chat_bubble_outline,
                        label: "About us",
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // ── Card 3: Log out ──────────────────────────
                    _drawerCard([
                      _drawerItem(
                        icon: Icons.logout,
                        label: "Log out",
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context);
                        },
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
            "Logout",
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Text(
            "Are you sure you want to logout from the application?",
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.logout();
                Get.offAll(() => const GetStartedScreen());
              },
              child: Text(
                "Logout",
                style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Drawer card (white rounded container) ──────────────────────────────────
  Widget _drawerCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  // ── Single drawer menu item ─────────────────────────────────────────────────
  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 1.5),
              ),
              child: Icon(icon, size: 18, color: Colors.green),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _drawerDivider() => const Divider(
      height: 1, thickness: 0.7, indent: 16, endIndent: 16);

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFEAF4FB),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          // Hamburger — opens drawer
          GestureDetector(
            onTap: _openDrawer,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6)],
              ),
              child: const Icon(Icons.menu, size: 20, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 10),

          // Location
          const Icon(Icons.location_on, color: Colors.black54, size: 18),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Your location',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[600])),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down,
                      size: 14, color: Colors.grey[600]),
                ]),
                Text(_currentAddress,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),

          // Bell
          GestureDetector(
            onTap: () => Get.to(() => const DriverNotificationScreen()),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none,
                    size: 28, color: Colors.black87),
                Positioned(
                  right: 0, top: 0,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          GestureDetector(
            onTap: () => Get.to(() => DriverProfileScreen()),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/32.jpg'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────────
  Widget _buildBanner(Size size) {
    return SizedBox(
      height: 175,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _banners.length,
        onPageChanged: (i) => setState(() => _currentBannerIndex = i),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Green left
                Positioned(
                  left: 0, top: 0, bottom: 0,
                  width: size.width * 0.52,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2ECC40), Color(0xFF27AE60)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_banners[index]['title']!,
                            style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                height: 1.2)),
                        const SizedBox(height: 8),
                        Text(_banners[index]['sub']!,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                ),
                // Right dark
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  width: size.width * 0.44,
                  child: Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Text('🧑‍🦱\n🛵',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 36, height: 1.4)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Page dots ──────────────────────────────────────────────────────────────
  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_banners.length, (i) {
        final bool active = i == _currentBannerIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
              color: active ? Colors.green : Colors.grey[350],
              borderRadius: BorderRadius.circular(4)),
        );
      }),
    );
  }

  // ── Stat grid ──────────────────────────────────────────────────────────────
  Widget _buildStatGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Orders',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard(
                '$_newRequests', 'New Requests', const Color(0xFF6C63FF))),
            const SizedBox(width: 12),
            Expanded(child: _statCard(
                '$_activeRequests', 'Active Requests', const Color(0xFF6C63FF))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard(
                '$_pendingRequests', 'Pending Requests', const Color(0xFF6C63FF))),
            const SizedBox(width: 12),
            Expanded(child: _statCard(
                '$_jobsCompleted', 'Jobs Completed', const Color(0xFF6C63FF))),
          ]),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return GestureDetector(
      onTap: () => Get.to(() => DriverOrdersScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85))),
          ],
        ),
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _tabBtn('My Vehicles', !_showReviews),
        const SizedBox(width: 12),
        _tabBtn('Reviews', _showReviews),
      ]),
    );
  }

  Widget _tabBtn(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _showReviews = label == 'Reviews'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
            color: active ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: active ? Colors.green : Colors.grey.shade300, width: 1)),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.grey[600])),
      ),
    );
  }

  // ── Vehicle grid ───────────────────────────────────────────────────────────
  Widget _buildVehicleGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _vehicleItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82),
        itemBuilder: (context, index) {
          final item = _vehicleItems[index];
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))],
                  ),
                  child: Center(
                      child: Text(item.emoji,
                          style: const TextStyle(fontSize: 28))),
                ),
              ),
              const SizedBox(height: 6),
              Text(item.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87)),
            ],
          );
        },
      ),
    );
  }

  // ── Reviews list ───────────────────────────────────────────────────────────
  Widget _buildReviewsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _reviews.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _reviewCard(r),
        )).toList(),
      ),
    );
  }

  Widget _reviewCard(_ReviewItem r) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 22,
              backgroundImage: NetworkImage(r.avatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(r.name,
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(r.time,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500])),
                ]),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) => Icon(Icons.star,
                      size: 13,
                      color: i < r.rating.toInt()
                          ? Colors.orange : Colors.grey[300])),
                ),
                const SizedBox(height: 6),
                Text(r.text,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey[600], height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRAWER BACKGROUND PAINTER
// Subtle darker-green polygon shapes on the green gradient
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.07);

    // Large polygon — top-right area
    final Path p1 = Path()
      ..moveTo(w * 0.40, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.35)
      ..lineTo(w * 0.55, h * 0.20)
      ..close();
    canvas.drawPath(p1, paint);

    // Medium polygon — bottom-left
    final Path p2 = Path()
      ..moveTo(0, h * 0.65)
      ..lineTo(w * 0.45, h * 0.80)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p2, paint);

    // Small polygon — mid-right
    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withOpacity(0.06);

    final Path p3 = Path()
      ..moveTo(w * 0.60, h * 0.10)
      ..lineTo(w, h * 0.28)
      ..lineTo(w, h * 0.10)
      ..close();
    canvas.drawPath(p3, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}