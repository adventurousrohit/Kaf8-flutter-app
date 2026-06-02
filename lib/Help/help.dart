import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsiveUtils.dart';
import 'helpchat.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqs = [
    {
      'q': 'How do I create a delivery order?',
      'a': 'Tap the "Send a Package" button on the home screen. Fill in the pickup address, '
          'delivery address, and package details. Choose a vehicle type, then confirm your order. '
          'A nearby transporter will accept and handle your delivery.',
      'expanded': false,
    },
    {
      'q': 'How can I track my delivery in real time?',
      'a': 'Once a transporter accepts your order, you can track their live location on the map '
          'directly from your order details screen. The map updates every few seconds so you always '
          'know where your package is.',
      'expanded': false,
    },
    {
      'q': 'What payment methods are accepted?',
      'a': 'We accept major credit and debit cards (Visa, Mastercard) via our secure Stripe '
          'integration. You can also save cards to your account for faster checkout on future orders.',
      'expanded': false,
    },
    {
      'q': 'How do I cancel an order?',
      'a': 'You can cancel a pending order before a transporter accepts it. Open the order from '
          'your Orders tab and tap "Cancel Order". Once a transporter has accepted and is on the way, '
          'cancellation may incur a fee.',
      'expanded': false,
    },
    {
      'q': 'What should I do if my package is damaged or lost?',
      'a': 'Please contact our support team immediately via the Live Chat button below. '
          'Provide your order number and a description of the issue. We will investigate and '
          'resolve the matter within 48 hours.',
      'expanded': false,
    },
    {
      'q': 'How do I become a transporter on KAF8?',
      'a': 'Select the "Transporter" role during registration. Upload your vehicle details and '
          'driver license. Once your profile is approved, you can start accepting delivery orders '
          'near your location.',
      'expanded': false,
    },
    {
      'q': 'How is the delivery price calculated?',
      'a': 'The delivery price is based on the distance between pickup and drop-off locations, '
          'the vehicle type required, and the weight or size of the package. You will always see '
          'the price before confirming an order.',
      'expanded': false,
    },
    {
      'q': 'How do I update my delivery address?',
      'a': 'Go to Settings → My Address to manage your saved addresses. You can add new addresses, '
          'set a default address, or remove old ones at any time.',
      'expanded': false,
    },
  ];

  List<Map<String, dynamic>> get _filtered => _searchQuery.isEmpty
      ? _faqs
      : _faqs
      .where((f) => (f['q'] as String)
      .toLowerCase()
      .contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchController.dispose();
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
          // Background shapes
          Positioned(top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.60, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.18))),
          Positioned(top: 0, right: 0,
              child: Transform(alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.36, fit: BoxFit.contain,
                      opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.12)))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.50, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.22))),

          SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _circleBack(context, theme),
                      const Spacer(),
                      Text("Help",
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleLarge?.color)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── Search bar ─────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) =>
                                setState(() => _searchQuery = v),
                            style: GoogleFonts.inter(fontSize: 14 * fontScale, color: theme.textTheme.bodyLarge?.color),
                            decoration: InputDecoration(
                              hintText: "Enter keyword or what to look for",
                              hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[400],
                                  fontSize: 13 * fontScale),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.grey[400], size: 20),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── FAQ accordion ──────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            children: List.generate(_filtered.length, (i) {
                              final item = _filtered[i];
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () => setState(
                                            () => item['expanded'] =
                                        !(item['expanded'] as bool)),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(item['q'] as String,
                                                style: GoogleFonts.inter(
                                                    fontSize: 14 * fontScale,
                                                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
                                          ),
                                          Icon(
                                              (item['expanded'] as bool)
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: Colors.grey[500], size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (item['expanded'] as bool)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 14),
                                      child: Text(item['a'] as String,
                                          style: GoogleFonts.inter(
                                              fontSize: 13 * fontScale,
                                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                              height: 1.5)),
                                    ),
                                  if (i < _filtered.length - 1)
                                    Divider(height: 1, thickness: 0.7,
                                        indent: 16, endIndent: 16, color: theme.dividerColor),
                                ],
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Go to Help Chat button ─────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onPressed: () =>
                                Get.to(() => const HelpChatScreen()),
                            child: Text("Live Chat Support",
                                style: GoogleFonts.inter(
                                    fontSize: 15 * fontScale,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _circleBack(BuildContext context, ThemeData theme) => GestureDetector(
  onTap: () => Navigator.pop(context),
  child: Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white24 : Colors.grey[800]!, width: 1.8)),
    child: Icon(Icons.arrow_back_ios_new,
        size: 15, color: theme.iconTheme.color),
  ),
);
