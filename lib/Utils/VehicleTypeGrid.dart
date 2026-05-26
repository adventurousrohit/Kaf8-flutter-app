// lib/customer_domain/home/widgets/vehicle_type_grid.dart

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:kaf8/Utils/responsiveUtils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/homeorder.dart';
import 'appColor.dart';
import 'appImage.dart';

class VehicleTypeGrid extends StatelessWidget {
  final double scale;
  final double fontScale;
  final Function(String) onVehicleTypeTap;

  VehicleTypeGrid({
    super.key,
    required this.scale,
    required this.fontScale,
    required this.onVehicleTypeTap,
  });

  final List<Map<String, dynamic>> _vehicleTypes = [
    {'icon': VehicleIcons.bicycle, 'label': 'Bicycle'},
    {'icon': VehicleIcons.motorcycle, 'label': 'Motorcycle'},
    {'icon': VehicleIcons.scooterBlue, 'label': 'Scooter'},
    {'icon': VehicleIcons.car, 'label': 'Car'},
    {'icon': VehicleIcons.van, 'label': 'Van'},
    {'icon': VehicleIcons.minibus, 'label': 'MiniBus'},
    {'icon': VehicleIcons.truck, 'label': 'Truck'},
    {'icon': VehicleIcons.breakdownVehicle, 'label': 'Breakdown\nVehicle'},
  ];

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.paddingScale(context) * 16;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12 * scale,
          mainAxisSpacing: 12 * scale,
          childAspectRatio: 0.85,
        ),
        itemCount: _vehicleTypes.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicleTypes[index];
          return InkWell(
            onTap: () {
              onVehicleTypeTap(vehicle['label']);
              Get.to(homeorder());
            },
            child: _buildVehicleTypeCard(
              icon: vehicle['icon'],
              label: vehicle['label'],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleTypeCard({required String icon, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: Appcolor.whiteColor,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, width: 50 * scale, height: 50 * scale),
          SizedBox(height: 10 * scale),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13 * fontScale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F1F1F),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
