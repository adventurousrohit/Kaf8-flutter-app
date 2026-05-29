import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../small-widgets/app_assets.dart';
import '../small-widgets/app_colors.dart';
import '../Controller/order_controller.dart';
import '../Service/api_service.dart';
import 'cencelOrder.dart';
import 'trackingScreen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? order;
  const OrderDetailsScreen({super.key, this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? get order => widget.order;

  // Existing feedback for this order (null = not yet submitted)
  Map<String, dynamic>? _existingFeedback;

  @override
  void initState() {
    super.initState();
    if (order?['statusOrder'] == 'delivered') {
      _loadFeedback();
    }
  }

  Future<void> _loadFeedback() async {
    final id = order?['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final res = await ApiService.getFeedbackForOrder(id);
    if (!mounted) return;
    if (res['success'] == true && res['data'] is Map) {
      setState(() => _existingFeedback = Map<String, dynamic>.from(res['data'] as Map));
    }
  }

  String get _orderId => order != null
      ? (() {
          final raw = order!['id']?.toString() ?? '';
          if (raw.isEmpty) return '#N/A';
          final safe = raw.length >= 8 ? raw.substring(0, 8) : raw;
          return '#${safe.toUpperCase()}';
        })()
      : '#--';

  String get _dateStr =>
      OrderController.formatDate(order?['dateOrder'] as String?);

  String get _status =>
      OrderController.statusLabel(order?['statusOrder'] as String? ?? '');

  String get _receiverName => order?['receiverName'] as String? ?? 'N/A';
  String get _receiverPhone => order?['receiverPhone'] as String? ?? 'N/A';
  String get _receiverAddress => order?['receiverAddress'] as String? ?? 'N/A';
  String get _departureAddress =>
      order?['departureAddress'] as String? ?? 'N/A';
  String get _paymentMethod =>
      OrderController.paymentMethodLabel(order?['paymentMethod'] as String?);
  double get _deliveryCost =>
      double.tryParse(order?['deliveryCost']?.toString() ?? '0') ?? 0;

  List get _packages =>
      (order?['Packages'] ?? order?['packages'] ?? []) as List;

  String? get _trackingNumber {
    if (_packages.isNotEmpty) {
      return _packages.first['trackingNumber'] as String?;
    }
    return null;
  }

  Future<void> _dialReceiver() async {
    final phone = _receiverPhone.trim();
    if (phone.isEmpty || phone == 'N/A') return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        "Call",
        "Unable to start phone call",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _showFeedbackSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FeedbackSheet(
        orderId: order?['id']?.toString() ?? '',
        transporterId: order?['transporterId']?.toString(),
      ),
    );
    if (result != null && mounted) {
      setState(() => _existingFeedback = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_back_ios,
                color: Color(0XFF60635E),
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                "Back",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          " Order Details ",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(AppAssets.person1, width: 38, height: 38),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOrderInfoCol(_orderId, "Date: $_dateStr"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _receiverName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 11.36,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 140,
                      child: InkWell(
                        onTap: _dialReceiver,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.call,
                              size: 7,
                              color: Color(0XFF045146),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                _receiverPhone,
                                style: GoogleFonts.poppins(
                                  color: const Color(0XFF212121),
                                  fontSize: 7.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_sharp,
                          size: 7,
                          color: Color(0XFF045146),
                        ),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 130,
                          child: Text(
                            _receiverAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: const Color(0XFF212121),
                              fontSize: 7.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Status : ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: const Color(0XFF212121),
                            fontSize: 8,
                          ),
                        ),
                        const SizedBox(width: 2),
                        _StatusBadge(
                          status: order?['statusOrder'] ?? 'pending',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(thickness: 2, color: const Color(0XFFEEEEEE)),
            const SizedBox(height: 10),

            // Route
            Text(
              "Delivery Route",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13.43,
              ),
            ),
            const SizedBox(height: 10),
            _routeRow(Icons.my_location, "From", _departureAddress),
            const SizedBox(height: 6),
            _routeRow(Icons.location_on, "To", _receiverAddress),

            if (_packages.isNotEmpty) ...[
              const SizedBox(height: 15),
              Divider(thickness: 1, color: const Color(0XFFEEEEEE)),
              Text(
                "Items Ordered",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.43,
                ),
              ),
              const SizedBox(height: 15),
              ..._packages.map((pkg) => _buildPackageCard(pkg)).toList(),
            ],

            const SizedBox(height: 15),
            Divider(thickness: 1, color: const Color(0XFFEEEEEE)),
            _buildSummaryRow("Payment Method", _paymentMethod),
            _buildSummaryRow(
              "Total Cost",
              "€${_deliveryCost.toStringAsFixed(2)}",
              isBold: true,
            ),
            if (_trackingNumber != null)
              _buildSummaryRow("Tracking Number", _trackingNumber!),

            const SizedBox(height: 25),
            Text(
              "Track Order",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            _buildTrackingStep(
              icon: Icons.access_time,
              title: "Order placed",
              subtitle: _dateStr.isNotEmpty ? _dateStr : "Just now",
              isActive: true,
            ),
            _buildVerticalDottedLine(),
            _buildTrackingStep(
              icon: Icons.local_shipping_outlined,
              title: "In transit",
              subtitle: _status,
              isActive:
                  order?['statusOrder'] == 'active' ||
                  order?['statusOrder'] == 'delivered',
            ),
            _buildVerticalDottedLine(),
            _buildTrackingStep(
              icon: Icons.check_circle_outline,
              title: "Delivered",
              subtitle: order?['statusOrder'] == 'delivered'
                  ? "Completed"
                  : "Pending",
              isActive: order?['statusOrder'] == 'delivered',
            ),

            const SizedBox(height: 20),

            // Live tracking button — only visible when a driver is en route
            if (order?['statusOrder'] == 'active') ...[
              _buildButton(
                "📍  Track Live",
                Colors.green,
                Colors.white,
                () => Get.to(() => TrackingScreen(order: order!)),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 10),

            // Review section — show card if already submitted, button if not
            if (order?['statusOrder'] == 'delivered') ...[
              _existingFeedback != null
                  ? _buildReviewCard(_existingFeedback!)
                  : _buildButton(
                      "⭐  Leave a Review",
                      const Color(0xFFFFF8E1),
                      const Color(0xFFE65100),
                      _showFeedbackSheet,
                    ),
              const SizedBox(height: 12),
            ],

            // Only show cancel if order is still pending
            if (order?['statusOrder'] == 'pending') ...[
              _buildButton(
                "Cancel Order",
                const Color(0xFFE8EBE6),
                const Color(0XFFB6B8B6),
                () =>
                    Get.to(() => CancelOrder(orderId: order?['id'] as String?)),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _routeRow(IconData icon, String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0XFF045146)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(Map pkg) {
    final parcelType = pkg['parcelType'] as String? ?? 'Goods';
    final parcelSize = pkg['parcelSize'] as String? ?? 'Standard';
    final tracking = pkg['trackingNumber'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 3)],
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade100),
              color: Colors.white,
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
            ),
            child: Image.asset(AppAssets.multibox),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parcelType,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Size: $parcelSize",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 9,
                  ),
                ),
                if (tracking.isNotEmpty)
                  Text(
                    "Track: $tracking",
                    style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCol(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 11.36,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 140,
          child: Row(
            children: [
              Image.asset(AppAssets.order, width: 9, height: 9),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: const Color(0XFF212121),
                    fontSize: 7.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0XFF03443C) : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: isActive ? const Color(0XFF00C853) : Colors.grey,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalDottedLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 9),
      child: Column(
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            width: 2,
            height: 5,
            color: Colors.grey.shade300,
          );
        }),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> feedback) {
    final rating = (feedback['overallRating'] as num?)?.toInt() ?? 0;
    final comment = feedback['comment']?.toString() ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('⭐', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('Your Review',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: const Color(0xFFE65100))),
            const Spacer(),
            Row(
              children: List.generate(5, (i) => Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: Colors.orange, size: 18,
              )),
            ),
          ]),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(comment,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.black87, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _buildButton(
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _FeedbackSheet extends StatefulWidget {
  final String orderId;
  final String? transporterId;
  const _FeedbackSheet({required this.orderId, this.transporterId});

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      Get.snackbar(
        "Rating required",
        "Please select a star rating",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _submitting = true);
    final res = await ApiService.submitFeedback({
      'orderId': widget.orderId,
      if (widget.transporterId != null) 'transporterId': widget.transporterId,
      'ratings': {'overall': _rating, 'delivery': _rating},
      'comment': _commentController.text.trim(),
    });
    if (!mounted) return;
    setState(() => _submitting = false);
    if (res['success'] == true) {
      // Build a local feedback map to pass back to the parent screen
      final submitted = {
        'overallRating': _rating,
        'comment': _commentController.text.trim(),
        ...(res['data'] is Map ? Map<String, dynamic>.from(res['data'] as Map) : {}),
      };
      Navigator.pop(context, submitted);
      Get.snackbar(
        "Thank you!",
        "Your review has been submitted",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Error",
        res['message']?.toString() ?? "Failed to submit",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Rate your delivery",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "How was your experience?",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Share your experience (optional)",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _submitting ? null : _submit,
                child: Text(
                  _submitting ? "Submitting..." : "Submit Review",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        OrderController.statusLabel(status),
        style: GoogleFonts.poppins(
          color: _color,
          fontSize: 7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
