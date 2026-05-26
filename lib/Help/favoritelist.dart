import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/responsiveUtils.dart';

class FavoriteList extends StatefulWidget {
  const FavoriteList({super.key});
  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  // Per-card selected vehicle: 0=Motorbike, 1=Lorry
  final Map<int, int> _selectedVehicle = {0: 0, 1: 0, 2: 0, 3: 0};

  final List<Map<String, String>> _drivers = List.generate(4, (_) => {
    'name': 'Wade Warren',
    'location': '123 Main St, Apt 4B, City, State',
    'rating': '4.8',
    'reviews': '1.2k',
  });

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // ── Background shapes ──────────────────────────────────────
          Positioned(top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.62, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.20))),
          Positioned(top: 0, right: 0,
              child: Transform(alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.36, fit: BoxFit.contain,
                      opacity: const AlwaysStoppedAnimation(0.13)))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.55, fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.30))),
          Positioned(bottom: 0, left: 0,
              child: Transform(alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.32, fit: BoxFit.contain,
                      opacity: const AlwaysStoppedAnimation(0.14)))),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey[800]!, width: 1.8)),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 15, color: Colors.black),
                        ),
                      ),
                      const Spacer(),
                      Text("Favourite List",
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Card list ────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    itemCount: _drivers.length,
                    itemBuilder: (_, i) => _buildCard(i, fontScale),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index, double fontScale) {
    final driver = _drivers[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: label + heart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Delivery Driver",
                  style: GoogleFonts.inter(
                      fontSize: 11 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.favorite,
                    size: 14, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Profile row
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                    "https://randomuser.me/api/portraits/men/45.jpg"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver['name']!,
                        style: GoogleFonts.inter(
                            fontSize: 15 * fontScale,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on,
                          size: 10, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(driver['location']!,
                            style: GoogleFonts.inter(
                                fontSize: 9 * fontScale,
                                color: Colors.grey),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(driver['rating']!,
                          style: GoogleFonts.inter(
                              fontSize: 11 * fontScale,
                              fontWeight: FontWeight.w600)),
                      Text(" (${driver['reviews']!})",
                          style: GoogleFonts.inter(
                              fontSize: 10 * fontScale,
                              color: Colors.grey[400])),
                    ]),
                  ],
                ),
              ),
              Row(children: [
                _greenBtn(Icons.graphic_eq),
                const SizedBox(width: 8),
                _greenBtn(Icons.call),
              ]),
            ],
          ),

          const SizedBox(height: 12),

          Text("Delivery Vehicles",
              style: GoogleFonts.inter(
                  fontSize: 12 * fontScale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),

          const SizedBox(height: 8),

          // Vehicle boxes
          Row(
            children: [
              Expanded(child: GestureDetector(
                  onTap: () => setState(() => _selectedVehicle[index] = 0),
                  child: _vehicleBox(
                      emoji: '🏍️', label: 'Motorbike',
                      isSelected: _selectedVehicle[index] == 0,
                      fontScale: fontScale))),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                  onTap: () => setState(() => _selectedVehicle[index] = 1),
                  child: _vehicleBox(
                      emoji: '🚛', label: 'Lorry',
                      isSelected: _selectedVehicle[index] == 1,
                      fontScale: fontScale))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _greenBtn(IconData icon) => Container(
    width: 34, height: 34,
    decoration: const BoxDecoration(
        color: Colors.green, shape: BoxShape.circle),
    child: Icon(icon, size: 16, color: Colors.white),
  );

  Widget _vehicleBox({
    required String emoji,
    required String label,
    required bool isSelected,
    required double fontScale,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          // Blue border on selected vehicle box — matches screenshot
          color: isSelected
              ? const Color(0xFF2979FF)
              : Colors.grey.shade200,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4)],
      ),
      child: Stack(
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          // Radio circle top-right
          Positioned(
            top: 0, right: 0,
            child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.green : Colors.white,
                  border: Border.all(
                      color: isSelected
                          ? Colors.green
                          : Colors.grey.shade400,
                      width: 1.5)),
              child: isSelected
                  ? const Icon(Icons.check, size: 9, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}