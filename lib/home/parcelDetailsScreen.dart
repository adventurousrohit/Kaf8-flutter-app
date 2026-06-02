import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/Service/api_service.dart';
import 'package:kaf8/Service/location_service.dart';
import 'package:kaf8/Service/vehicle_type_model.dart';

import '../../../components/delivery_textWidget.dart';
import '../../../small-widgets/app_colors.dart';
import '../small-widgets/app_assets.dart';
import '../Controller/order_controller.dart';
import 'orderDetails.dart';
import 'paymentCheckout.dart';

class ParcelDetailsScreen extends StatefulWidget {
  final String? departureAddress;
  final String? destinationAddress;
  final VehicleTypeModel? initialVehicleType;
  const ParcelDetailsScreen({
    super.key,
    this.departureAddress,
    this.destinationAddress,
    this.initialVehicleType,
  });

  @override
  State<ParcelDetailsScreen> createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends State<ParcelDetailsScreen> {
  String selectedSize = "Small";
  String selectedType = "Goods";
  String paymentMethod = "pay_now";
  String selectedVehicleId = "";
  String _pickupAddress = "Fetching location...";
  bool _vehicleTypesLoading = false;
  List<VehicleTypeModel> _vehicleTypes = const [
    VehicleTypeModel(
      id: 'fallback-motorcycle',
      name: 'Motorcycle',
      icon: 'assets/icons/ic_motorcycle.png',
      baseCost: 15,
      description: '',
    ),
    VehicleTypeModel(
      id: 'fallback-truck',
      name: 'Truck',
      icon: 'assets/icons/ic_truck.png',
      baseCost: 40,
      description: '',
    ),
  ];

  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _receiverAddressController = TextEditingController();

  bool _isSubmitting = false;

  static const Map<String, double> _sizeCost = {
    "Small": 5.0,
    "Medium": 10.0,
    "Large": 20.0,
  };

  VehicleTypeModel? get _selectedVehicle {
    for (final vehicle in _vehicleTypes) {
      if (vehicle.id == selectedVehicleId) return vehicle;
    }
    return null;
  }

  double get _deliveryCost =>
      (_selectedVehicle?.baseCost ?? 15) + (_sizeCost[selectedSize] ?? 5.0);

  @override
  void initState() {
    super.initState();
    if (widget.departureAddress != null &&
        widget.departureAddress!.isNotEmpty) {
      _pickupAddress = widget.departureAddress!;
    } else {
      _fetchPickupLocation();
    }
    if (widget.destinationAddress != null &&
        widget.destinationAddress!.trim().isNotEmpty) {
      _receiverAddressController.text = widget.destinationAddress!.trim();
    }
    _loadVehicleTypes();
    _receiverNameController.addListener(() => setState(() {}));
    _receiverPhoneController.addListener(() => setState(() {}));
    _receiverAddressController.addListener(() => setState(() {}));
  }

  Future<void> _loadVehicleTypes() async {
    setState(() => _vehicleTypesLoading = true);
    final result = await ApiService.getVehicleTypes();
    if (!mounted) return;
    if (result['success'] == true && result['data'] is List) {
      final parsed = (result['data'] as List)
          .whereType<Map>()
          .map((e) {
            final model = VehicleTypeModel.fromJson(Map<String, dynamic>.from(e));
            String iconPath = model.icon;
            final name = model.name.toLowerCase();
            if (iconPath.contains('🚲') || name.contains('bicycle')) {
              iconPath = 'assets/icons/ic_bicycle.png';
            } else if (iconPath.contains('🏍️') || name.contains('motorcycle')) {
              iconPath = 'assets/icons/ic_motorcycle.png';
            } else if (iconPath.contains('🛵') || name.contains('scooter')) {
              iconPath = 'assets/icons/ic_scooter.png';
            } else if (iconPath.contains('🚗') || name.contains('car')) {
              iconPath = 'assets/icons/ic_car.png';
            } else if (iconPath.contains('🚚') || name.contains('van')) {
              iconPath = 'assets/icons/ic_van.png';
            } else if (iconPath.contains('🚌') || name.contains('minibus') || name.contains('mini bus')) {
              iconPath = 'assets/icons/ic_mini_bus.png';
            } else if (iconPath.contains('🚛') || name.contains('truck')) {
              iconPath = 'assets/icons/ic_truck.png';
            } else if (iconPath.contains('🚜') || name.contains('breakdown')) {
              iconPath = 'assets/icons/ic_breakdown_vehicle.png';
            }

            return VehicleTypeModel(
              id: model.id,
              name: model.name,
              icon: iconPath,
              baseCost: model.baseCost,
              description: model.description,
            );
          })
          .where((v) => v.id.isNotEmpty)
          .toList();
      if (parsed.isNotEmpty) {
        _vehicleTypes = parsed;
      }
    }
    final prefill = widget.initialVehicleType?.id;
    if (prefill != null && _vehicleTypes.any((v) => v.id == prefill)) {
      selectedVehicleId = prefill;
    } else if (selectedVehicleId.isEmpty && _vehicleTypes.isNotEmpty) {
      selectedVehicleId = _vehicleTypes.first.id;
    }
    setState(() => _vehicleTypesLoading = false);
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverAddressController.dispose();
    super.dispose();
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

  bool get _isFormValid =>
      _receiverNameController.text.trim().isNotEmpty &&
      _receiverPhoneController.text.trim().isNotEmpty &&
      _receiverAddressController.text.trim().isNotEmpty;

  void _handleConfirmOrder() async {
    if (!_isFormValid) {
      Get.snackbar(
        "Missing info",
        "Please fill in all recipient fields",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final orderController = Get.find<OrderController>();
    final result = await orderController.createOrder({
      "departureAddress": _pickupAddress,
      "receiverName": _receiverNameController.text.trim(),
      "receiverPhone": _receiverPhoneController.text.trim(),
      "receiverAddress": _receiverAddressController.text.trim(),
      "paymentMethod": paymentMethod,
      "deliveryCost": _deliveryCost,
      if (selectedVehicleId.isNotEmpty) "vehicleTypeId": selectedVehicleId,
      "notes": selectedType,
      "packages": [
        {
          "parcelType": selectedType.toLowerCase(),
          "parcelSize": selectedSize.toLowerCase(),
          "packageCost": _sizeCost[selectedSize] ?? 5.0,
        },
      ],
    });

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      final order = result['data'] as Map<String, dynamic>;
      if (paymentMethod == 'pay_now') {
        Get.to(() => PaymentCheckoutScreen(order: order));
      } else {
        Get.to(() => OrderDetailsScreen(order: order));
      }
    } else {
      Get.snackbar(
        "Error",
        result['message'] ?? "Failed to create order",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(theme),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Parcel Size",
                    style: GoogleFonts.poppins(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSizeCard(
                        "Small",
                        "0.1 kg to 1.0 kg",
                        AppAssets.box,
                        theme,
                      ),
                      _buildSizeCard(
                        "Medium",
                        "0.1 kg to 3.0 kg",
                        AppAssets.box,
                        theme,
                      ),
                      _buildSizeCard(
                        "Large",
                        "0.1 kg to 20.0 kg",
                        AppAssets.box,
                        theme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  Text(
                    "Delivery Vehicle",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      if (_vehicleTypesLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(),
                        )
                      else
                        Expanded(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _vehicleTypes
                                .map(
                                  (vehicle) => SizedBox(
                                    width:
                                        (MediaQuery.of(context).size.width -
                                            70) /
                                        2,
                                    child: _buildVehicleCard(vehicle, theme),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  Text(
                    "Choose type",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildTypeChip("Goods", theme),
                      _buildTypeChip("Medicine", theme),
                      _buildTypeChip("Cosmetics", theme),
                      _buildTypeChip("Electronic", theme),
                      _buildTypeChip("Computer", theme),
                    ],
                  ),

                  const SizedBox(height: 25),
                  Text(
                    "Payment Options",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildPaymentCard("Pay Now", "pay_now", theme),
                      const SizedBox(width: 10),
                      _buildPaymentCard(
                        "Pay after Delivery",
                        "pay_on_delivery",
                        theme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  Text(
                    "Estimated Cost",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _costRow(
                    "$selectedSize Package",
                    "€${_sizeCost[selectedSize]?.toStringAsFixed(2)}",
                    theme,
                  ),
                  _costRow(
                    _selectedVehicle?.name ?? 'Vehicle',
                    "€${(_selectedVehicle?.baseCost ?? 0).toStringAsFixed(2)}",
                    theme,
                  ),
                  _costRow(
                    "Total Cost",
                    "€${_deliveryCost.toStringAsFixed(2)}",
                    theme,
                    isTotal: true,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? const Color(0XFF46890D)
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _handleConfirmOrder,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Confirm Order",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white10 : const Color(0XFFE8EBE6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Back to home",
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Color(0XFFB6B8B6),
                          fontSize: 18,
                        ),
                      ),
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

  Widget _buildHeader(ThemeData theme) {
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
                  Icons.arrow_back_ios_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                Text(
                  " Back",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Image.asset(AppAssets.person1, width: 40, height: 40),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PICK UP FROM",
                      style: GoogleFonts.poppins(
                        color: const Color(0XFFFFFFFFBA),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      _pickupAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Recipient Information",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _headerTextField(
            "Name of Receiver",
            _receiverNameController,
            TextInputType.name,
            theme,
          ),
          const SizedBox(height: 10),
          _headerTextField(
            "Phone of Receiver",
            _receiverPhoneController,
            TextInputType.phone,
            theme,
          ),
          const SizedBox(height: 10),
          _headerTextField(
            "Delivery Address",
            _receiverAddressController,
            TextInputType.streetAddress,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _headerTextField(
    String hint,
    TextEditingController controller,
    TextInputType keyboardType,
    ThemeData theme,
  ) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSizeCard(String title, String weight, String imagePath, ThemeData theme) {
    final bool isSelected = selectedSize == title;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = title),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0XFF46890D) : theme.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.5),
                    blurRadius: 3,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked,
                color: isSelected ? const Color(0XFF46890D) : Colors.grey,
                size: 18,
              ),
            ),
            Image.asset(
              imagePath,
              height: 48.0,
              width: 48.0,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.inventory_2, size: 40),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              weight,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, ThemeData theme) {
    final bool isSelected = selectedType == label;
    return GestureDetector(
      onTap: () => setState(() => selectedType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0XFF46890D) : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(String title, String value, ThemeData theme) {
    final bool isSelected = paymentMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => paymentMethod = value),
        child: Container(
          height: 62,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? const Color(0XFF46890D)
                  : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.5),
                      blurRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked,
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
                      fontSize: 12.5,
                      color: isSelected ? theme.textTheme.bodyLarge?.color : theme.textTheme.bodyMedium?.color?.withOpacity(0.54),
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

  Widget _costRow(String label, String? price, ThemeData theme, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: DottedLine(
                direction: Axis.horizontal,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 2.0,
                dashColor: theme.dividerColor,
                dashGapLength: 2.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            price ?? '',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13.71,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleTypeModel vehicle, ThemeData theme) {
    final bool isSelected = selectedVehicleId == vehicle.id;
    return GestureDetector(
      onTap: () => setState(() => selectedVehicleId = vehicle.id),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0XFF46890D) : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.5),
                    blurRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 5,
              right: 5,
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? const Color(0XFF46890D)
                    : (theme.brightness == Brightness.dark ? Colors.white24 : Colors.grey.shade300),
                size: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _buildVehicleIcon(vehicle.icon, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BahamasTextWidget(
                      text: vehicle.name,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? theme.textTheme.bodyLarge?.color : theme.textTheme.bodyMedium?.color?.withOpacity(0.54),
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

  Widget _buildVehicleIcon(String icon, {double size = 20}) {
    if (icon.contains('assets/')) {
      return Image.asset(
        icon,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Text(icon, style: TextStyle(fontSize: size)),
      );
    }
    return Text(icon, style: TextStyle(fontSize: size));
  }
}
