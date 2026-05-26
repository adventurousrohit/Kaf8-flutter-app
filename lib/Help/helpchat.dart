import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/appColor.dart';
import '../Utils/responsiveUtils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _ProblemCategory {
  final String label;
  final List<String> subProblems;
  const _ProblemCategory({required this.label, required this.subProblems});
}

const List<_ProblemCategory> _categories = [
  _ProblemCategory(
    label: 'Problem Related To An Order',
    subProblems: [
      'Problem With The Current Order',
      'My Order Has Been Cancelled',
      'Order Damage',
      'Missing Dishes',
      'Incorrect Order',
      'Missing Dishes',
      'Order Delay',
      'Other Order Problems',
    ],
  ),
  _ProblemCategory(
    label: 'Problem Not Related To A Current Order',
    subProblems: [
      'Add Or Modify Items',
      'Delete An Item From The Order',
      'Problem With The Restaurant',
      'Problem With Delivery Person',
      'Other Problem',
    ],
  ),
  _ProblemCategory(
    label: 'Problem With The Delivery Person',
    subProblems: [
      'The Driver Was Rude Or Disrespectful',
      'Delivery Problem With The Driver',
      'Add A Comment',
      'Other Problem',
    ],
  ),
  _ProblemCategory(
    label: 'Other Problem',
    subProblems: [
      'Payment Issue',
      'App Not Working',
      'Account Problem',
      'Other',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class HelpChatScreen extends StatefulWidget {
  const HelpChatScreen({super.key});
  @override
  State<HelpChatScreen> createState() => _HelpChatScreenState();
}

class _HelpChatScreenState extends State<HelpChatScreen> {
  // Which top-level category is checked (-1 = none)
  int _selectedCategoryIndex = -1;

  // Which sub-problems are checked (Set of sub-problem labels)
  final Set<String> _selectedSubs = {};

  // Comment text controller
  final _commentController = TextEditingController();

  // Whether "Add A Comment" sub is selected (triggers text area)
  bool get _showCommentBox =>
      _selectedSubs.contains('Add A Comment') ||
          _selectedSubs.contains('Other') ||
          _selectedSubs.contains('Other Problem');

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onCategoryTap(int index) {
    setState(() {
      if (_selectedCategoryIndex == index) {
        _selectedCategoryIndex = -1;
        _selectedSubs.clear();
      } else {
        _selectedCategoryIndex = index;
        _selectedSubs.clear();
      }
    });
  }

  void _onSubTap(String sub) {
    setState(() {
      if (_selectedSubs.contains(sub)) {
        _selectedSubs.remove(sub);
      } else {
        _selectedSubs.add(sub);
      }
    });
  }

  void _onAdd() {
    if (_selectedCategoryIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select a problem category"),
          backgroundColor: Colors.red));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Your issue has been submitted. We'll contact you soon."),
        backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background shapes
          Positioned(top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.55, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.10))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.45, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.18))),

          SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      _circleBack(context),
                      const Spacer(),
                      Text("Help Chat",
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w700,
                              color: Colors.green)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                // ── Scrollable content ─────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title
                        Text("Choose The Problem",
                            style: GoogleFonts.inter(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        const SizedBox(height: 16),

                        // ── Top-level categories ──────────────────────
                        ...List.generate(_categories.length, (i) {
                          final cat = _categories[i];
                          final bool catChecked = _selectedCategoryIndex == i;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category checkbox row
                              _checkRow(
                                label: cat.label,
                                checked: catChecked,
                                fontScale: fontScale,
                                bold: false,
                                onTap: () => _onCategoryTap(i),
                              ),

                              // Sub-problems (only when this category selected)
                              if (catChecked) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: cat.subProblems.map((sub) {
                                      final bool subChecked =
                                      _selectedSubs.contains(sub);
                                      return _checkRow(
                                        label: sub,
                                        checked: subChecked,
                                        fontScale: fontScale,
                                        bold: false,
                                        onTap: () => _onSubTap(sub),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                // "Add A Comment" text area
                                if (_showCommentBox) ...[
                                  const SizedBox(height: 16),
                                  Text("Other",
                                      style: GoogleFonts.inter(
                                          fontSize: 15 * fontScale,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _commentController,
                                    maxLines: 4,
                                    style: GoogleFonts.inter(
                                        fontSize: 13 * fontScale),
                                    decoration: InputDecoration(
                                      hintText:
                                      "please write your comment here",
                                      hintStyle: GoogleFonts.inter(
                                          color: Colors.grey[400],
                                          fontSize: 13 * fontScale),
                                      filled: true,
                                      fillColor:
                                      const Color(0xFFF8F8F8),
                                      contentPadding:
                                      const EdgeInsets.all(12),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.grey[200]!)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.grey[200]!)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Appcolor.secondaryColor,
                                              width: 1.5)),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // "Still Need A Call? Call Now"
                                  RichText(
                                    text: TextSpan(
                                      text: "Still Need A Call? ",
                                      style: GoogleFonts.inter(
                                          fontSize: 13 * fontScale,
                                          color: Colors.green),
                                      children: [
                                        TextSpan(
                                          text: "Call Now",
                                          style: GoogleFonts.inter(
                                              fontSize: 13 * fontScale,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 8),
                              ],

                              const SizedBox(height: 4),
                            ],
                          );
                        }),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // ── Add button (sticky bottom) ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: _onAdd,
                      child: Text("Add",
                          style: GoogleFonts.inter(
                              fontSize: 16 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
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

  // ── Checkbox row ────────────────────────────────────────────────────────────
  Widget _checkRow({
    required String label,
    required bool checked,
    required double fontScale,
    required bool bold,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            // Custom checkbox
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: checked ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: checked ? Colors.green : Colors.grey[350]!,
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14 * fontScale,
                      fontWeight:
                      bold ? FontWeight.w600 : FontWeight.w400,
                      color: Colors.black87)),
            ),
          ],
        ),
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