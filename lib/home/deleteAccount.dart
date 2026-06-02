import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Utils/appColor.dart';
import '../Utils/appImage.dart';
import '../Utils/primaryButtion.dart';
import '../Utils/responsiveUtils.dart';


class Deleteaccount extends StatefulWidget {
  const Deleteaccount({super.key});

  @override
  State<Deleteaccount> createState() => _DeleteaccountState();
}

class _DeleteaccountState extends State<Deleteaccount> {
  @override
  final TextEditingController emailController = TextEditingController();

  /// ✅ Login Function
  // void _handleLogin() {
  //   print("Login Clicked");
  // }
  bool isPasswordVisible = true;
  bool isPasswordWrong = false;
  void _handleLogin() {

  }
  @override
  void initState() {
    super.initState();

    emailController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveUtils.componentScale(context);
    final padding = ResponsiveUtils.paddingScale(context) * 16;
    final fontScale = ResponsiveUtils.fontScale(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                  ),
                  const Spacer(),
                  Image.asset(
                    Assets.imagesLogo,
                    height: 50 * scale,
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "You are going to delete your account.",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "We are very sorry to see you leaving. Deleting your account will permanently delete all of the data plus any active subscriptions and this action can’t be undone!"
                    "\nIf you still want to delete your account, enter “CONFIRM” to proceed.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 30),
              // Text("Email",style: TextStyle(color: Colors.black),),
              // const SizedBox(height: 5),
              TextField(
                controller: emailController, // ✅ attach
                style: GoogleFonts.inter(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: "Enter \"CONFIRM\"",
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.all(8),

                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.dividerColor,
                          width: 0
                      )                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Appcolor.secondaryColor,
                      )
                  ),
                ),
              ),


              const Spacer(),
              PrimaryButton(
                text: 'Delete account',
                onPressed: (){

                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}