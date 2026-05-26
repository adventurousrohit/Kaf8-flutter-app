import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../small-widgets/app_assets.dart';

class OrdersEmptyScreen extends StatelessWidget {
  const OrdersEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// APP BAR
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
               title: const Text(
                     "Orders",
                     style: TextStyle(
                       color: Colors.black,
                       fontSize: 17,
                       fontWeight: FontWeight.w700,
                     ),
                   ),
           ),
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   leading: InkWell(
      //     onTap: () => Navigator.pop(context),
      //     child: Row(
      //       children: [
      //         const SizedBox(width: 10),
      //         const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
      //         const SizedBox(width: 4),
      //         Text(
      //           "Back",
      //           style: GoogleFonts.poppins(
      //             color: Colors.black,
      //             fontSize: 15,
      //             fontWeight: FontWeight.w500,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      //
      //   title: const Text(
      //     "Orders",
      //     style: TextStyle(
      //       color: Colors.black,
      //       fontWeight: FontWeight.w500,
      //     ),
      //   ),
      // ),

      /// BODY
      body: Column(
        children: [
          const Spacer(),

          /// IMAGE (replace with your asset)
          Image.asset(AppAssets.Empty,height: 180),

          const SizedBox(height: 20),

          /// TITLE
           Text(
            "There are no orders!",
            style: GoogleFonts.inter(
              fontSize: 32 ,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          /// SUBTITLE
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Place order to show here. Previous orders will be shown here as well.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15 ,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// BUTTON
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFF00C853),
              padding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("My Cart",
              style: GoogleFonts.inter(
              fontSize: 15 ,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),),
          ),

          const Spacer(),
        ],
      ),

      /// BOTTOM NAV BAR
    );
  }
}