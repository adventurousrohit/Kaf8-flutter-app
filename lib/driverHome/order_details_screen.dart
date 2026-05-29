import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/order_controller.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final Map<String, dynamic> order;

  List<dynamic> get _packages =>
      (order['Packages'] ?? order['packages'] ?? []) as List<dynamic>;

  String get _orderId {
    final id = order['id']?.toString() ?? '';
    if (id.length < 8) return id;
    return '#${id.substring(0, 8).toUpperCase()}';
  }

  String get _status => order['statusOrder']?.toString() ?? 'pending';

  Color get _statusColor {
    switch (_status) {
      case 'active':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String get _parcelType {
    if (_packages.isEmpty) return 'Goods';
    return _packages.first['parcelType']?.toString() ?? 'Goods';
  }

  double get _deliveryCost =>
      double.tryParse(order['deliveryCost']?.toString() ?? '0') ?? 0;

  String get _createdAt =>
      OrderController.formatDate(order['dateOrder']?.toString());

  String get _fromAddress => order['departureAddress']?.toString() ?? 'N/A';
  String get _toAddress => order['receiverAddress']?.toString() ?? 'N/A';
  String get _receiverName => order['receiverName']?.toString() ?? 'Customer';
  String get _receiverPhone => order['receiverPhone']?.toString() ?? 'N/A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDetailCard(context),
                ],
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
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          Text('Order Details',
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

  Widget _buildDetailCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
                    if (_packages.isNotEmpty)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                          child: Text('x${_packages.length}',
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
                          child: Text(OrderController.statusLabel(_status),
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: _statusColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('€${_deliveryCost.toStringAsFixed(2)}',
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
                _priceRow('Delivery cost', '€${_deliveryCost.toStringAsFixed(2)}'),
                _priceRow(
                  'Payment',
                  OrderController.paymentMethodLabel(order['paymentMethod']?.toString()),
                ),
                _priceRow('Status', OrderController.statusLabel(_status)),
                const Divider(height: 16),
                _priceRow('Order ID', _orderId, bold: true),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Distance + order info ─────────────────────────────────────
          Row(
            children: [
              _infoChip(Icons.receipt, _orderId),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(_createdAt,
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
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: Colors.green),
              ),
              const SizedBox(width: 8),
              Text(_receiverName,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text(_receiverPhone,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  )),
            ],
          ),

          const SizedBox(height: 12),

          // ── Buttons ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showAddressDialog(
                    context,
                    title: 'Route',
                    content: 'From: $_fromAddress\n\nTo: $_toAddress',
                  ),
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
                  onPressed: () => _showAddressDialog(
                    context,
                    title: 'Customer',
                    content: 'Name: $_receiverName\nPhone: $_receiverPhone',
                  ),
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

  void _showAddressDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
