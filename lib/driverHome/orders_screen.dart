import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Controller/order_controller.dart';
import '../Controller/user_profile_controller.dart';
import '../Utils/avatar_widget.dart';
import 'map_screen.dart';
import 'notification_screen.dart';
import 'order_details_screen.dart';

class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
  int _tabIndex = 0; // 0=New, 1=Active, 2=History

  final OrderController _orderController = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    _loadTab(0);
  }

  void _loadTab(int index) {
    if (index == 0) {
      _orderController.fetchPendingAvailable();
    } else if (index == 1) {
      _orderController.fetchActive();
    } else {
      _orderController.fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabs(),
            const SizedBox(height: 12),
            Expanded(child: Obx(() {
              final bool isLoading = _tabIndex == 0
                  ? _orderController.isLoadingAvailable.value
                  : _tabIndex == 1
                      ? _orderController.isLoadingActive.value
                      : _orderController.isLoadingHistory.value;

              final List<Map<String, dynamic>> orders = _tabIndex == 0
                  ? _orderController.availableOrders
                  : _tabIndex == 1
                      ? _orderController.activeOrders
                      : _orderController.historyOrders;

              if (isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.green));
              }

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('No orders',
                          style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text(_tabIndex == 0
                          ? 'No available orders right now'
                          : _tabIndex == 1
                              ? 'No active orders'
                              : 'No completed orders yet',
                          style: GoogleFonts.inter(
                              color: Colors.grey[400], fontSize: 13)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.green,
                onRefresh: () async => _loadTab(_tabIndex),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => _DriverOrderCard(
                    order: orders[index],
                    tabIndex: _tabIndex,
                    onOpenMap: () => _openMap(orders[index]),
                    onViewDetails: () => _openDetails(orders[index]),
                    onAccept: _tabIndex == 0
                        ? () => _acceptOrder(orders[index])
                        : null,
                    onComplete: _tabIndex == 1
                        ? () => _completeOrder(orders[index])
                        : null,
                  ),
                ),
              );
            })),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptOrder(Map<String, dynamic> order) async {
    final orderId = order['id'] as String?;
    if (orderId == null) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Accept Order'),
        content: const Text('Do you want to accept this delivery?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Get.back(result: true),
              child: const Text('Accept',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _orderController.acceptOrder(orderId);
    if (result['success'] == true) {
      Get.snackbar('Order Accepted', 'You have accepted this delivery',
          backgroundColor: Colors.green, colorText: Colors.white);
      _loadTab(1); // Switch feeling to active
      setState(() => _tabIndex = 1);
    } else {
      Get.snackbar('Error', result['message'] ?? 'Failed to accept order',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _completeOrder(Map<String, dynamic> order) async {
    final orderId = order['id'] as String?;
    if (orderId == null) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Mark as Delivered'),
        content: const Text('Confirm that this order has been delivered?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Get.back(result: true),
              child: const Text('Confirm',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm != true) return;

    final result =
        await _orderController.updateOrderStatus(orderId, 'delivered');
    if (result['success'] == true) {
      Get.snackbar('Delivered!', 'Order marked as delivered',
          backgroundColor: Colors.green, colorText: Colors.white);
      _loadTab(1);
    } else {
      Get.snackbar('Error', result['message'] ?? 'Failed to update status',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _openMap(Map<String, dynamic> order) {
    Get.to(() => MapScreen(order: order));
  }

  void _openDetails(Map<String, dynamic> order) {
    Get.to(() => OrderDetailsScreen(order: order));
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          Text('Orders',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.to(() => const DriverNotificationScreen()),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none,
                    size: 26, color: Colors.black87),
                Positioned(
                  right: 0, top: 0,
                  child: Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildTabs() {
    const tabs = ['New', 'Active', 'History'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: List.generate(3, (i) {
          final active = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _tabIndex = i);
                _loadTab(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: active ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(tabs[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : Colors.grey[500])),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DriverOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final int tabIndex;
  final VoidCallback? onOpenMap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onAccept;
  final VoidCallback? onComplete;

  const _DriverOrderCard({
    required this.order,
    required this.tabIndex,
    this.onOpenMap,
    this.onViewDetails,
    this.onAccept,
    this.onComplete,
  });

  List get _packages =>
      (order['Packages'] ?? order['packages'] ?? []) as List;

  String get _parcelType =>
      _packages.isNotEmpty
          ? (_packages.first['parcelType'] as String? ?? 'Goods')
          : 'Goods';

  String get _shortId =>
      (() {
        final raw = order['id']?.toString() ?? '';
        if (raw.isEmpty) return '#N/A';
        final safe = raw.length >= 8 ? raw.substring(0, 8) : raw;
        return '#${safe.toUpperCase()}';
      })();

  double get _cost =>
      double.tryParse(order['deliveryCost']?.toString() ?? '0') ?? 0;

  String get _statusStr => order['statusOrder'] as String? ?? 'pending';

  Color get _statusColor {
    switch (_statusStr) {
      case 'active': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'canceled': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                    child: Text('📦', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_parcelType,
                            style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                              OrderController.statusLabel(_statusStr),
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: _statusColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('Order $_shortId',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Text('🚚', style: TextStyle(fontSize: 14)),
                        const Spacer(),
                        Text('€${_cost.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // From / To
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.my_location, size: 12, color: Colors.green),
                  Container(
                      height: 16, width: 1, color: Colors.grey.shade300),
                  const Icon(Icons.location_on, size: 12, color: Colors.red),
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
                            fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text(order['receiverAddress'] as String? ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.map_outlined,
                      size: 16, color: Colors.black87),
                  label: Text('Open Map',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (onAccept != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text('Accept',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              if (onComplete != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text('Delivered',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              if (onAccept == null && onComplete == null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text('Completed',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ),
    ));
  }
}
