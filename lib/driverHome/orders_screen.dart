import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'map_screen.dart';
// import 'order_details_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum OrderStatus { newOrder, active, history }

class OrderModel {
  final String id;
  final String title;
  final double price;
  final String vehicleEmoji;
  final String vehicleLabel;
  final double distance;
  final String size;
  final double driverFee;
  final String statusLabel;
  final String note;
  final OrderStatus status;

  const OrderModel({
    required this.id,
    required this.title,
    required this.price,
    required this.vehicleEmoji,
    required this.vehicleLabel,
    required this.distance,
    required this.size,
    required this.driverFee,
    required this.statusLabel,
    required this.note,
    required this.status,
  });
}

const List<OrderModel> _allOrders = [
  OrderModel(
    id: '#81',
    title: 'Goods',
    price: 50,
    vehicleEmoji: '🚚',
    vehicleLabel: 'Van',
    distance: 6.651,
    size: 'small',
    driverFee: 5,
    statusLabel: 'Ready',
    note: 'Lorem ipsum shop',
    status: OrderStatus.newOrder,
  ),
  OrderModel(
    id: '#81',
    title: 'Goods',
    price: 50,
    vehicleEmoji: '🚚',
    vehicleLabel: 'Van',
    distance: 6.651,
    size: 'small',
    driverFee: 5,
    statusLabel: 'Ready',
    note: 'Lorem ipsum shop',
    status: OrderStatus.active,
  ),
  OrderModel(
    id: '#81',
    title: 'Goods',
    price: 50,
    vehicleEmoji: '🚚',
    vehicleLabel: 'Van',
    distance: 6.651,
    size: 'small',
    driverFee: 5,
    statusLabel: 'Ready',
    note: 'Lorem ipsum shop',
    status: OrderStatus.active,
  ),
  OrderModel(
    id: '#81',
    title: 'Goods',
    price: 50,
    vehicleEmoji: '🚚',
    vehicleLabel: 'Van',
    distance: 6.651,
    size: 'small',
    driverFee: 5,
    statusLabel: 'Ready',
    note: 'Lorem ipsum shop',
    status: OrderStatus.history,
  ),
  OrderModel(
    id: '#81',
    title: 'Goods',
    price: 50,
    vehicleEmoji: '🚚',
    vehicleLabel: 'Van',
    distance: 6.651,
    size: 'small',
    driverFee: 5,
    statusLabel: 'Ready',
    note: 'Lorem ipsum shop',
    status: OrderStatus.history,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// ORDERS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
  int _tabIndex = 1; // 0=New, 1=Active, 2=History

  List<OrderModel> get _filteredOrders {
    final status = [OrderStatus.newOrder, OrderStatus.active, OrderStatus.history][_tabIndex];
    return _allOrders.where((o) => o.status == status).toList();
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
            Expanded(
              child: _filteredOrders.isEmpty
                  ? Center(
                      child: Text('No orders',
                          style: GoogleFonts.inter(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) =>
                          _OrderCard(order: _filteredOrders[index], tabIndex: _tabIndex),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.menu, size: 24, color: Colors.black87),
          const SizedBox(width: 14),
          Text('Orders',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          Stack(
            children: [
              const Icon(Icons.notifications_none, size: 26, color: Colors.black87),
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
            backgroundImage:
                NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : Colors.grey[500],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final int tabIndex;

  const _OrderCard({required this.order, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Get.to(() => OrderDetailsScreen(order: order));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ──────────────────────────────────────────────────
            Row(
              children: [
                // Goods image placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('📦', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 12),

                // Order info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(order.title,
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(order.statusLabel,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text('Order ID ${order.id}',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(height: 3),
                      // Vehicle + price row
                      Row(
                        children: [
                          Text(order.vehicleEmoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(order.vehicleLabel,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey[600])),
                          const Spacer(),
                          Text('\$${order.price.toStringAsFixed(0)}.00',
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

            // ── Details row ───────────────────────────────────────────────
            Row(
              children: [
                _detailChip(Icons.straighten, 'Size: ${order.size}'),
                const SizedBox(width: 12),
                _detailChip(Icons.route,
                    'Distance: ${order.distance.toStringAsFixed(3)} km'),
                const SizedBox(width: 12),
                _detailChip(
                    Icons.person, 'Driver fee: \$${order.driverFee.toInt()}'),
              ],
            ),

            const SizedBox(height: 10),

            // Note
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(order.note,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.green[700])),
              ],
            ),

            const SizedBox(height: 12),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Get.to(() => MapScreen());
                    },
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
      ),
    );
  }

  Widget _detailChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 3),
        Text(label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }
}
