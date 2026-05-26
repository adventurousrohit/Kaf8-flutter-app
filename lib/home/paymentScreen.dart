import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/delivery_textfiled.dart';
import '../../../small-widgets/app_colors.dart';
import '../module/userProfileScreen/getx/switchController.dart';
import 'editCardScreen.dart';

class PaymentScreens extends StatelessWidget {
  const PaymentScreens({super.key});


  @override
  Widget build(BuildContext context) {

    final SwitchController switchController = Get.put(SwitchController());

    return Scaffold(
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
              const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
              const SizedBox(width: 4),
              Text(
                "Back",
                style: GoogleFonts.poppins(
                  color: Colors.black,
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
            color: Color(0XFF363A33),
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
                color: const Color(0XFFF9FAF8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Set as default",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: switchController.isDefault.value,
                      onChanged: (val) {
                        switchController.toggleDefault(val);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0XFF00C853),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(thickness: 1, color: Color(0XFFE8EBE6)),
            ),
            SizedBox(height: 12),
            DeliveryTextFormField(hintText: "Cardholder name"),
            SizedBox(height: 12),
            DeliveryTextFormField(hintText: "Card name"),
            SizedBox(height: 12),
            DeliveryTextFormField(hintText: "Expiration date"),
            SizedBox(height: 12),
            DeliveryTextFormField(hintText: "CVV"),
            SizedBox(height: 153),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                 Get.to(EditCardScreen());

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  "Save",
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
