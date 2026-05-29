import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';
import '../Utils/responsiveUtils.dart';
import 'AddAccountScreen.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});
  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  bool _loading = true;
  int? _selectedIndex;
  List<Map<String, dynamic>> _methods = [];

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() => _loading = true);
    final res = await ApiService.getPaymentMethods();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res['success'] == true && res['data'] is List) {
        _methods = List<Map<String, dynamic>>.from(
          (res['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
        final defaultIdx = _methods.indexWhere((m) => m['isDefault'] == true);
        _selectedIndex = defaultIdx >= 0 ? defaultIdx : (_methods.isNotEmpty ? 0 : null);
      }
    });
  }

  String _brandLabel(Map<String, dynamic> method) {
    final brand = method['brand']?.toString() ?? '';
    final type  = method['type']?.toString() ?? 'card';
    if (brand.isNotEmpty) {
      return brand[0].toUpperCase() + brand.substring(1);
    }
    return type[0].toUpperCase() + type.substring(1);
  }

  String _maskedNumber(Map<String, dynamic> method) {
    final last4 = method['last4']?.toString();
    if (last4 != null && last4.isNotEmpty) {
      return '•••• •••• •••• $last4';
    }
    // Try to get from details JSON
    final details = method['details'];
    if (details is Map) {
      final num = details['last4']?.toString();
      if (num != null) return '•••• •••• •••• $num';
    }
    return '•••• •••• •••• ••••';
  }

  bool _isVisa(Map<String, dynamic> method) {
    final brand = method['brand']?.toString().toLowerCase() ?? '';
    return brand == 'visa';
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // Background shapes
          Positioned(top: 0, left: 0,
            child: Image.asset('assets/images/bg_top_left.png',
              width: size.width * 0.60, fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.18))),
          Positioned(top: 0, right: 0,
            child: Transform(alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset('assets/images/bg_bottom_right.png',
                width: size.width * 0.36, fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.12)))),
          Positioned(bottom: 0, right: 0,
            child: Image.asset('assets/images/bg_bottom_right.png',
              width: size.width * 0.50, fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.25))),

          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _circleBack(context),
                      const Spacer(),
                      Text('bank_account_title'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 17 * fontScale,
                          fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          await Get.to(() => const AddAccountScreen());
                          _loadMethods();
                        },
                        child: const Icon(Icons.add, size: 24, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.8),

                // Body
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _methods.isEmpty
                          ? _emptyState(fontScale)
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _methods.length,
                              separatorBuilder: (context, i) => const Divider(
                                  height: 1, thickness: 0.8,
                                  indent: 16, endIndent: 16),
                              itemBuilder: (context, index) {
                                final method = _methods[index];
                                final selected = _selectedIndex == index;
                                return InkWell(
                                  onTap: () => setState(() => _selectedIndex = index),
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        // Brand logo
                                        Container(
                                          width: 48, height: 30,
                                          decoration: BoxDecoration(
                                            color: _isVisa(method)
                                                ? const Color(0xFF1A1F71)
                                                : Colors.grey[800],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _brandLabel(method).toUpperCase(),
                                            style: GoogleFonts.inter(
                                              fontSize: 10 * fontScale,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: 0.5),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(children: [
                                                Text(_brandLabel(method),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14 * fontScale,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87)),
                                                if (method['isDefault'] == true) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.shade50,
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: Colors.green, width: 0.8),
                                                    ),
                                                    child: Text('default_badge'.tr,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 10 * fontScale,
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.w600)),
                                                  ),
                                                ],
                                              ]),
                                              const SizedBox(height: 3),
                                              Text(_maskedNumber(method),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12 * fontScale,
                                                  color: Colors.grey[500],
                                                  letterSpacing: 1)),
                                            ],
                                          ),
                                        ),
                                        selected
                                          ? Container(
                                              width: 24, height: 24,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle),
                                              child: const Icon(Icons.check,
                                                  size: 14, color: Colors.white))
                                          : Container(
                                              width: 24, height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.grey[400]!,
                                                    width: 1.5))),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(double fontScale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'no_payment_methods'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14 * fontScale,
                  color: Colors.grey[500],
                  height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _circleBack(BuildContext context) {
  return GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[800]!, width: 1.8)),
      child: const Icon(Icons.arrow_back_ios_new, size: 15, color: Colors.black),
    ),
  );
}
