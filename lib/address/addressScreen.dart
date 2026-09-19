import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';
import '../Utils/responsiveUtils.dart';
import 'AddAddressScreen.dart';

class AddressScreens extends StatefulWidget {
  const AddressScreens({super.key});

  @override
  State<AddressScreens> createState() => _AddressScreensState();
}

class _AddressScreensState extends State<AddressScreens> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getAddresses();
    if (!mounted) return;
    final data = response['data'];
    if (response['success'] == true && data is List) {
      _addresses = data.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      final defaultIndex = _addresses.indexWhere((a) => a['isDefault'] == true);
      _selectedIndex = defaultIndex >= 0 ? defaultIndex : 0;
    } else {
      _addresses = [];
      Get.snackbar("Error", response['message']?.toString() ?? "Failed to load addresses");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _setDefault(int index) async {
    final id = _addresses[index]['id']?.toString();
    if (id == null) return;
    final response = await ApiService.setDefaultAddress(id);
    if (response['success'] == true) {
      await _loadAddresses();
    } else {
      Get.snackbar("Error", response['message']?.toString() ?? "Failed to update default address");
    }
  }

  Future<void> _delete(int index) async {
    final id = _addresses[index]['id']?.toString();
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete address"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    final response = await ApiService.deleteAddress(id);
    if (response['success'] == true) {
      await _loadAddresses();
    } else {
      Get.snackbar("Error", response['message']?.toString() ?? "Failed to delete");
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Top-left geometric background ──────────────────────────
          Positioned(
            top: 0, left: 0,
            child: Image.asset(
              'assets/images/bg_top_left.png',
              width: size.width * 0.62,
              fit: BoxFit.contain,
              opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.20),
            ),
          ),
          // ── Top-right ──────────────────────────────────────────────
          Positioned(
            top: 0, right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.36,
                fit: BoxFit.contain,
                opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.13),
              ),
            ),
          ),
          // ── Bottom-right ───────────────────────────────────────────
          Positioned(
            bottom: 0, right: 0,
            child: Image.asset(
              'assets/images/bg_bottom_right.png',
              width: size.width * 0.50,
              fit: BoxFit.contain,
              opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.25),
            ),
          ),

          // ── Main content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Circle back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isDark ? Colors.white24 : Colors.grey[800]!, width: 1.8),
                          ),
                          child: Icon(Icons.arrow_back_ios_new,
                              size: 15, color: theme.iconTheme.color),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Address",
                        style: GoogleFonts.inter(
                          fontSize: 17 * fontScale,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      // Plus button
                      GestureDetector(
                        onTap: () async {
                          await Get.to(() => const AddAddressScreen());
                          _loadAddresses();
                        },
                        child: Icon(Icons.add,
                            size: 24, color: theme.iconTheme.color),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Address list ─────────────────────────────────────
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _addresses.isEmpty
                          ? Center(child: Text("No addresses yet", style: TextStyle(color: theme.textTheme.bodyMedium?.color)))
                          : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final addr = _addresses[index];
                      final bool selected = _selectedIndex == index;

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: text + Change button
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (addr['label'] ?? "Saved Address").toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 16 * fontScale,
                                        fontWeight: FontWeight.w700,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (addr['city'] ?? "").toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 13 * fontScale,
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${addr['detailAddress'] ?? ''}${(addr['country'] != null) ? ', ${addr['country']}' : ''}",
                                      style: GoogleFonts.inter(
                                        fontSize: 13 * fontScale,
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _setDefault(index),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 7),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text("Set default",
                                              style: GoogleFonts.inter(
                                                fontSize: 13 * fontScale,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () => _delete(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                                            ),
                                            child: Icon(Icons.delete_outline,
                                                size: 18, color: Colors.red.shade400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Right: radio / checkmark
                              selected
                                  ? Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    size: 14, color: Colors.white),
                              )
                                  : Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: isDark ? Colors.white24 : Colors.grey[400]!,
                                      width: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}