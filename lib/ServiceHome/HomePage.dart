import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Controller/user_profile_controller.dart';
import '../Help/notification.dart';
import '../Service/api_service.dart';
import '../Service/fcm_service.dart';
import '../Service/location_service.dart';
import '../Service/vehicle_type_model.dart';
import '../Utils/responsiveUtils.dart';
import '../home/homeorder.dart';
import '../profile/myProfile.dart';

class UserModel {
  final String transporterId;
  final String fullName;
  final bool isOnline;
  final double rating;
  final int reviewCount;
  final String location;
  final String phone;
  final String avatarUrl;
  final double? distanceKm;
  final bool isFavorite;

  UserModel({
    required this.transporterId,
    required this.fullName,
    required this.isOnline,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.phone,
    required this.avatarUrl,
    required this.distanceKm,
    required this.isFavorite,
  });

  UserModel copyWith({bool? isFavorite}) {
    return UserModel(
      transporterId: transporterId,
      fullName: fullName,
      isOnline: isOnline,
      rating: rating,
      reviewCount: reviewCount,
      location: location,
      phone: phone,
      avatarUrl: avatarUrl,
      distanceKm: distanceKm,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class _VehicleItem {
  final VehicleTypeModel model;
  const _VehicleItem(this.model);
}

class _BannerItem {
  final String title;
  final String subtitle;
  final String imageUrl;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

const List<_BannerItem> _fallbackBanners = [
  _BannerItem(
    title: 'The Best Delivery\nService.',
    subtitle: 'Make it your own 🚚',
    imageUrl: '',
  ),
  _BannerItem(
    title: 'Trusted Drivers\nNearby.',
    subtitle: 'Reliable every time 🏍️',
    imageUrl: '',
  ),
  _BannerItem(
    title: 'Best Service\nGuaranteed.',
    subtitle: 'On time, every time 📦',
    imageUrl: '',
  ),
];

const List<_VehicleItem> _fallbackVehicleItems = [
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-bicycle',
      name: 'Bicycle',
      icon: '🚲',
      baseCost: 8,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-motorcycle',
      name: 'Motorcycle',
      icon: '🏍️',
      baseCost: 15,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-scooter',
      name: 'Scooter',
      icon: '🛵',
      baseCost: 12,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-car',
      name: 'Car',
      icon: '🚗',
      baseCost: 25,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-van',
      name: 'Van',
      icon: '🚚',
      baseCost: 35,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-minibus',
      name: 'MiniBus',
      icon: '🚌',
      baseCost: 50,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-truck',
      name: 'Truck',
      icon: '🚛',
      baseCost: 60,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-breakdown',
      name: 'Breakdown Vehicle',
      icon: '🚜',
      baseCost: 80,
      description: '',
    ),
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  final UserProfileController _profileController =
      Get.find<UserProfileController>();

  int _currentBannerIndex = 0;
  String _currentAddress = 'Fetching location...';
  Position? _userPosition;
  bool _locationPermissionDenied = false;
  bool _notificationPermissionDenied = false;

  List<UserModel> _nearbyDrivers = [];
  List<UserModel> _originalNearbyDrivers = [];
  List<_BannerItem> _banners = _fallbackBanners;
  List<_VehicleItem> _vehicleItems = _fallbackVehicleItems;
  bool _driversLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeHome();
    _searchController.addListener(() => _performSearch(_searchController.text));
  }

  Future<void> _initializeHome() async {
    await _fetchCurrentLocation();
    await Future.wait([
      _loadBanners(),
      _loadVehicleTypes(),
      _checkNotificationPermission(),
      _loadDrivers(),
    ]);
  }

  Future<void> _checkNotificationPermission() async {
    final denied = await FcmService.isNotificationPermissionDenied();
    if (!mounted) return;
    setState(() => _notificationPermissionDenied = denied);
  }

  Future<void> _fetchCurrentLocation() async {
    final result = await LocationService.getCurrentPositionWithStatus();
    if (!mounted) return;

    if (result.position != null) {
      _userPosition = result.position;
      final address = await LocationService.getAddressFromLatLng(
        result.position!,
      );
      if (!mounted) return;
      setState(() {
        _currentAddress = address ?? 'Current location';
        _locationPermissionDenied = false;
      });
      return;
    }

    final cached = await LocationService.getLastKnownPosition();
    if (!mounted) return;
    if (cached != null) {
      final address = await LocationService.getAddressFromLatLng(cached);
      if (!mounted) return;
      setState(() {
        _userPosition = cached;
        _currentAddress = address ?? 'Last known location';
      });
    } else {
      setState(() {
        _currentAddress = 'Location unavailable';
      });
    }
    setState(() {
      _locationPermissionDenied =
          result.status == LocationAccessStatus.denied ||
          result.status == LocationAccessStatus.deniedForever ||
          result.status == LocationAccessStatus.serviceDisabled;
    });
  }

  Future<void> _loadBanners() async {
    final result = await ApiService.getBanners();
    if (!mounted) return;
    if (result['success'] != true || result['data'] is! List) return;

    final parsed = (result['data'] as List)
        .whereType<Map>()
        .map(
          (item) => _BannerItem(
            title: '${item['title'] ?? ''}',
            subtitle: '${item['subtitle'] ?? ''}',
            imageUrl: '${item['imageUrl'] ?? ''}',
          ),
        )
        .where((b) => b.title.isNotEmpty)
        .toList();
    if (parsed.isEmpty) return;
    setState(() {
      _banners = parsed;
      _currentBannerIndex = 0;
    });
  }

  Future<void> _loadVehicleTypes() async {
    final result = await ApiService.getVehicleTypes();
    if (!mounted) return;
    if (result['success'] != true || result['data'] is! List) return;
    final parsed = (result['data'] as List)
        .whereType<Map>()
        .map((e) => VehicleTypeModel.fromJson(Map<String, dynamic>.from(e)))
        .where((v) => v.id.isNotEmpty && v.name.isNotEmpty)
        .map((v) => _VehicleItem(v))
        .toList();
    if (parsed.isEmpty) return;
    setState(() => _vehicleItems = parsed);
  }

  Future<void> _loadDrivers() async {
    if (!mounted) return;
    setState(() => _driversLoading = true);
    final result = _userPosition != null
        ? await ApiService.getNearbyTransporters(
            latitude: _userPosition!.latitude,
            longitude: _userPosition!.longitude,
            radius: 10,
          )
        : await ApiService.getTransporters(limit: 10);
    if (!mounted) return;

    List<UserModel> drivers = [];
    if (result['success'] == true) {
      final raw = result['data'];
      final list = (raw is List) ? raw : (raw is Map ? raw['data'] : null);
      if (list is List) {
        for (final t in list) {
          if (t is! Map) continue;
          final userMap = (t['User'] is Map)
              ? Map<String, dynamic>.from(t['User'])
              : <String, dynamic>{};
          final transporterId = '${t['id'] ?? ''}';
          if (transporterId.isEmpty) continue;
          final isFav = await _safeCheckFavorite(transporterId);
          drivers.add(
            UserModel(
              transporterId: transporterId,
              fullName: '${userMap['fullName'] ?? 'Driver'}',
              isOnline: t['isOnline'] == true,
              rating: double.tryParse('${t['averageRating'] ?? 0}') ?? 0,
              reviewCount: int.tryParse('${t['totalReviews'] ?? 0}') ?? 0,
              location: '${t['address'] ?? ''}',
              phone: '${userMap['phone'] ?? ''}',
              avatarUrl: '${userMap['avatar'] ?? ''}',
              distanceKm: double.tryParse('${t['distance'] ?? ''}'),
              isFavorite: isFav,
            ),
          );
        }
      }
    }

    setState(() {
      _originalNearbyDrivers = drivers;
      _nearbyDrivers = drivers;
      _driversLoading = false;
    });
  }

  Future<bool> _safeCheckFavorite(String transporterId) async {
    final check = await ApiService.checkFavorite(transporterId);
    if (check['success'] == true && check['data'] is Map) {
      return check['data']['isFavorite'] == true;
    }
    return false;
  }

  void _performSearch(String query) {
    setState(() {
      _nearbyDrivers = query.isEmpty
          ? _originalNearbyDrivers
          : _originalNearbyDrivers
                .where(
                  (d) => d.fullName.toLowerCase().contains(query.toLowerCase()),
                )
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

  Future<void> _openLocationSettings() async {
    await openAppSettings();
  }

  Future<void> _openNotificationSettings() async {
    await openAppSettings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size = MediaQuery.of(context).size;

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
                  child: RefreshIndicator(
                    color: Colors.green,
                    onRefresh: () async {
                      await Future.wait([
                        _profileController.refreshProfile(),
                        _initializeHome(),
                      ]);
                    },
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        if (_locationPermissionDenied ||
                            _notificationPermissionDenied)
                          _buildPermissionCards(),
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
                    Text(
                      "Your location",
                      style: GoogleFonts.inter(
                        fontSize: 12 * fontScale,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                Text(
                  _currentAddress,
                  style: GoogleFonts.inter(
                    fontSize: 15 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
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
                const Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: Colors.black87,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // User avatar
          GestureDetector(
            onTap: () => Get.to(() => const MyProfileScreen()),
            child: Obx(() {
              final url = _profileController.avatarUrl ?? '';
              return CircleAvatar(
                radius: 18,
                backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
                child: url.isEmpty ? const Icon(Icons.person, size: 18) : null,
              );
            }),
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(fontSize: 14 * fontScale),
                decoration: InputDecoration(
                  hintText: "Search here",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14 * fontScale,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
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
                    offset: const Offset(0, 2),
                  ),
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
                  left: 0,
                  top: 0,
                  bottom: 0,
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
                          _banners[index].title,
                          style: GoogleFonts.inter(
                            fontSize: 18 * fontScale,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            height: 1.25,
                          ),
                        ),
                        Text(
                          _banners[index].subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12 * fontScale,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right dark section
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: size.width * 0.42,
                  child: Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Text(
                        "🚀\n🧑‍🦱\n🛵",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28),
                      ),
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
          width: active ? 24 : 8,
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
            onTap: () => Get.to(() => homeorder(selectedVehicle: item.model)),
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
                      child: Text(
                        item.model.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.model.name == 'Breakdown Vehicle'
                      ? 'Breakdown\nVehicle'
                      : item.model.name,
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
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 17 * fontScale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600]),
        ],
      ),
    );
  }

  // ── Driver cards ───────────────────────────────────────────────────────────
  Widget _buildDriverCards() {
    if (_driversLoading) {
      return const SizedBox(
        height: 230,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_nearbyDrivers.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            "No carriers found nearby",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: _nearbyDrivers.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _DriverCard(
            driver: _nearbyDrivers[index],
            onFavoriteChanged: (isFavorite) {
              final id = _nearbyDrivers[index].transporterId;
              _updateDriverFavorite(id, isFavorite);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        children: [
          if (_locationPermissionDenied)
            _permissionCard(
              icon: Icons.location_off,
              text: "Location access is needed for accurate nearby carriers.",
              button: "Enable",
              onTap: _openLocationSettings,
            ),
          if (_notificationPermissionDenied)
            _permissionCard(
              icon: Icons.notifications_off,
              text:
                  "Enable notifications to receive booking updates instantly.",
              button: "Allow",
              onTap: _openNotificationSettings,
            ),
        ],
      ),
    );
  }

  Widget _permissionCard({
    required IconData icon,
    required String text,
    required String button,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
          TextButton(onPressed: onTap, child: Text(button)),
        ],
      ),
    );
  }

  void _updateDriverFavorite(String transporterId, bool isFavorite) {
    setState(() {
      _nearbyDrivers = _nearbyDrivers
          .map(
            (d) => d.transporterId == transporterId
                ? d.copyWith(isFavorite: isFavorite)
                : d,
          )
          .toList();
      _originalNearbyDrivers = _originalNearbyDrivers
          .map(
            (d) => d.transporterId == transporterId
                ? d.copyWith(isFavorite: isFavorite)
                : d,
          )
          .toList();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRIVER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _DriverCard extends StatefulWidget {
  final UserModel driver;
  final ValueChanged<bool> onFavoriteChanged;
  const _DriverCard({required this.driver, required this.onFavoriteChanged});

  @override
  State<_DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<_DriverCard> {
  bool _isFavoriteLoading = false;

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading) return;
    setState(() => _isFavoriteLoading = true);
    final res = widget.driver.isFavorite
        ? await ApiService.removeFavorite(widget.driver.transporterId)
        : await ApiService.addFavorite(widget.driver.transporterId);
    if (!mounted) return;
    setState(() => _isFavoriteLoading = false);
    if (res['success'] == true) {
      final next = !widget.driver.isFavorite;
      widget.onFavoriteChanged(next);
      Get.snackbar(
        "Favorites",
        next ? "Added to favourites" : "Removed from favourites",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Favorites",
        res['message']?.toString() ?? "Unable to update favorite",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _makePhoneCall() async {
    final phone = widget.driver.phone.trim();
    if (phone.isEmpty) {
      Get.snackbar(
        "Call",
        "No phone number available",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        "Call",
        "Unable to start phone call",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _openQuickActions() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  widget.driver.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                title: Text(
                  widget.driver.isFavorite
                      ? "Remove from favourites"
                      : "Add to favourites",
                ),
                onTap: () {
                  Get.back();
                  _toggleFavorite();
                },
              ),
              ListTile(
                leading: const Icon(Icons.call),
                title: const Text("Call carrier"),
                onTap: () {
                  Get.back();
                  _makePhoneCall();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text("View profile"),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _openQuickActions,
      child: Container(
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: widget.driver.isOnline
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.driver.isOnline ? "Online" : "Offline",
                    style: TextStyle(
                      color: widget.driver.isOnline
                          ? Colors.green
                          : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.driver.isFavorite
                          ? Colors.green
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: _isFavoriteLoading
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.6,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Profile row
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: widget.driver.avatarUrl.isNotEmpty
                          ? NetworkImage(widget.driver.avatarUrl)
                          : null,
                      child: widget.driver.avatarUrl.isEmpty
                          ? const Icon(Icons.person, size: 18)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: widget.driver.isOnline
                              ? Colors.green
                              : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driver.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 11,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              widget.driver.location.isNotEmpty
                                  ? widget.driver.location
                                  : 'Location not set',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 13,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${widget.driver.rating.toStringAsFixed(1)} (${widget.driver.reviewCount})",
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      if (widget.driver.distanceKm != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          "${widget.driver.distanceKm!.toStringAsFixed(1)} km away",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    GestureDetector(
                      onTap: _makePhoneCall,
                      child: _actionBtn(Icons.call),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon) => Container(
    padding: const EdgeInsets.all(7),
    decoration: const BoxDecoration(
      color: Colors.green,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 14, color: Colors.white),
  );
}
