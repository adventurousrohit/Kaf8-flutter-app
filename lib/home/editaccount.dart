import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/delivery_textfiled.dart';
import '../../../small-widgets/app_assets.dart';


class AccountScreenEdit extends StatelessWidget {
  const AccountScreenEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
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
                "Cancel",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        title: Text("My Account",style: GoogleFonts.poppins(fontWeight: FontWeight.bold,fontSize: 17),),
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.only(right: 10),
            child: Text("Save",style: GoogleFonts.poppins(fontSize: 15,fontWeight: FontWeight.w700,
                color: Color(0XFF00C853)),),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Image.asset(
                          AppAssets.person1,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color:  Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color(0XFF60635E),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                DeliveryTextFormField(
                  hintText: "Wade Warren",
                ),
                Row(
                  children: [
                    const SizedBox(height: 15),
                    Expanded(
                      flex: 1,
                      child: DeliveryTextFormField(
                        hintText: "405",
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 3,
                      child: DeliveryTextFormField(
                        hintText: "555-0128",
                      ),
                    )
                  ],
                ),
                DeliveryTextFormField(
                  hintText: "12-10-1996",
                ),
                DeliveryTextFormField(
                  hintText: "Address-Home",
                  suffixIcon: Icon(Icons.keyboard_arrow_right_rounded,color: Colors.grey,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}