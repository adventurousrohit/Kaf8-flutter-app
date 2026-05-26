import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaf8/Utils/appColor.dart';

import '../Help/favoritelist.dart';
import '../Help/notification.dart';
import '../Service/location_service.dart';
import '../ServiceHome/call.dart';
import '../Utils/VehicleTypeGrid.dart';
import '../Utils/responsiveUtils.dart';
import '../home/homeorder.dart';
import '../profile/myProfile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

enum VehicleType { bike, scooter, car, van, truck, pickup, minibus, lorry, bicycle }

class UserModel {
  final String uid;
  final String fullName;
  final bool isOnline;
  final double rating;
  final int reviewCount;
  final String location;
  final List<VehicleType> vehicleTypes;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.isOnline,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.vehicleTypes,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// VEHICLE GRID DATA
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleItem {
  final String emoji;
  final String label;
  const _VehicleItem(this.emoji, this.label);
}

const List<_VehicleItem> _vehicleItems = [
  _VehicleItem('🚲', 'Bicycle'),
  _VehicleItem('🏍️', 'Motorcycle'),
  _VehicleItem('🛵', 'Scooter'),
  _VehicleItem('🚗', 'Car'),
  _VehicleItem('🚚', 'Van'),
  _VehicleItem('🚌', 'MiniBus'),
  _VehicleItem('🚛', 'Truck'),
  _VehicleItem('🚜', 'Breakdown\nVehicle'),
];

// ─────────────────────────────────────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  int _currentBannerIndex = 0;
  String _currentAddress = 'Embassy of the USA';

  List<UserModel> _nearbyDrivers = [];
  List<UserModel> _originalNearbyDrivers = [];

  bool showReviews = false;

  @override
  void initState() {
    super.initState();
    _loadStaticDrivers();
    _fetchCurrentLocation();
    _searchController.addListener(() => _performSearch(_searchController.text));
  }

