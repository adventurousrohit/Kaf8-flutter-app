import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0=PayPal, 1=Stripe
  bool _showCardSheet = false;

  final _cardController = TextEditingController();
  final _expController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _expController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(theme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildCardPlaceholder(theme),
                        const SizedBox(height: 30),
                        _buildOrDivider(theme),
                        const SizedBox(height: 20),
                        _buildMethodTile(
                          index: 0,
                          label: 'Paypal',
                          logo: _PaypalLogo(),
                          theme: theme,
                        ),
                        const SizedBox(height: 14),
                        _buildMethodTile(
                          index: 1,
                          label: 'Stripe',
                          logo: _StripeLogo(),
                          theme: theme,
                        ),
                        const SizedBox(height: 36),
                        _buildContinueButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card entry bottom sheet
            if (_showCardSheet) _buildCardSheet(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(Icons.menu, size: 24, color: theme.iconTheme.color),
          const SizedBox(width: 14),
          Text('Bank Account',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
          const Spacer(),
          Icon(Icons.notifications_none,
              size: 26, color: isDark ? Colors.white70 : Colors.black87),
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

  Widget _buildCardPlaceholder(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _cardIcon(Icons.credit_card, theme),
              const SizedBox(width: 20),
              _cardIcon(Icons.contactless, theme),
              const SizedBox(width: 20),
              _cardIcon(Icons.card_membership, theme),
            ],
          ),
          const SizedBox(height: 20),
          Text('Add credit or debit card',
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _cardIcon(IconData icon, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 64,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Icon(icon, color: Colors.grey[400], size: 28),
    );
  }

  Widget _buildOrDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or',
              style:
                  GoogleFonts.inter(fontSize: 14, color: Colors.grey[500])),
        ),
        Expanded(child: Divider(color: theme.dividerColor)),
      ],
    );
  }

  Widget _buildMethodTile(
      {required int index, required String label, required Widget logo, required ThemeData theme}) {
    final selected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.green : theme.dividerColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.green : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
            const Spacer(),
            logo,
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => setState(() => _showCardSheet = true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: Text('Continue',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildCardSheet(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {}, // prevent dismiss on tap inside
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 24),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('New Payment',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
              const SizedBox(height: 4),
              Text('Card details',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey[500])),
              const SizedBox(height: 12),
              _inputField('Enter card details', _cardController, theme),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exp date',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(height: 6),
                        _inputField('DD/MM', _expController, theme),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CVV',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(height: 6),
                        _inputField('Enter CVV', _cvvController, theme),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _showCardSheet = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Text('Submit',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController controller, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5F7FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ── Logos ─────────────────────────────────────────────────────────────────────

class _PaypalLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
              text: 'Pay',
              style: TextStyle(
                  color: Color(0xFF003087),
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          TextSpan(
              text: 'Pal',
              style: TextStyle(
                  color: Color(0xFF009CDE),
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ],
      ),
    );
  }
}

class _StripeLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'stripe',
      style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF635BFF)),
    );
  }
}
