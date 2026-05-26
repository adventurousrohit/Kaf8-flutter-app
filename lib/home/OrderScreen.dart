import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ServiceHome/Statistics.dart';
import '../ServiceHome/map.dart';
import '../Utils/appColor.dart';
import '../Utils/responsiveUtils.dart';
import '../Help/notification.dart';
import '../profile/myProfile.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // ── Top-left geometric background ────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/bg_top_left.png',
              width: size.width * 0.60,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              opacity: const AlwaysStoppedAnimation(0.18),
            ),
          ),

          // ── Top-right geometric background ───────────────────────────
          Positioned(
            top: 0,
            right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.38,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.15),
              ),
            ),
          ),

          // ── Bottom-right geometric background ────────────────────────
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg_bottom_right.png',
              width: size.width * 0.60,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              opacity: const AlwaysStoppedAnimation(0.35),
            ),
          ),

          // ── Bottom-left mirror ───────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.35,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.15),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── WHITE HEADER ──────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Placeholder spacer to balance
                      const SizedBox(width: 44),
                      const Spacer(),
                      Text(
                        "Orders",
                        style: GoogleFonts.inter(
                          fontSize: 18 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      // Bell with dot
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => NotificationPage()),
                            child: const Icon(Icons.notifications_none,
                                size: 26, color: Colors.black87),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Avatar
                      GestureDetector(
                        onTap: () => Get.to(() => const MyProfileScreen()),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                              "https://randomuser.me/api/portraits/men/32.jpg"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── PILL TAB BAR ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _tabPill("New",     0, fontScale),
                        _tabPill("Active",  1, fontScale),
                        _tabPill("History", 2, fontScale),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── TAB CONTENT ───────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(),
                      _buildOrderList(),
                      _buildOrderList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Pill tab item ──────────────────────────────────────────────────────────
  Widget _tabPill(String label, int index, double fontScale) {
    final bool active = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() => _selectedTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14 * fontScale,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  // ── Order list ─────────────────────────────────────────────────────────────
  Widget _buildOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: 3,
      itemBuilder: (_, i) => const _OrderCard(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard();

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goods image (teal rounded bg)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFB2EBE8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('📦', style: TextStyle(fontSize: 32)),
                ),
              ),

              const SizedBox(width: 12),

              // Left text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Goods",
                        style: GoogleFonts.inter(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    const SizedBox(height: 2),
                    Text("x 1",
                        style: GoogleFonts.inter(
                            fontSize: 13 * fontScale,
                            color: Colors.black87)),
                    Text("Order ID #81",
                        style: GoogleFonts.inter(
                            fontSize: 13 * fontScale,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 11, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text("Date: 2024-03-22 / 00:20:13",
                              style: GoogleFonts.inter(
                                  fontSize: 11 * fontScale,
                                  color: Colors.grey)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right info block
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Ready",
                      style: GoogleFonts.inter(
                          fontSize: 11 * fontScale,
                          color: Colors.grey)),
                  Text("\$50.00",
                      style: GoogleFonts.inter(
                          fontSize: 20 * fontScale,
                          fontWeight: FontWeight.w800,
                          color: Colors.black)),
                  Row(
                    children: [
                      Text("Vehicle: ",
                          style: GoogleFonts.inter(
                              fontSize: 11 * fontScale,
                              color: Colors.grey)),
                      const Text("🚚",
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Size: ",
                          style: GoogleFonts.inter(
                              fontSize: 11 * fontScale,
                              color: Colors.grey)),
                      Text("small",
                          style: GoogleFonts.inter(
                              fontSize: 11 * fontScale,
                              color: Colors.black87)),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Driver fee: ",
                          style: GoogleFonts.inter(
                              fontSize: 11 * fontScale,
                              color: Colors.grey)),
                      Text("5F",
                          style: GoogleFonts.inter(
                              fontSize: 11 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Distance row ───────────────────────────────────────────
          Row(
            children: [
              Text("Distance: ",
                  style: GoogleFonts.inter(
                      fontSize: 12 * fontScale, color: Colors.grey)),
              Text("6.651 km",
                  style: GoogleFonts.inter(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.green)),
            ],
          ),

          const SizedBox(height: 10),

          // ── Route + Open Map row ───────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashed route line with icons
              Column(
                children: [
                  const Icon(Icons.storefront,
                      size: 14, color: Colors.green),
                  _dashedLine(),
                  const Icon(Icons.location_on,
                      size: 14, color: Colors.green),
                ],
              ),
              const SizedBox(width: 8),
              // Addresses
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Lorem ipsum shop",
                        style: GoogleFonts.inter(
                            fontSize: 12 * fontScale,
                            color: Colors.grey)),
                    const SizedBox(height: 16),
                    Text("Lorem ipsum house",
                        style: GoogleFonts.inter(
                            fontSize: 12 * fontScale,
                            color: Colors.grey)),
                  ],
                ),
              ),
              // Open Map button
              GestureDetector(
                onTap: () => Get.to(() => TrackingScreen()),
                child: Row(
                  children: [
                    Text("Open Map",
                        style: GoogleFonts.inter(
                          fontSize: 12 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        )),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_pin,
                        color: Colors.green, size: 16),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Check Status button ────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => Get.to(() => StatisticsScreen()),
              child: Text(
                "Check Status",
                style: GoogleFonts.inter(
                  fontSize: 13 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dashed vertical line
  Widget _dashedLine() {
    return SizedBox(
      height: 22,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          5,
              (_) => Container(width: 1.5, height: 3, color: Colors.grey[400]),
        ),
      ),
    );
  }
}