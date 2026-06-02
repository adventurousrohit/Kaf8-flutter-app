import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/order_controller.dart';
import 'call_screen.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, theme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDetailCard(context, theme),
                ],
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
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          Text('Order Details',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
          const Spacer(),
          Stack(
            children: [
              Icon(Icons.notifications_none,
                  size: 26, color: isDark ? Colors.white70 : Colors.black87),
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

  Widget _buildDetailCard(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
                  color: isDark ? Colors.white10 : Colors.grey[100],
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
                                fontSize: 15, fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color)),
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
                            color: theme.textTheme.bodyLarge?.color)),
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
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _priceRow('Delivery cost', '€${_deliveryCost.toStringAsFixed(2)}', theme),
                _priceRow(
                  'Payment',
                  OrderController.paymentMethodLabel(order['paymentMethod']?.toString()),
                  theme
                ),
                _priceRow('Status', OrderController.statusLabel(_status), theme),
                Divider(height: 16, color: theme.dividerColor),
                _priceRow('Order ID', _orderId, theme, bold: true),
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
                child: const Icon(Icons.person, color: Colors.green, size: 18),
              ),
              const SizedBox(width: 8),
              Text(_receiverName,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
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
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Delivery Status',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.to(() => CallScreen(
                        name: _receiverName,
                        duration: 'Calling...',
                      )),
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

  Widget _priceRow(String label, String value, ThemeData theme, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
          const Spacer(),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
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
