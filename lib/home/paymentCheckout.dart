import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';
import 'orderDetails.dart';

/// Shown after order creation when paymentMethod == "pay_now".
/// Fetches a PaymentIntent from the backend, presents Stripe's native
/// payment sheet, then navigates to OrderDetailsScreen on success.
class PaymentCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> order; // the created order from the API
  const PaymentCheckoutScreen({super.key, required this.order});

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  _Status _status = _Status.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPaymentSheet();
  }

  Future<void> _initPaymentSheet() async {
    setState(() { _status = _Status.loading; _errorMessage = null; });

    final orderId = widget.order['id'] as String?;
    final amount  = double.tryParse(
        widget.order['deliveryCost']?.toString() ?? '0') ?? 0;

    // 1. Create intent on backend
    final intentResult = await ApiService.createPaymentIntent(
      amount:   amount,
      currency: 'eur',
      orderId:  orderId,
    );

    if (intentResult['success'] != true) {
      setState(() {
        _status = _Status.error;
        _errorMessage = intentResult['message'] ?? 'Could not create payment';
      });
      return;
    }

    final clientSecret =
        intentResult['data']?['clientSecret'] as String? ?? '';

    // 2. Initialize Stripe payment sheet
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'KAF8 Delivery',
          style: ThemeMode.light,
          returnURL: 'kaf8://payment-complete',
        ),
      );
      setState(() => _status = _Status.ready);
    } catch (e) {
      setState(() {
        _status = _Status.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _presentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // Success — navigate to order details
      Get.offAll(() => OrderDetailsScreen(order: widget.order));
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return; // user dismissed
      setState(() {
        _status = _Status.error;
        _errorMessage = e.error.localizedMessage ?? 'Payment failed';
      });
    } catch (e) {
      setState(() {
        _status = _Status.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(
        widget.order['deliveryCost']?.toString() ?? '0') ?? 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 16, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment',
            style: GoogleFonts.inter(
                fontSize: 17, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
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
                  Text('Order Summary',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery cost',
                          style: GoogleFonts.inter(
                              fontSize: 15, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
                      Text('€${amount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge?.color)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('To',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
                      Expanded(
                        child: Text(
                          widget.order['receiverAddress'] as String? ?? '',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Status feedback
            if (_status == _Status.loading)
              const Center(
                  child: CircularProgressIndicator(color: Colors.green))
            else if (_status == _Status.error)
              _ErrorCard(
                message: _errorMessage ?? 'Something went wrong',
                onRetry: _initPaymentSheet,
              )
            else ...[
              // Pay button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _presentSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Pay €${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text('Secured by Stripe',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

enum _Status { loading, ready, error }

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.red[700])),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text('Try again',
                style: GoogleFonts.inter(
                    color: Colors.red,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
