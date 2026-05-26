
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Utils/appColor.dart';
import '../Utils/appImage.dart';
import '../Utils/primaryButtion.dart';
import '../Utils/responsiveUtils.dart';
import '../components/delivery_textWidget.dart';
import 'RegisterScreenuser.dart';

class changepassword extends StatefulWidget {
  const changepassword({super.key});

  @override
  State<changepassword> createState() => _changepasswordState();
}

class _changepasswordState extends State<changepassword> {
  @override
  /// ✅ Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// ✅ Login Function
  // void _handleLogin() {
  //   print("Login Clicked");
  // }
  bool isPasswordVisible = true;
  bool isPasswordVisible1 = true;
  bool isPasswordWrong = false;
  void _handleLogin() {
    if (passwordController.text != "123456") { // demo check
      setState(() {
        isPasswordWrong = false;
      });
    } else {
      setState(() {
        isPasswordWrong = false;
      });

      print("Login Success");
    }
  }  @override
  void initState() {
    super.initState();

    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.componentScale(context);
    final padding = ResponsiveUtils.paddingScale(context) * 16;
    final fontScale = ResponsiveUtils.fontScale(context);
    bool isEnabled = emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;

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
        title: const BahamasTextWidget(
          text: "New password",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Enter first enter the current password and then your new password.",
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0XFF60655C)),
              ),
              const SizedBox(height: 17),
              Text("Current password",style: TextStyle(color: Colors.black),),
              const SizedBox(height: 5),
              TextField(
                controller: emailController, // ✅ attach
                decoration: InputDecoration(
                  hintText: "Current password",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(8),

                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Appcolor.greyColors,
                          width: 0
                      )                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Appcolor.greyColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Appcolor.secondaryColor,
                      )
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),

                ),
              ),
              const SizedBox(height: 15),
              Text("New password",style: TextStyle(color: Colors.black),),
              const SizedBox(height: 5),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,

                decoration: InputDecoration(
                  hintText: "New password",
                  filled: true,
                  fillColor: Colors.white,
                  // const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  contentPadding: EdgeInsets.all(8),

                  // 👇 NORMAL BORDER
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isPasswordWrong ? Colors.red : Appcolor.greyColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Appcolor.greyColor,
                    ),
                  ),
                  // 👇 FOCUSED BORDER
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isPasswordWrong
                          ? Colors.red
                          :  Appcolor.secondaryColor,// ya Appcolor.secondaryColor
                    ),
                  ),

                  // 👁️ TOGGLE ICON
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible1
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible1 = !isPasswordVisible1;
                      });
                    },
                  ),
                ),
              ),

              const Spacer(),
              PrimaryButton(
                text: 'Create new password',
                onPressed: isEnabled ? _handleLogin : null,
                isDisabled: !isEnabled,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
