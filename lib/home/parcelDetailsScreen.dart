import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/Service/location_service.dart';

import '../../../components/delivery_textWidget.dart';
import '../../../small-widgets/app_colors.dart';
import '../small-widgets/app_assets.dart';
import 'orderDetails.dart';

class ParcelDetailsScreen extends StatefulWidget {
  const ParcelDetailsScreen({super.key});

  @override
  State<ParcelDetailsScreen> createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends State<ParcelDetailsScreen> {
  String selectedSize = "Small";
  String selectedType = "Goods";
  String paymentMethod = "Pay Now";
  String selectedVehicle = "Moterbike";
  String _pickupAddress = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _fetchPickupLocation();
  }

  void _fetchPickupLocation() async {
    Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      String? address = await LocationService.getAddressFromLatLng(position);
      if (mounted) {
        setState(() {
          if (address != null) _pickupAddress = address;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Parcel Size", style: GoogleFonts.poppins(
                      color: Colors.black, fontSize: 16,
                      fontWeight: FontWeight.w700)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSizeCard(
                          // "Small", "0.1 kg to 1.0 kg", AppAssets.box),
                          "Small", "0.1 kg to 1.0 kg", AppAssets.box),
                      _buildSizeCard(
                          "Medium", "0.1 kg to 3.0 kg", AppAssets.box),
                      _buildSizeCard(
                          "Large", "0.1 kg to 20.0 kg", AppAssets.box)
                    ],
                  ),

                  const SizedBox(height: 25),
                  Text("Delivery Vehicle",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      _buildVehicleCard("Moterbike", AppAssets.bike),
                      const SizedBox(width: 10),
                      _buildVehicleCard("Lorry", AppAssets.truck2),
                    ],
                  ),

                  const SizedBox(height: 25),
                   Text("Choose type", style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildTypeChip("Goods"),
                      _buildTypeChip("Medicine"),
                      _buildTypeChip("Cosmetics"),
                      _buildTypeChip("Electronic"),
                      _buildTypeChip("Computer"),
                    ],
                  ),
                  const SizedBox(height: 25),
                   Text("Payment Options", style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildPaymentCard("Pay Now", true),
                      const SizedBox(width: 10),
                      _buildPaymentCard("Pay after Delivery", false),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 62.4,
                    padding:  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade50),
                        boxShadow:[
                          BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 1
                          )
                        ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Container(
                            width :54.14,
                            height: 40.29,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade50),
                                boxShadow:[
                                  BoxShadow(
                                      color: AppColors.shadow,
                                      blurRadius: 1
                                  )
                                ]
                            ),
                            child:
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(AppAssets.payment,width: 35,height: 16.15,),
                              // child: Image.asset(AppAssets.stripe,width: 35,height: 16.15,),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Image.asset(AppAssets.payment,width: 45.71,height: 20.52,),
                          // child: Image.asset(AppAssets.paypal,width: 45.71,height: 20.52,),
                        )
                      ],
                    )
                  ),

                  const SizedBox(height: 25),
                   Text("Estimated Cost", style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16,color: Colors.black)),
                  const SizedBox(height: 7),
                  _costRow("Small Package", "\$20.00"),
                  _costRow("Motorbike", "\$15.00"),
                  _costRow("Total Cost", "\$30.00", isTotal: true),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF46890D),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        Get.to(OrderDetailsScreen());

                       // Navigator.pushNamed(context, AppRoutes.OrderDetailsScreen);
                      },
                      child: const Text("Confirm Order",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFFE8EBE6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Back to home",
                          style: TextStyle(color: Color(0XFFB6B8B6), fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0XFF46890D),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(
                    Icons.arrow_back_ios_outlined, color: Colors.white, size: 18),
                Text(" Back",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Image.asset(AppAssets.person1, width: 40, height: 40,),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PICK UP FROM", style: GoogleFonts.poppins(
                        color: Color(0XFFFFFFFFBA), fontSize: 14,
                        fontWeight: FontWeight.w400)),
                    Text(_pickupAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 17,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Recipient Information",
              style: GoogleFonts.poppins(color: Color(0XFFFFFFFF), fontSize: 11,
                  fontWeight: FontWeight.w400)),
          const SizedBox(height: 10),
          _headerTextField("Name Of Receiver"),
          const SizedBox(height: 10),
          _headerTextField("Number Of Receiver"),
          const SizedBox(height: 10),
          _headerTextField("Address Of Receiver"),
        ],
      ),
    );
  }

  Widget _headerTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSizeCard(String title, String weight, String imagePath) {
    bool isSelected = selectedSize == title;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = title),
      child:
      Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.grey.shade100 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.5),
              blurRadius: 3,
            )
          ]
              : [],
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked,
                color: isSelected ? const Color(0XFF46890D) : Colors.grey,
                size: 18,
              ),
            ),
            Image.asset(
              imagePath,
              height: isSelected ? 48.0 : 58.21,
              width: isSelected ? 48.0 : 58.21,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.inventory_2, size: 40),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
            Text(
              weight,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 10.13),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTypeChip(String label) {
    bool isSelected = selectedType == label;
    return GestureDetector(
      onTap: () => setState(() => selectedType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0XFF46890D) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 2,

              )
            ]
        ),
        child: Text(label,
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
      ),
    );
  }
  Widget _buildPaymentCard(String title, bool isSelected) {
    // Is line ko check karein, ye 'paymentMethod' variable use karega jo aapne upar define kiya hai
    bool isSelected = paymentMethod == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => paymentMethod = title);
        },
        child: Container(
          width: 185,
          height: 62,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? Colors.grey.shade100 : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.5),
                blurRadius: 3,
              )
            ]
                : [],
          ),
          child: Stack( // Radio button ko top-right rakhne ke liye Stack best hai
            children: [
              // 1. Radio Button (Top Right)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0XFF46890D) : Colors.grey,
                  size: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: isSelected ? Colors.black : Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }  Widget _costRow(String label, String price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: DottedLine(
                direction: Axis.horizontal,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 2.0,
                dashColor: Colors.black26,
                dashGapLength: 2.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            price,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13.71,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildVehicleCard(String name, String imagePath) {
    bool isSelected = selectedVehicle == name;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedVehicle = name;
          });
        },
        child:  Container(
            width: 188,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? Colors.grey.shade100 : Colors.grey.shade200,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.5),
                  blurRadius: 2,
                )
              ]
                  : [],
            ),
          child: Stack(
            children: [
              Positioned(
                top: 5,
                right: 5,
                child: Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF00C853) : Colors.grey.shade300,
                  size: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Image.asset(
                      imagePath,
                      height: 56,
                      width: 69,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 1),
                    BahamasTextWidget(
                      text: name,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}