  void _fetchCurrentLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      final address = await LocationService.getAddressFromLatLng(position);
      if (address != null) {
        setState(() {
          _currentAddress = address;
        });
      }
    }
  }

  void _loadStaticDrivers() {
    final drivers = [
      UserModel(uid: "1", fullName: "Rohit Sharma",  isOnline: true,  rating: 4.5, reviewCount: 120, location: "Jaipur",  vehicleTypes: [VehicleType.bike,  VehicleType.scooter]),
      UserModel(uid: "2", fullName: "Amit Singh",    isOnline: false, rating: 4.2, reviewCount: 80,  location: "Delhi",   vehicleTypes: [VehicleType.car,   VehicleType.van]),
      UserModel(uid: "3", fullName: "Suresh Kumar",  isOnline: true,  rating: 4.8, reviewCount: 200, location: "Mumbai",  vehicleTypes: [VehicleType.truck, VehicleType.pickup]),
    ];
    setState(() {
      _originalNearbyDrivers = drivers;
      _nearbyDrivers = drivers;
    });
  }

  void _performSearch(String query) {
    setState(() {
      _nearbyDrivers = query.isEmpty
          ? _originalNearbyDrivers
          : _originalNearbyDrivers
          .where((d) => d.fullName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _applyFilter(double minRating) {
    setState(() {
      _nearbyDrivers = _originalNearbyDrivers
          .where((d) => d.rating >= minRating)
          .toList();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> _banners = [
    {'title': 'The Best Delivery\nService.', 'sub': 'Make it your own 🚚'},
    {'title': 'Trusted Drivers\nNearby.',    'sub': 'Reliable every time 🏍️'},
    {'title': 'Best Service\nGuaranteed.',   'sub': 'On time, every time 📦'},
  ];

  @override
  Widget build(BuildContext context) {
    final scale     = ResponsiveUtils.componentScale(context);
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Stack(
        children: [
          // ── Top-left geometric background ──────────────────────────
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/bg_top_left.png',
              width: size.width * 0.60,
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              opacity: const AlwaysStoppedAnimation(0.18),
            ),
          ),

          // ── Top-right corner (flip the same asset) ─────────────────
          Positioned(
            top: 0,
            right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                'assets/images/bg_bottom_right.png',
                width: size.width * 0.38,
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
                opacity: const AlwaysStoppedAnimation(0.15),
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── HEADER ──────────────────────────────────────────
                _buildHeader(fontScale),
                // ── SEARCH BAR ──────────────────────────────────────
                _buildSearchBar(fontScale),
                const SizedBox(height: 12),

                // ── SCROLLABLE BODY ──────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildBanner(size, fontScale),
                      const SizedBox(height: 8),
                      _buildPageDots(),
                      const SizedBox(height: 18),
                      _buildVehicleGrid(fontScale),
                      const SizedBox(height: 18),
                      _buildSectionHeader("Carriers near me", fontScale),
                      const SizedBox(height: 12),
                      _buildDriverCards(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(double fontScale) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.black54, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Your location",
                        style: GoogleFonts.inter(
                            fontSize: 12 * fontScale,
                            color: Colors.grey[600])),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 14, color: Colors.grey[600]),
                  ],
                ),
                Text(
                  _currentAddress,
                  style: GoogleFonts.inter(
                      fontSize: 15 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Bell with dot
          GestureDetector(
            onTap: () => Get.to(() => NotificationPage()),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none,
                    size: 28, color: Colors.black87),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // User avatar
          GestureDetector(
            onTap: () => Get.to(() => const MyProfileScreen()),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                  "https://randomuser.me/api/portraits/men/32.jpg"),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar(double fontScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                decoration: InputDecoration(
                  hintText: "Search here",
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14 * fontScale, color: Colors.grey[400]),
                  prefixIcon:
                  Icon(Icons.search, color: Colors.grey[400], size: 20),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          GestureDetector(
            onTap: () => _applyFilter(4.5),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(Icons.tune, size: 20, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────────
  Widget _buildBanner(Size size, double fontScale) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _banners.length,
        onPageChanged: (i) => setState(() => _currentBannerIndex = i),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Green left section
                Positioned(
                  left: 0, top: 0, bottom: 0,
                  width: size.width * 0.52,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2ECC40), Color(0xFF27AE60)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _banners[index]['title']!,
                          style: GoogleFonts.inter(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            height: 1.25,
                          ),
                        ),
                        Text(
                          _banners[index]['sub']!,
                          style: GoogleFonts.inter(
                              fontSize: 12 * fontScale,
                              color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right dark section
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  width: size.width * 0.42,
                  child: Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Text("🚀\n🧑‍🦱\n🛵",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Page dots ──────────────────────────────────────────────────────────────
  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_banners.length, (i) {
        final bool active = i == _currentBannerIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width:  active ? 24 : 8,
          height: 5,
          decoration: BoxDecoration(
            color: active ? Colors.green : Colors.grey[350],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Vehicle grid ───────────────────────────────────────────────────────────
  Widget _buildVehicleGrid(double fontScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _vehicleItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.80,
        ),
        itemBuilder: (context, index) {
          final item = _vehicleItems[index];
          return GestureDetector(
            onTap: () => Get.to(() => homeorder()),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(item.emoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11 * fontScale,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, double fontScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 17 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
                overflow: TextOverflow.ellipsis),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600]),
        ],
      ),
    );
  }

  // ── Driver cards ───────────────────────────────────────────────────────────
  Widget _buildDriverCards() {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: 3,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(right: 14),
          child: _DriverCard(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRIVER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _DriverCard extends StatefulWidget {
  const _DriverCard();

  @override
  State<_DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<_DriverCard> {
  int _selectedVehicle = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Text("Delivery Driver",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.to(() => FavoriteList()),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Profile row
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                    "https://randomuser.me/api/portraits/men/45.jpg"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Wade Warren",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 3),
                    Row(
                      children: const [
                        Icon(Icons.location_on, size: 11, color: Colors.grey),
                        SizedBox(width: 3),
                        Expanded(
                          child: Text("123 Main St, Apt 4B, City, State",
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: const [
                        Icon(Icons.star, size: 13, color: Colors.orange),
                        SizedBox(width: 3),
                        Text("4.8 (1.2k)",
                            style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                children: [
                  _actionBtn(Icons.graphic_eq),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Get.to(() => CallScreen()),
                    child: _actionBtn(Icons.call),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text("Delivery Vehicles",
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 8),

          // Vehicle options with radio
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedVehicle = 0),
                  child: _VehicleOption(
                      emoji: '🏍️',
                      label: 'Motorbike',
                      isSelected: _selectedVehicle == 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedVehicle = 1),
                  child: _VehicleOption(
                      emoji: '🚛',
                      label: 'Lorry',
                      isSelected: _selectedVehicle == 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon) => Container(
    padding: const EdgeInsets.all(7),
    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    child: Icon(icon, size: 14, color: Colors.white),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// VEHICLE OPTION (radio style)
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleOption extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;

  const _VehicleOption({
    required this.emoji,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ),
          // Radio circle
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey.shade400,
                width: 1.5,
              ),
            ),
            child: isSelected
                ? Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
              ),
            )
                : null,
          ),
        ],
      ),
    );
  }
}