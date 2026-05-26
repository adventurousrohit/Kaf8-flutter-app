import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../small-widgets/app_assets.dart';
import '../small-widgets/app_colors.dart';
import 'cencelOrder.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              const Icon(
                Icons.arrow_back_ios,
                color: Color(0XFF60635E),
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                "Back",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          " Order Details ",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(AppAssets.person1, width: 38, height: 38),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, left: 20,right: 18),
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOrderInfoCol(
                    "Order ID #81",
                    "Date: 2024-03-22 / 00:20:13",
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "John Doe",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 11.36,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 140,
                        child: Row(
                          children: [
                            Icon(Icons.call,size: 7,color: Color(0XFF045146),),
                            SizedBox(width: 2),
                            Text(
                              '+1 234 567 897',
                              style: GoogleFonts.poppins(
                                color: Color(0XFF212121),
                                fontSize: 7.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on_sharp,size: 7,color: Color(0XFF045146),),
                          SizedBox(width: 2),
                          Text(
                            '123 Main St, Apt 4B, City, State',
                            style: GoogleFonts.poppins(
                              color: Color(0XFF212121),
                              fontSize: 7.35,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Status : ',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Color(0XFF212121),
                              fontSize: 8,
                            ),
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Out for Delivery',
                            style: GoogleFonts.poppins(
                              color: Color(0XFF212121),
                              fontSize: 7.35,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12,),
              Divider(thickness: 2,color: Color(0XFFEEEEEE),),
              const SizedBox(height: 10),
              Text(
                "Items Ordered",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.43,
                ),
              ),
              const SizedBox(height: 15),
              _buildProductCard("Goods", "Quantity: 2", "\$Price:20.00"),
              _buildProductCard("Goods", "Quantity: 2", "\$Price:20.00"),

              const SizedBox(height: 15),
              Divider(thickness: 1,color: Color(0XFFEEEEEE),),
              _buildSummaryRow("Payment Method", "Paid with Credit Card"),
              _buildSummaryRow("Total Cost", "\$30.00", isBold: true),
              _buildSummaryRow("Tracking Number", "1Z9999999999999999"),
              _buildSummaryRow("Carrier", "UPS"),

              const SizedBox(height: 25),
              Text(
                "Track Order",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              _buildTrackingStep(
                icon: Icons.access_time,
                title: "Your delivery time",
                subtitle: "10 minutes",
                isActive: true,
              ),
              _buildVerticalDottedLine(),
              _buildTrackingStep(
                icon: Icons.location_on_outlined,
                title: "Your address",
                subtitle: "Home address",
                isActive: false,
              ),
              const SizedBox(height: 30),
              _buildButton(
                "Confirm Order",
                const Color(0xFF00C853),
                Colors.white,
                    () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Image.asset(AppAssets.partyingface, width: 120, height: 120),


                              /// TITLE
                              Text(
                                "Ordered successfully",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  color: const Color(0xff1D1B20),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              const SizedBox(height: 18),

                              /// DESCRIPTION
                               Text(
                                "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xff6F6F6F),
                                  fontWeight: FontWeight.w400,
                                ),

                              ),

                              const SizedBox(height: 28),

                              /// BUTTON
                              // SizedBox(
                              //   width: double.infinity,
                              //   height: 52,
                              //   child: ElevatedButton(
                              //     style: ElevatedButton.styleFrom(
                              //       backgroundColor: const Color(0xFF00C853),
                              //       elevation: 0,
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(14),
                              //       ),
                              //     ),
                              //     onPressed: () {
                              //       Navigator.pop(context);
                              //     },
                              //     child: Text(
                              //       "Done",
                              //       style: GoogleFonts.inter(
                              //         fontSize: 24,
                              //         color: Colors.white,
                              //         fontWeight: FontWeight.w400,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildButton(
                "Cancel order",
                const Color(0xFFE8EBE6),
                const Color(0XFFB6B8B6),
                  (){
                    Get.to(CancelOrder());

                    // Navigator.pushNamed(context, AppRoutes.CancelOrder);
                  }
              ),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCol(
    String title,
    String subtitle, {
    bool isRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 11.36,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 140,
          child: Row(
            children: [
              // Image.asset(AppAssets.done, width: 9, height: 9),
              Image.asset(AppAssets.order, width: 9, height: 9),
              SizedBox(width: 2),
              Text(
                subtitle,
                textAlign: isRight ? TextAlign.right : TextAlign.left,
                style: GoogleFonts.poppins(
                  color: Color(0XFF212121),
                  fontSize: 7.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(String name, String qty, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow:[
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 3
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade100),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4
                )
              ]
            ),
            child: Image.asset(AppAssets.multibox)
            // child: Image.asset(AppAssets.box)
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  qty,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 8.96,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 11.19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13,fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 11,fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0XFF03443C) :const Color(0XFF03443C) ,
          size: 20
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:  GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 17,
                color: Color(0XFF00C853)
              ),
            ),
            Text(
              subtitle,
              style:GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 18.39,
                  color: Color(0XFF000000)
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalDottedLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Column(
        children: List.generate(4,
              (index) {
            double opacity = 0.1 + (index * 0.2);
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              width: 6.13,
              height: 6.13,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(opacity > 1.0 ? 1.0 : opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildButton(String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }}
