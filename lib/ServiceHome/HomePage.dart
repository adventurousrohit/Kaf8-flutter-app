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
import '../driverHome/call_screen.dart';

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

// ── Fallback vehicle items now use local PNG assets ─────────────────────────
const List<_VehicleItem> _fallbackVehicleItems = [
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-bicycle',
      name: 'Bicycle',
      icon: 'assets/images/vehicles/icon_bicycle.png',
      baseCost: 8,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-motorcycle',
      name: 'Motorcycle',
      icon: 'assets/images/shared/scooter.png',
      baseCost: 15,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-scooter',
      name: 'Scooter',
      icon: 'assets/images/vehicles/icon_scooter_blue.png',
      baseCost: 12,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-car',
      name: 'Car',
      icon: 'assets/images/vehicles/icon_car.png',
      baseCost: 25,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-van',
      name: 'Van',
      icon: 'assets/images/vehicles/icon_van.png',
      baseCost: 35,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-minibus',
      name: 'MiniBus',
      icon: 'assets/images/vehicles/icon_minibus.png',
      baseCost: 50,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-truck',
      name: 'Truck',
      icon: 'assets/images/vehicles/icon_truck.png',
      baseCost: 60,
      description: '',
    ),
  ),
  _VehicleItem(
    VehicleTypeModel(
      id: 'fallback-breakdown',
      name: 'Breakdown Vehicle',
      icon: 'assets/images/vehicles/icon_breakdown_vehicle.png',
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

  // Filter state
  double _minRating = 0.0;
  bool _onlyOnline = false;

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
        .map((e) {
      final model = VehicleTypeModel.fromJson(Map<String, dynamic>.from(e));
      // Map icon strings (emojis or old names) to local PNG assets from assets/icons/
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
      } else if (iconPath.contains('🚌') ||
          name.contains('minibus') ||
          name.contains('mini bus')) {
        iconPath = 'assets/icons/ic_mini_bus.png';
      } else if (iconPath.contains('🚛') || name.contains('truck')) {
        iconPath = 'assets/icons/ic_truck.png';
      } else if (iconPath.contains('🚜') || name.contains('breakdown')) {
        iconPath = 'assets/icons/ic_breakdown_vehicle.png';
      }

      return _VehicleItem(VehicleTypeModel(
        id: model.id,
        name: model.name,
        icon: iconPath,
        baseCost: model.baseCost,
        description: model.description,
      ));
    })
        .where((v) => v.model.id.isNotEmpty && v.model.name.isNotEmpty)
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
    _filterDrivers();
  }

  void _filterDrivers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _nearbyDrivers = _originalNearbyDrivers.where((d) {
        final matchesSearch = d.fullName.toLowerCase().contains(query);
        final matchesRating = d.rating >= _minRating;
        final matchesOnline = !_onlyOnline || d.isOnline;
        return matchesSearch && matchesRating && matchesOnline;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Filter Carriers",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Online only toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Show online carriers only",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Switch(
                        value: _onlyOnline,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setModalState(() => _onlyOnline = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Rating slider
                  Text(
                    "Minimum Rating: ${_minRating.toStringAsFixed(1)}",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    activeColor: Colors.green,
                    label: _minRating.toStringAsFixed(1),
                    onChanged: (val) {
                      setModalState(() => _minRating = val);
                    },
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        _filterDrivers();
                        Get.back();
                      },
                      child: Text(
                        "Apply Filters",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setModalState(() {
                          _minRating = 0.0;
                          _onlyOnline = false;
                        });
                        _filterDrivers();
                        Get.back();
                      },
                      child: Text(
                        "Reset All",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.18),
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
                opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.15),
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── HEADER ──────────────────────────────────────────
                _buildHeader(fontScale, theme),
                // ── SEARCH BAR ──────────────────────────────────────
                _buildSearchBar(fontScale, theme),
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
                          _buildPermissionCards(theme),
                        _buildBanner(size, fontScale, isDark),
                        const SizedBox(height: 8),
                        _buildPageDots(isDark),
                        const SizedBox(height: 18),
                        _buildVehicleGrid(fontScale, isDark),
                        const SizedBox(height: 18),
                        _buildSectionHeader("Carriers near me", fontScale, theme),
                        const SizedBox(height: 12),
                        _buildDriverCards(theme),
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
  Widget _buildHeader(double fontScale, ThemeData theme) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
            size: 22,
          ),
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
                    Icon(Icons.chevron_right, size: 14, color: Colors.grey[600]),
                  ],
                ),
                Text(
                  _currentAddress,
                  style: GoogleFonts.inter(
                    fontSize: 15 * fontScale,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Get.to(() => NotificationPage()),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
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
  Widget _buildSearchBar(double fontScale, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
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
                style: GoogleFonts.inter(
                  fontSize: 14 * fontScale,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: "Search here",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14 * fontScale,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
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
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.cardColor,
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
  Widget _buildBanner(Size size, double fontScale, bool isDark) {
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
  Widget _buildPageDots(bool isDark) {
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
            color: active
                ? Colors.green
                : (isDark ? Colors.grey[700] : Colors.grey[350]),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Vehicle grid ───────────────────────────────────────────────────────────
  Widget _buildVehicleGrid(double fontScale, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _vehicleItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final item = _vehicleItems[index];
          return GestureDetector(
            onTap: () => Get.to(() => homeorder(selectedVehicle: item.model)),
            child: _VehicleCell(
              item: item,
              fontScale: fontScale,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, double fontScale, ThemeData theme) {
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
                color: theme.textTheme.titleLarge?.color,
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
  Widget _buildDriverCards(ThemeData theme) {
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

  Widget _buildPermissionCards(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        children: [
          if (_locationPermissionDenied)
            _permissionCard(
              theme: theme,
              icon: Icons.location_off,
              text: "Location access is needed for accurate nearby carriers.",
              button: "Enable",
              onTap: _openLocationSettings,
            ),
          if (_notificationPermissionDenied)
            _permissionCard(
              theme: theme,
              icon: Icons.notifications_off,
              text: "Enable notifications to receive booking updates instantly.",
              button: "Allow",
              onTap: _openNotificationSettings,
            ),
        ],
      ),
    );
  }

  Widget _permissionCard({
    required ThemeData theme,
    required IconData icon,
    required String text,
    required String button,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
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
// VEHICLE CELL
// Large rounded-square card with PNG asset icon + label below.
// Matches the screenshot style exactly.
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleCell extends StatelessWidget {
  final _VehicleItem item;
  final double fontScale;
  final bool isDark;

  const _VehicleCell({
    required this.item,
    required this.fontScale,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF252525) : Colors.white;
    // Soft blue-tinted shadow in light mode (matches screenshot); darker shadow in dark mode
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.35)
        : const Color(0xFF90CAF9).withOpacity(0.30);

    final displayName = item.model.name == 'Breakdown Vehicle'
        ? 'Breakdown\nVehicle'
        : item.model.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Card ────────────────────────────────────────────────────
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 14,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset(
                item.model.icon,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.directions_car_outlined,
                  size: 32,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ── Label ───────────────────────────────────────────────────
        Text(
          displayName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFEAEAEA) : const Color(0xFF1A1A1A),
            height: 1.25,
          ),
        ),
      ],
    );
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
    Get.to(() => CallScreen(
          name: widget.driver.fullName,
          avatarUrl: widget.driver.avatarUrl.isNotEmpty
              ? widget.driver.avatarUrl
              : 'https://randomuser.me/api/portraits/men/33.jpg',
          duration: 'Calling...',
        ));
  }

  void _openQuickActions() {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  widget.driver.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isDark ? Colors.white70 : null,
                ),
                title: Text(
                  widget.driver.isFavorite
                      ? "Remove from favourites"
                      : "Add to favourites",
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87),
                ),
                onTap: () {
                  Get.back();
                  _toggleFavorite();
                },
              ),
              ListTile(
                leading: Icon(Icons.call,
                    color: isDark ? Colors.white70 : null),
                title: Text("Call carrier",
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Get.back();
                  _makePhoneCall();
                },
              ),
              ListTile(
                leading: Icon(Icons.person_outline,
                    color: isDark ? Colors.white70 : null),
                title: Text("View profile",
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87)),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: _openQuickActions,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor, width: 1.5),
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
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
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
                          : Colors.grey.withOpacity(0.3),
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
                          border: Border.all(
                              color: theme.cardColor, width: 1.5),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 11, color: Colors.grey),
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
                          const Icon(Icons.star,
                              size: 13, color: Colors.orange),
                          const SizedBox(width: 3),
                          Text(
                            "${widget.driver.rating.toStringAsFixed(1)} (${widget.driver.reviewCount})",
                            style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodyMedium?.color),
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
                GestureDetector(
                  onTap: _makePhoneCall,
                  child: _actionBtn(Icons.call),
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