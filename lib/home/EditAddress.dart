import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/delivery_textfiled.dart';
import '../module/userProfileScreen/getx/switchController.dart';

class EditAddressScreens extends StatelessWidget {
  const EditAddressScreens({super.key});

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
          " Edit Address ",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
              DeliveryTextFormField(
                hintText: "Home",
                hintStyle: GoogleFonts.poppins(
                  color: Color(0XFF363A33),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 12),
              DeliveryTextFormField(
                hintText: "Buzz apartment 4B",
                hintStyle: GoogleFonts.poppins(
                  color: Color(0XFF363A33),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                Divider(thickness: 1, color: Color(0XFFE8EBE6)),
              ),
              SizedBox(height: 12),
              DeliveryTextFormField(
                hintText: "Daniel Jones",
                hintStyle: GoogleFonts.poppins(
                  color: Color(0XFF363A33),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DeliveryTextFormField(
                      hintText: "405",
                      hintStyle: GoogleFonts.poppins(
                        color: Color(0XFF363A33),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 12,),
                  Expanded(
                    flex: 5,
                    child: DeliveryTextFormField(
                      hintText: "555-0128",
                      hintStyle: GoogleFonts.poppins(
                        color: Color(0XFF363A33),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              DeliveryTextFormField(
                hintText: "123 Main St, Apt 4B",
                hintStyle: GoogleFonts.poppins(
                  color: Color(0XFF363A33),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DeliveryTextFormField(
                      hintText: "New York",
                      hintStyle: GoogleFonts.poppins(
                        color: Color(0XFF363A33),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 12,),
                  Expanded(
                    flex: 5,
                    child: DeliveryTextFormField(
                      hintText: "California",
                      hintStyle: GoogleFonts.poppins(
                        color: Color(0XFF363A33),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DeliveryTextFormField(
                      hintText: "10001",
                      hintStyle: GoogleFonts.poppins(
                        color: Color(0XFF363A33),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 12,),
                  Expanded(
                    flex: 5,
                    child: DeliveryTextFormField(
                      hintText: "United States",
                      hintStyle: GoogleFonts.poppins(
                        color: Color(0XFF363A33),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 153),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFFE8EBE6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    "Save changes",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0XFFB6B8B6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
