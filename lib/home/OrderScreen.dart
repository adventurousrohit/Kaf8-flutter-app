import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Controller/order_controller.dart';
import '../Controller/user_profile_controller.dart';
import '../Utils/avatar_widget.dart';
import '../Utils/responsiveUtils.dart';
import '../Help/notification.dart';
import '../profile/myProfile.dart';
import 'orderDetails.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  final OrderController _ctrl = Get.find<OrderController>();
  final UserProfileController _profileCtrl = Get.find<UserProfileController>();

  @override
  void initState() {
    super.initState();
    debugPrint("📱 OrderScreen: initState called");
    _tabController = TabController(length: 3, vsync: this);

    // Update the pill indicator whenever the tab changes (tap OR swipe)
    _tabController.addListener(() {
      final newIndex = _tabController.index;
      if (_selectedTab != newIndex) {
        setState(() => _selectedTab = newIndex);
        _loadTab(newIndex);
      }
    });

    _loadTab(0);
  }

  void _loadTab(int index) {
    debugPrint("📱 OrderScreen: _loadTab($index)");
    if (index == 0) _ctrl.fetchPending();
    if (index == 1) _ctrl.fetchActive();
    if (index == 2) _ctrl.fetchHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          Positioned(
            top: 0, left: 0,
            child: Image.asset('assets/images/bg_top_left.png',
                width: size.width * 0.60, fit: BoxFit.contain,
                opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.18)),
          ),
          Positioned(
            top: 0, right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.38, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.15)),
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Image.asset('assets/images/bg_bottom_right.png',
                width: size.width * 0.60, fit: BoxFit.contain,
                opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.35)),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const SizedBox(width: 44),
                      const Spacer(),
                      Text("My Orders",
                          style: GoogleFonts.inter(
                              fontSize: 18 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleLarge?.color)),
                      const Spacer(),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => NotificationPage()),
                            child: Icon(Icons.notifications_none,
                                size: 26, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Obx(() => GestureDetector(
                        onTap: () => Get.to(() => const MyProfileScreen()),
                        child: AvatarWidget(
                          avatarUrl: _profileCtrl.avatarUrl,
                          name: _profileCtrl.displayName,
                          radius: 18,
                        ),
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Pill tab bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        _tabPill("New",     0, fontScale, theme),
                        _tabPill("Active",  1, fontScale, theme),
                        _tabPill("History", 2, fontScale, theme),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OrderList(
                        ordersRx: _ctrl.pendingOrders,
                        isLoadingRx: _ctrl.isLoadingPending,
                        onRefresh: _ctrl.fetchPending,
                        emptyLabel: "No pending orders",
                        fontScale: fontScale,
                        theme: theme,
                      ),
                      _OrderList(
                        ordersRx: _ctrl.activeOrders,
                        isLoadingRx: _ctrl.isLoadingActive,
                        onRefresh: _ctrl.fetchActive,
                        emptyLabel: "No active orders",
                        fontScale: fontScale,
                        theme: theme,
                      ),
                      _OrderList(
                        ordersRx: _ctrl.historyOrders,
                        isLoadingRx: _ctrl.isLoadingHistory,
                        onRefresh: _ctrl.fetchHistory,
                        emptyLabel: "No completed orders yet",
                        fontScale: fontScale,
                        theme: theme,
                      ),
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

  Widget _tabPill(String label, int index, double fontScale, ThemeData theme) {
    final bool active = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() => _selectedTab = index);
          _loadTab(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
        ),
      ),
    );
  }
}

// ─── Per-tab list widget ──────────────────────────────────────────────────────

class _OrderList extends StatelessWidget {
  final RxList<Map<String, dynamic>> ordersRx;
  final RxBool isLoadingRx;
  final Future<void> Function() onRefresh;
  final String emptyLabel;
  final double fontScale;
  final ThemeData theme;

  const _OrderList({
    required this.ordersRx,
    required this.isLoadingRx,
    required this.onRefresh,
    required this.emptyLabel,
    required this.fontScale,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoadingRx.value) {
        return const Center(
            child: CircularProgressIndicator(color: Colors.green));
      }

      final orders = ordersRx;

      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(emptyLabel,
                  style: GoogleFonts.inter(
                      fontSize: 16 * fontScale,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text("Pull down to refresh",
                  style: GoogleFonts.inter(
                      fontSize: 13 * fontScale, color: Colors.grey[400])),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: Colors.green,
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: orders.length,
          itemBuilder: (_, i) =>
              _OrderCard(order: orders[i], fontScale: fontScale, theme: theme),
        ),
      );
    });
  }
}

// ─── Order card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final double fontScale;
  final ThemeData theme;
  const _OrderCard({required this.order, required this.fontScale, required this.theme});

  String get _shortId =>
      (() {
        final raw = order['id']?.toString() ?? '';
        if (raw.isEmpty) return '#N/A';
        final safe = raw.length >= 8 ? raw.substring(0, 8) : raw;
        return '#${safe.toUpperCase()}';
      })();

  String get _statusStr => order['statusOrder'] as String? ?? 'pending';

  Color get _statusColor {
    switch (_statusStr) {
      case 'active':    return Colors.blue;
      case 'delivered': return Colors.green;
      case 'canceled':  return Colors.red;
      default:          return Colors.orange;
    }
  }

  List get _packages =>
      (order['Packages'] ?? order['packages'] ?? []) as List;

  String get _parcelType =>
      _packages.isNotEmpty
          ? (_packages.first['parcelType'] as String? ?? 'Goods')
          : 'Goods';

  double get _cost =>
      double.tryParse(order['deliveryCost']?.toString() ?? '0') ?? 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => OrderDetailsScreen(order: order)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                      color: const Color(0xFFB2EBE8).withOpacity(theme.brightness == Brightness.dark ? 0.2 : 1.0),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Text('📦', style: TextStyle(fontSize: 32))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_parcelType,
                          style: GoogleFonts.inter(
                              fontSize: 16 * fontScale,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 2),
                      Text(_shortId,
                          style: GoogleFonts.inter(
                              fontSize: 12 * fontScale,
                              color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 11, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            OrderController.formatDate(
                                order['dateOrder'] as String?),
                            style: GoogleFonts.inter(
                                fontSize: 11 * fontScale,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                          OrderController.statusLabel(_statusStr),
                          style: GoogleFonts.inter(
                              fontSize: 11 * fontScale,
                              color: _statusColor,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    Text("€${_cost.toStringAsFixed(2)}",
                        style: GoogleFonts.inter(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.bodyLarge?.color)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.storefront, size: 13, color: Colors.green),
                    _dashedLine(),
                    const Icon(Icons.location_on, size: 13, color: Colors.green),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['departureAddress'] as String? ?? 'N/A',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 12 * fontScale, color: Colors.grey)),
                      const SizedBox(height: 14),
                      Text(order['receiverAddress'] as String? ?? 'N/A',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 12 * fontScale, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

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
                onPressed: () =>
                    Get.to(() => OrderDetailsScreen(order: order)),
                child: Text("View Details",
                    style: GoogleFonts.inter(
                        fontSize: 13 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashedLine() {
    return SizedBox(
      height: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4,
            (_) => Container(width: 1.5, height: 3, color: Colors.grey[400])),
      ),
    );
  }
}
