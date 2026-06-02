import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';
import '../components/delivery_textfiled.dart';
import '../small-widgets/app_colors.dart';
import '../module/userProfileScreen/getx/switchController.dart';
import 'editCardScreen.dart';

class PaymentScreens extends StatefulWidget {
  const PaymentScreens({super.key});

  @override
  State<PaymentScreens> createState() => _PaymentScreensState();
}

class _PaymentScreensState extends State<PaymentScreens> {
  final _holderController = TextEditingController();
  final _cardController = TextEditingController();
  final _expController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isSaving = false;
  bool _isLoadingMethods = false;
  int _savedMethodsCount = 0;

  bool get _isFormValid =>
      _holderController.text.trim().isNotEmpty &&
      _cardController.text.trim().isNotEmpty &&
      _expController.text.trim().isNotEmpty &&
      _cvvController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _holderController.dispose();
    _cardController.dispose();
    _expController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoadingMethods = true);
    final response = await ApiService.getPaymentMethods();
    if (!mounted) return;
    if (response['success'] == true && response['data'] is List) {
      _savedMethodsCount = (response['data'] as List).length;
    }
    setState(() => _isLoadingMethods = false);
  }

  Future<void> _saveCard(bool isDefault) async {
    if (!_isFormValid) {
      Get.snackbar("Missing info", "Please fill all card fields");
      return;
    }
    setState(() => _isSaving = true);
    final response = await ApiService.savePaymentMethod({
      "type": "card",
      "details": {
        "cardholderName": _holderController.text.trim(),
        "cardNumber": _cardController.text.trim(),
        "expiry": _expController.text.trim(),
        "cvv": _cvvController.text.trim(),
      },
      "isDefault": isDefault,
    });
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (response['success'] == true) {
      _holderController.clear();
      _cardController.clear();
      _expController.clear();
      _cvvController.clear();
      _loadPaymentMethods();
      Get.to(EditCardScreen());
      return;
    }
    Get.snackbar("Error", response['message']?.toString() ?? "Unable to save card");
  }

  @override
  Widget build(BuildContext context) {

    final SwitchController switchController = Get.put(SwitchController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(Icons.arrow_back_ios, color: theme.iconTheme.color, size: 18),
              const SizedBox(width: 4),
              Text(
                "Back",
                style: GoogleFonts.poppins(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          "Add a card",
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Set as default",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoadingMethods
                              ? "Loading saved methods..."
                              : "Saved methods: $_savedMethodsCount",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: switchController.isDefault.value,
                      onChanged: (val) {
                        switchController.toggleDefault(val);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0XFF00C853),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(thickness: 1, color: theme.dividerColor),
            ),
            const SizedBox(height: 12),
            DeliveryTextFormField(
              hintText: "Cardholder name",
              controller: _holderController,
            ),
            const SizedBox(height: 12),
            DeliveryTextFormField(
              hintText: "Card name",
              controller: _cardController,
            ),
            const SizedBox(height: 12),
            DeliveryTextFormField(
              hintText: "Expiration date",
              controller: _expController,
            ),
            const SizedBox(height: 12),
            DeliveryTextFormField(
              hintText: "CVV",
              controller: _cvvController,
            ),
            const SizedBox(height: 153),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                  _saveCard(switchController.isDefault.value);

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  _isSaving ? "Saving..." : "Save",
                  style: GoogleFonts.inter(
                    fontSize: 18.52,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
