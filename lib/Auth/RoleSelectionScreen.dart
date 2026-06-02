import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kaf8/Auth/loginScreen.dart';

import '../Utils/appImage.dart';
import '../Utils/primaryButtion.dart';
import '../Utils/responsiveUtils.dart';
import '../Utils/role.dart';
import 'customerstartingscreen.dart';


class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {

  // ✅ LOCAL STATE
  String selectedRole = '';

  void _handleNavigation() {
    if (selectedRole == 'customer') {
     Get.to(() => GetStartedScreen(role: selectedRole));
    } else if (selectedRole == 'driver') {
      Get.to(() => LoginScreen(role: selectedRole));
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.paddingScale(context) * 16;
    final fontScale = ResponsiveUtils.fontScale(context);
    final spacing = ResponsiveUtils.spacingScale(context) * 16;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Text(
                'Choose how you want to use our platform:',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),

              const SizedBox(height: 40),

              /// ✅ CUSTOMER
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRole = 'customer';
                  });
                },
                child: RoleCard(
                  title: 'Looking for Transportation',
                  subtitle:
                  'Easily find transporters for your shipments.',
                  imagePath: Assets.imagesAuthRoleCustomer,
                  isSelected: selectedRole == 'customer',
                ),
              ),

              SizedBox(height: spacing),

              /// ✅ DRIVER
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRole = 'driver';
                  });
                },
                child: RoleCard(
                  title: 'Become a Service Provider?',
                  subtitle:
                  'Join our platform as a service provider to connect with customers',
                  imagePath: Assets.imagesAuthRoleProvider,
                  isSelected: selectedRole == 'driver',
                ),
              ),

              const Spacer(),

              /// ✅ BUTTON
              PrimaryButton(
                text: 'Next',
                onPressed: selectedRole.isNotEmpty ? _handleNavigation : null,
                isDisabled: selectedRole.isEmpty,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}