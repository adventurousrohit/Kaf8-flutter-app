import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ORDER DETAILS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDetailCard(
                    itemCount: '+1',
                    title: 'Goods',
                    price: 50,
                    subtotal: 50,
                    shoppingCost: 5,
                    taxes: 5,
                    total: 60,
                    vehicle: '🚚',
                    vehicleLabel: 'Van',
                    distance: 6.651,
                    size: 'small',
                    note: 'Lorem ipsum shop',
                    orderId: '#81',
                    date: '2024-03-22 / 05:25',
                    driverName: 'Wade Warren',
                    driverAvatar:
                        'https://randomuser.me/api/portraits/men/45.jpg',
                    statusLabel: 'Ready',
                  ),
                  _buildDetailCard(
                    itemCount: '+1',
                    title: 'Goods',
                    price: 50,
                    subtotal: 50,
                    shoppingCost: 0,
                    taxes: 5,
                    total: 55,
                    vehicle: '🚚',
                    vehicleLabel: 'Van',
                    distance: 6.651,
                    size: 'small',
                    note: 'Lorem ipsum shop',
                    orderId: '#81',
                    date: '2024-03-22 / 05:25',
                    driverName: 'Wade Warren',
                    driverAvatar:
                        'https://randomuser.me/api/portraits/men/45.jpg',
                    statusLabel: 'Ready',
                  ),
                  _buildDetailCard(
                    itemCount: '×1',
                    title: 'Goods',
                    price: 60,
                    subtotal: 60,
                    shoppingCost: 0,
                    taxes: 5,
                    total: 65,
                    vehicle: '🚚',
                    vehicleLabel: 'Van',
                    distance: 6.651,
                    size: 'small',
                    note: 'Lorem ipsum shop',
                    orderId: '#81',
                    date: '2024-03-11 / 04:21',
                    driverName: 'Wade Warren',
                    driverAvatar:
                        'https://randomuser.me/api/portraits/men/45.jpg',
                    statusLabel: 'Ready',
                  ),
                ],
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
          Text('Orders Details',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
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

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tab('New', false),
          _tab('Active', false),
          _tab('History', true),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String itemCount,
    required String title,
    required double price,
    required double subtotal,
    required double shoppingCost,
    required double taxes,
    required double total,
    required String vehicle,
    required String vehicleLabel,
    required double distance,
    required String size,
    required String note,
    required String orderId,
    required String date,
    required String driverName,
    required String driverAvatar,
    required String statusLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          // ── Header row ────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Center(
                        child: Text('📦', style: TextStyle(fontSize: 26))),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                        child: Text(itemCount,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title,
                            style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(statusLabel,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('\$${price.toStringAsFixed(0)}.00',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Pricing breakdown ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _priceRow('Subtotal', '\$${subtotal.toStringAsFixed(0)} \$1 × ${subtotal.toStringAsFixed(0)}\$'),
                _priceRow('Shopping costs:', '\$${shoppingCost.toStringAsFixed(0)}'),
                _priceRow('Taxes:', '\$${taxes.toStringAsFixed(0)}'),
                const Divider(height: 16),
                _priceRow('Total:', '\$${total.toStringAsFixed(0)} \$', bold: true),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Distance + order info ─────────────────────────────────────
          Row(
            children: [
              _infoChip(Icons.route, '${distance.toStringAsFixed(3)} km'),
              const SizedBox(width: 12),
              _infoChip(Icons.receipt, 'Order ID $orderId'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(note,
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.green[700])),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(date,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.grey[500])),
            ],
          ),

          const SizedBox(height: 12),

          // ── Driver row ────────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(driverAvatar),
              ),
              const SizedBox(width: 8),
              Text(driverName,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),

          const SizedBox(height: 12),

          // ── Buttons ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Delivery Status',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.black87)),
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
                  child: Text('Call to Customer',
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
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: Colors.black87)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }
}
