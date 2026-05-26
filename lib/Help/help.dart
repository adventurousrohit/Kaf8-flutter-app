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
      'q': 'Lorem ipsum dolor sit amet',
      'a': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
          'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      'expanded': false,
    },
    {
      'q': 'Lorem ipsum dolor sit amet',
      'a': 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
      'expanded': false,
    },
    {
      'q': 'Lorem ipsum dolor sit amet',
      'a': 'Duis aute irure dolor in reprehenderit in voluptate velit esse.',
      'expanded': false,
    },
    {
      'q': 'Lorem ipsum dolor sit amet',
      'a': 'Excepteur sint occaecat cupidatat non proident sunt in culpa.',
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
                  opacity: const AlwaysStoppedAnimation(0.22))),

          SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _circleBack(context),
                      const Spacer(),
                      Text("Help",
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
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
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) =>
                                setState(() => _searchQuery = v),
                            style: GoogleFonts.inter(fontSize: 14 * fontScale),
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
                            color: Colors.white,
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
                                                    color: Colors.black87)),
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
                                              color: Colors.grey[600],
                                              height: 1.5)),
                                    ),
                                  if (i < _filtered.length - 1)
                                    const Divider(height: 1, thickness: 0.7,
                                        indent: 16, endIndent: 16),
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

Widget _circleBack(BuildContext context) => GestureDetector(
  onTap: () => Navigator.pop(context),
  child: Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[800]!, width: 1.8)),
    child: const Icon(Icons.arrow_back_ios_new,
        size: 15, color: Colors.black),
  ),
);