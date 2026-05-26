import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsiveUtils.dart';

class CancelOrder extends StatefulWidget {
  const CancelOrder({super.key});

  @override
  State<CancelOrder> createState() => _CancelOrderState();
}

class _CancelOrderState extends State<CancelOrder> {
  final TextEditingController _otherController = TextEditingController();

  // Checkbox states
  final List<String> _reasons = [
    'Late delivery',
    'Can not contact to the driver',
    'Driver denied to come to pickup',
    'Driver denied to come to pickup',
    'Displayed wrong address',
    'Unfavorable price',
    'I want to order another restaurant',
    'I just want to cancel the order',
  ];
  final Set<String> _selected = {};
  bool _showSuccess = false;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _onSend() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select at least one reason"),
          backgroundColor: Colors.red));
      return;
    }
    setState(() => _showSuccess = true);
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // ── Background shapes ──────────────────────────────────────
          Positioned(top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.62, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.20))),
          Positioned(top: 0, right: 0,
              child: Transform(alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.36, fit: BoxFit.contain,
                      opacity: const AlwaysStoppedAnimation(0.13)))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.50, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.22))),

          // ── Main content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey[800]!, width: 1.8)),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 15, color: Colors.black),
                        ),
                      ),
                      const Spacer(),
                      Text("Cancel order",
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                // ── Body ─────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title
                        Text("Please select reasons",
                            style: GoogleFonts.inter(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        const SizedBox(height: 14),

                        // ── Checkbox list ────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            children: List.generate(_reasons.length, (i) {
                              final r = _reasons[i];
                              final checked = _selected.contains(r + i.toString());
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      final key = r + i.toString();
                                      setState(() {
                                        checked
                                            ? _selected.remove(key)
                                            : _selected.add(key);
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      child: Row(
                                        children: [
                                          // Custom checkbox
                                          Container(
                                            width: 22, height: 22,
                                            decoration: BoxDecoration(
                                              color: checked
                                                  ? Colors.green
                                                  : Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: checked
                                                      ? Colors.green
                                                      : Colors.grey[350]!,
                                                  width: 1.5),
                                            ),
                                            child: checked
                                                ? const Icon(Icons.check,
                                                size: 14,
                                                color: Colors.white)
                                                : null,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(r,
                                                style: GoogleFonts.inter(
                                                    fontSize: 14 * fontScale,
                                                    color: Colors.black87)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (i < _reasons.length - 1)
                                    const Divider(height: 1,
                                        thickness: 0.7,
                                        indent: 16,
                                        endIndent: 16),
                                ],
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Other section ────────────────────────────
                        Text("Other",
                            style: GoogleFonts.inter(
                                fontSize: 15 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _otherController,
                          maxLines: 4,
                          style: GoogleFonts.inter(
                              fontSize: 13 * fontScale),
                          decoration: InputDecoration(
                            hintText: "Do you have any message to the restaurant",
                            hintStyle: GoogleFonts.inter(
                                color: Colors.grey[400],
                                fontSize: 13 * fontScale),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey[200]!)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey[200]!)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 1.5)),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ── Send button ──────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: _onSend,
                            child: Text("Send",
                                style: GoogleFonts.inter(
                                    fontSize: 16 * fontScale,
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

          // ── Success overlay dialog ─────────────────────────────────
          if (_showSuccess)
            Container(
              color: Colors.black.withOpacity(0.45),
              child: Center(
                child: _SuccessCard(
                  fontScale: fontScale,
                  onBack: () {
                    setState(() => _showSuccess = false);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUCCESS CARD  (shown as overlay after Send)
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessCard extends StatelessWidget {
  final double fontScale;
  final VoidCallback onBack;

  const _SuccessCard({
    required this.fontScale,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2979FF), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Dashed inner border area ─────────────────────────────
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(
                vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2979FF),
                width: 1.5,
                // Dart doesn't support native dashed borders on Container,
                // so we use a CustomPaint wrapper below
              ),
            ),
            child: Column(
              children: [
                // Crying emoji
                const Text("😭",
                    style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text(
                  "We are sorry that your order had\nbeen canceled",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "We will continue improving our service and\npleasing you in the next order.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12 * fontScale,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Back to homepage button ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: onBack,
                child: Text("Back to homepage",
                    style: GoogleFonts.inter(
                        fontSize: 14 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}