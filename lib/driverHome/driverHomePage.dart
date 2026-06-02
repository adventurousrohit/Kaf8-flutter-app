import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kaf8/Auth/customerstartingscreen.dart';
import 'package:kaf8/Service/api_service.dart';
import 'package:kaf8/Controller/order_controller.dart';
import 'package:kaf8/Controller/user_profile_controller.dart';
import 'package:kaf8/Utils/avatar_widget.dart';
import 'package:kaf8/Controller/theme_controller.dart';
import 'package:kaf8/driverHome/my_profile_screen.dart';
import 'package:kaf8/driverHome/orders_screen.dart';
import 'package:kaf8/driverHome/statistics_screen.dart';

import '../Help/help.dart';
import '../setting/LanguageScreen.dart';
import 'add_vehicle_sheet.dart';
import 'notification_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VEHICLE TYPE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

String _vehicleEmoji(String? type) {
  switch (type?.toLowerCase()) {
    case 'truck':    return '🚛';
    case 'van':      return '🚚';
    case 'motorbike':return '🏍️';
    case 'bike':     return '🚲';
    case 'car':      return '🚗';
    case 'pickup':   return '🛻';
    default:         return '🚗';
  }
}

String _vehicleLabel(String? type) {
  switch (type?.toLowerCase()) {
    case 'truck':    return 'Truck';
    case 'van':      return 'Van';
    case 'motorbike':return 'Motorbike';
    case 'bike':     return 'Bicycle';
    case 'car':      return 'Car';
    case 'pickup':   return 'Pickup';
    default:         return type ?? 'Vehicle';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEW MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewItem {
  final String name;
  final String avatar;
  final double rating;
  final String time;
  final String text;
  const _ReviewItem({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.time,
    required this.text,
  });
}


// ─────────────────────────────────────────────────────────────────────────────
// DRIVER HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

enum _LocationStatus { loading, ok, serviceOff, denied, permanentlyDenied }

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  final OrderController _orderController = Get.find<OrderController>();
  final UserProfileController _profileCtrl = Get.find<UserProfileController>();

  int _currentBannerIndex = 0;
  bool _showReviews = false;

  // Online status — initialised from profile, synced to backend on toggle
  bool _isOnline = false;
  bool _isTogglingOnline = false;

  bool _isStatsLoading = false;

  List<_ReviewItem> _reviews = [];
  bool _reviewsLoading = false;

  // Location
  String _currentAddress = 'Fetching location…';
  bool _locationLoading = true;
  _LocationStatus _locationStatus = _LocationStatus.loading;

  // My vehicles
  List<Map<String, dynamic>> _myVehicles = [];
  bool _vehiclesLoading = true;

  int _newRequests = 0;
  int _activeRequests = 0;
  int _pendingRequests = 0;
  int _jobsCompleted = 0;

  // Listen to profile changes so online status stays in sync
  Worker? _profileWorker;

  final List<Map<String, String>> _banners = [
    {'title': 'Get Ready\nMove On',        'sub': 'Make it your own 🚚'},
    {'title': 'Trusted Drivers\nNearby.',  'sub': 'Reliable every time 🏍️'},
    {'title': 'Best Service\nGuaranteed.', 'sub': 'On time, every time 📦'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncOnlineFromProfile(_profileCtrl.profile.value);
    _profileWorker = ever(_profileCtrl.profile, (p) {
      if (mounted && !_isTogglingOnline) {
        setState(() => _syncOnlineFromProfile(p));
      }
    });
    _refreshStats();
    _loadReviews();
    _fetchLocation();
    _loadMyVehicles();
  }

  // Re-check location when user comes back from device Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _locationStatus != _LocationStatus.ok) {
      _fetchLocation();
    }
  }

  void _syncOnlineFromProfile(Map<String, dynamic>? p) {
    final tp = p?['TransporterProfile'];
    _isOnline = tp?['isOnline'] == true;
  }

  Future<void> _fetchLocation() async {
    setState(() { _locationLoading = true; _locationStatus = _LocationStatus.loading; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location disabled';
          _locationStatus = _LocationStatus.serviceOff;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = 'Permission denied';
            _locationStatus = _LocationStatus.denied;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Enable in Settings';
          _locationStatus = _LocationStatus.permanentlyDenied;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.thoroughfare, p.locality]
            .where((s) => s != null && s.isNotEmpty);
        setState(() {
          _currentAddress = parts.isNotEmpty
              ? parts.join(', ')
              : '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
          _locationStatus = _LocationStatus.ok;
        });
      } else {
        setState(() {
          _currentAddress = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
          _locationStatus = _LocationStatus.ok;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _currentAddress = 'Location unavailable'; _locationStatus = _LocationStatus.serviceOff; });
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _profileCtrl.refreshProfile(),
      _refreshStats(),
      _loadReviews(),
      _loadMyVehicles(),
      _fetchLocation(),
    ]);
  }

  Future<void> _loadMyVehicles() async {
    setState(() => _vehiclesLoading = true);
    final res = await ApiService.getMyVehicles();
    if (!mounted) return;

    List<Map<String, dynamic>> vehicles = [];

    if (res['success'] == true && res['data'] is List) {
      vehicles = List<Map<String, dynamic>>.from(
        (res['data'] as List).map((v) => Map<String, dynamic>.from(v as Map)),
      );
    }

    // Fallback: driver's registration vehicle lives in TransporterProfile.Vehicle
    // (set during signup via vehicleId FK, not captured by ownerId filter)
    if (vehicles.isEmpty) {
      final profileVehicle = _profileCtrl.profile.value
          ?['TransporterProfile']?['Vehicle'];
      if (profileVehicle is Map) {
        vehicles = [Map<String, dynamic>.from(profileVehicle)];
      }
    }

    setState(() { _myVehicles = vehicles; _vehiclesLoading = false; });
  }

  Future<void> _toggleOnlineStatus(bool newValue) async {
    if (newValue == false) {
      // Confirm going offline
      final confirmed = await _showGoOfflineSheet();
      if (!confirmed) return;
    }
    setState(() { _isOnline = newValue; _isTogglingOnline = true; });
    final res = await ApiService.updateOnlineStatus(newValue);
    if (!mounted) return;
    if (res['success'] != true) {
      setState(() => _isOnline = !newValue); // revert
      Get.snackbar('Error', 'Could not update status. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white);
    }
    setState(() => _isTogglingOnline = false);
  }

  Future<bool> _showGoOfflineSheet() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Icon(Icons.wifi_off_rounded, size: 48, color: isDark ? Colors.white54 : Colors.grey),
            const SizedBox(height: 12),
            Text('Go Offline?',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
            const SizedBox(height: 8),
            Text("You won't receive new delivery requests while offline.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Go Offline',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _loadReviews() async {
    setState(() => _reviewsLoading = true);
    final res = await ApiService.getMyFeedbacks();
    if (!mounted) return;
    if (res['success'] == true && res['data'] is List) {
      final list = res['data'] as List;
      _reviews = list.map((f) {
        final order = (f['Order'] is Map) ? f['Order'] as Map : {};
        final client = (order['client'] is Map) ? order['client'] as Map : {};
        final name = "${client['firstName'] ?? client['fullName'] ?? 'Customer'}";
        return _ReviewItem(
          name: name,
          avatar: 'https://randomuser.me/api/portraits/men/32.jpg',
          rating: double.tryParse("${f['overallRating'] ?? f['transporterRating'] ?? 0}") ?? 0,
          time: _formatDate("${f['createdAt'] ?? ''}"),
          text: "${f['comment'] ?? ''}",
        );
      }).toList();
    }
    setState(() => _reviewsLoading = false);
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  Future<void> _refreshStats() async {
    setState(() => _isStatsLoading = true);
    await Future.wait([
      _orderController.fetchPendingAvailable(),
      _orderController.fetchActive(),
      _orderController.fetchHistory(),
    ]);
    if (!mounted) return;
    setState(() {
      _newRequests = _orderController.availableOrders.length;
      _activeRequests = _orderController.activeOrders.length;
      _pendingRequests = _orderController.availableOrders.length;
      _jobsCompleted = _orderController.historyOrders
          .where((o) => o['statusOrder'] == 'delivered')
          .length;
      _isStatsLoading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _profileWorker?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ── Open drawer ────────────────────────────────────────────────────────────
  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Gate: require location before the driver can use the home screen
    if (_locationStatus != _LocationStatus.ok &&
        _locationStatus != _LocationStatus.loading) {
      return _buildLocationGate(context);
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,

      // ── GREEN NAVIGATION DRAWER ─────────────────────────────────────────
      drawer: _buildDrawer(context),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: RefreshIndicator(
                color: Colors.green,
                onRefresh: _onRefresh,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 12),
                    _buildBanner(size, isDark),
                    const SizedBox(height: 10),
                    _buildPageDots(theme),
                    const SizedBox(height: 18),
                    _buildStatGrid(theme),
                    const SizedBox(height: 18),
                    _buildTabBar(theme),
                    const SizedBox(height: 16),
                    _showReviews ? _buildReviewsList(theme) : _buildVehicleGrid(theme),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LOCATION GATE ──────────────────────────────────────────────────────────
  Widget _buildLocationGate(BuildContext context) {
    final isPermanent = _locationStatus == _LocationStatus.permanentlyDenied;
    final isServiceOff = _locationStatus == _LocationStatus.serviceOff;

    return Scaffold(
      backgroundColor: const Color(0xFF2ECC71),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_off_rounded,
                    size: 52, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text(
                isServiceOff ? 'GPS is Turned Off' : 'Location Permission Required',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                isServiceOff
                    ? 'Please enable your device\'s GPS so KAF8 can match you with nearby delivery requests and let customers track their orders in real time.'
                    : isPermanent
                        ? 'Location permission was permanently denied. Open app settings to grant access — it\'s required to receive orders and for customer tracking.'
                        : 'KAF8 needs your location to match you with nearby delivery requests and let customers track their orders in real time.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 15, color: Colors.white.withValues(alpha: 0.9), height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (isPermanent) {
                      await Geolocator.openAppSettings();
                    } else if (isServiceOff) {
                      await Geolocator.openLocationSettings();
                    } else {
                      await _fetchLocation();
                    }
                  },
                  icon: Icon(isPermanent || isServiceOff
                      ? Icons.settings_outlined : Icons.location_on_outlined),
                  label: Text(
                    isPermanent
                        ? 'Open Settings'
                        : isServiceOff
                            ? 'Enable GPS'
                            : 'Grant Permission',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              if (isPermanent || isServiceOff) ...[
                const SizedBox(height: 12),
                Text(
                  'Come back to the app after enabling — it will detect automatically.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── DRAWER ─────────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      width: size.width * 0.85,
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.green,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // ── Background polygon shapes ──────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _DrawerBgPainter(isDark: isDark)),
            ),

            // ── Content ───────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Driver profile header ────────────────────
                    Obx(() => Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: ClipOval(
                            child: AvatarWidget(
                              avatarUrl: _profileCtrl.avatarUrl,
                              name: _profileCtrl.displayName,
                              radius: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _profileCtrl.displayName.isNotEmpty
                                    ? _profileCtrl.displayName : 'Driver',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _profileCtrl.profile.value?['email']?.toString() ?? '',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.85)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),

                    const SizedBox(height: 28),

                    // ── Card 1: General ──────────────────────────
                    _drawerCard(theme, [
                      _drawerItem(
                        icon: Icons.person_outline,
                        label: "My profile",
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => DriverProfileScreen());
                        },
                      ),
                      _drawerDivider(theme),
                      // Online / Offline with toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _isOnline ? Colors.green : Colors.grey,
                                      width: 1.5)),
                              child: Icon(
                                  Icons.local_shipping_outlined,
                                  size: 18,
                                  color: _isOnline ? Colors.green : Colors.grey),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_isOnline ? 'Online' : 'Offline',
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: _isOnline ? Colors.green : (isDark ? Colors.white70 : Colors.grey[700]))),
                                  Text(_isOnline ? 'Receiving new orders' : 'Not receiving orders',
                                      style: GoogleFonts.inter(
                                          fontSize: 11, color: Colors.grey[500])),
                                ],
                              ),
                            ),
                            _isTogglingOnline
                                ? const SizedBox(
                                    width: 36, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green))
                                : Transform.scale(
                                    scale: 0.85,
                                    child: Switch(
                                      value: _isOnline,
                                      onChanged: _toggleOnlineStatus,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: Colors.green,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: Colors.grey[300],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      _drawerDivider(theme),
                      // Dark Mode toggle
                      Obx(() {
                        final themeCtrl = Get.find<ThemeController>();
                        final isDarkNow = themeCtrl.themeMode.value == ThemeMode.dark;
                        return _drawerToggle(
                          icon: isDarkNow ? Icons.dark_mode : Icons.light_mode_outlined,
                          label: "dark_mode".tr,
                          value: isDarkNow,
                          theme: theme,
                          onChanged: (val) => themeCtrl.toggleTheme(),
                        );
                      }),
                      _drawerDivider(theme),
                      _drawerItem(
                        icon: Icons.notifications_outlined,
                        label: "Notification",
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const DriverNotificationScreen());
                        },
                      ),
                      _drawerDivider(theme),
                      _drawerItem(
                        icon: Icons.bar_chart_outlined,
                        label: "Statistics",
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const StatisticsScreen());
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // ── Card 2: Support ──────────────────────────
                    _drawerCard(theme, [
                      _drawerItem(
                        icon: Icons.headset_mic_outlined,
                        label: "Help & Support",
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const HelpScreen());
                        },
                      ),
                      _drawerDivider(theme),
                      _drawerItem(
                        icon: Icons.language_outlined,
                        label: "Language",
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const LanguageScreen());
                        },
                      ),
                      _drawerDivider(theme),
                      _drawerItem(
                        icon: Icons.chat_bubble_outline,
                        label: "About us",
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // ── Card 3: Log out ──────────────────────────
                    _drawerCard(theme, [
                      _drawerItem(
                        icon: Icons.logout,
                        label: "Log out",
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context);
                        },
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Logout",
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Text(
            "Are you sure you want to logout from the application?",
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                Get.find<UserProfileController>().clearProfile();
                await ApiService.logout();
                Get.offAll(() => const GetStartedScreen());
              },
              child: Text(
                "Logout",
                style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Drawer card (white rounded container) ──────────────────────────────────
  Widget _drawerCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  // ── Single drawer menu item ─────────────────────────────────────────────────
  Widget _drawerItem({
    required IconData icon,
    required String label,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 1.5),
              ),
              child: Icon(icon, size: 18, color: Colors.green),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
          ],
        ),
      ),
    );
  }

  Widget _drawerDivider(ThemeData theme) => Divider(
      height: 1, thickness: 0.7, indent: 16, endIndent: 16, color: theme.dividerColor);

  Widget _drawerToggle({
    required IconData icon,
    required String label,
    required bool value,
    required ThemeData theme,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 1.5),
            ),
            child: Icon(icon, size: 18, color: Colors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          // Hamburger — opens drawer
          GestureDetector(
            onTap: _openDrawer,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6)],
              ),
              child: Icon(Icons.menu, size: 20, color: theme.iconTheme.color),
            ),
          ),
          const SizedBox(width: 10),

          // Location
          Icon(Icons.location_on,
              color: _locationLoading ? Colors.grey : Colors.green, size: 18),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: _locationLoading ? null : _fetchLocation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('Your location',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down,
                        size: 14, color: Colors.grey[600]),
                  ]),
                  _locationLoading
                      ? SizedBox(
                          height: 14,
                          width: 100,
                          child: LinearProgressIndicator(
                              color: Colors.green,
                              backgroundColor: theme.dividerColor))
                      : Text(_currentAddress,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge?.color),
                          overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),

          // Bell
          GestureDetector(
            onTap: () => Get.to(() => const DriverNotificationScreen()),
            child: Stack(
              children: [
                Icon(Icons.notifications_none,
                    size: 28, color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                Positioned(
                  right: 0, top: 0,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Avatar — real profile photo
          Obx(() => GestureDetector(
            onTap: () => Get.to(() => DriverProfileScreen()),
            child: AvatarWidget(
              avatarUrl: _profileCtrl.avatarUrl,
              name: _profileCtrl.displayName,
              radius: 18,
            ),
          )),
        ],
      ),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────────
  Widget _buildBanner(Size size, bool isDark) {
    return SizedBox(
      height: 175,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _banners.length,
        onPageChanged: (i) => setState(() => _currentBannerIndex = i),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Green left
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_banners[index]['title']!,
                            style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                height: 1.2)),
                        const SizedBox(height: 8),
                        Text(_banners[index]['sub']!,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                ),
                // Right dark
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  width: size.width * 0.44,
                  child: Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Text('🧑‍🦱\n🛵',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 36, height: 1.4)),
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
  Widget _buildPageDots(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_banners.length, (i) {
        final bool active = i == _currentBannerIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
              color: active ? Colors.green : (theme.brightness == Brightness.dark ? Colors.white24 : Colors.grey[350]),
              borderRadius: BorderRadius.circular(4)),
        );
      }),
    );
  }

  // ── Stat grid ──────────────────────────────────────────────────────────────
  Widget _buildStatGrid(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isStatsLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(color: Colors.green),
            ),
          Text('My Orders',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard(
                '$_newRequests', 'New Requests', const Color(0xFF6C63FF))),
            const SizedBox(width: 12),
            Expanded(child: _statCard(
                '$_activeRequests', 'Active Requests', const Color(0xFF6C63FF))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard(
                '$_pendingRequests', 'Pending Requests', const Color(0xFF6C63FF))),
            const SizedBox(width: 12),
            Expanded(child: _statCard(
                '$_jobsCompleted', 'Jobs Completed', const Color(0xFF6C63FF))),
          ]),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return GestureDetector(
      onTap: () => Get.to(() => DriverOrdersScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85))),
          ],
        ),
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _tabBtn('My Vehicles', !_showReviews, theme),
        const SizedBox(width: 12),
        _tabBtn('Reviews', _showReviews, theme),
      ]),
    );
  }

  Widget _tabBtn(String label, bool active, ThemeData theme) {
    return GestureDetector(
      onTap: () => setState(() => _showReviews = label == 'Reviews'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
            color: active ? Colors.green : theme.cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: active ? Colors.green : theme.dividerColor, width: 1)),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
      ),
    );
  }

  // ── Add vehicle sheet ───────────────────────────────────────────────────────
  Future<void> _openAddVehicleSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFF7F7F7),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const AddVehicleSheet(),
    );
    if (result != null) _loadMyVehicles();
  }

  Future<void> _showVehicleOptions(Map<String, dynamic> vehicle) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final id = vehicle['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final isLast = _myVehicles.length <= 1;
    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(children: [
              Text(_vehicleEmoji(vehicle['type']?.toString()),
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(vehicle['brand']?.toString() ?? '',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
                Text('${_vehicleLabel(vehicle['type']?.toString())} · ${vehicle['registration'] ?? ''}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5))),
              ]),
            ]),
            const SizedBox(height: 20),
            if (isLast)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'You must keep at least one vehicle.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.orange[700]),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLast ? null : () async {
                  Navigator.pop(ctx);
                  await _deleteVehicle(id);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text('Delete Vehicle',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: isLast ? theme.dividerColor : Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteVehicle(String id) async {
    final res = await ApiService.deleteVehicle(id);
    if (!mounted) return;
    if (res['success'] == true) {
      _loadMyVehicles();
    } else {
      Get.snackbar('Error',
          res['message'] ?? 'Could not delete vehicle',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white);
    }
  }

  // ── Vehicle grid ───────────────────────────────────────────────────────────
  Widget _buildVehicleGrid(ThemeData theme) {
    if (_vehiclesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    // itemCount = vehicles + 1 for the "+" add tile
    final itemCount = _myVehicles.length + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82),
        itemBuilder: (context, index) {
          // Last tile is always the "+" add button
          if (index == _myVehicles.length) return _buildAddTile(theme);

          final v = _myVehicles[index];
          final emoji = _vehicleEmoji(v['type']?.toString());
          final type  = _vehicleLabel(v['type']?.toString());
          final brand = v['brand']?.toString() ?? '';
          return GestureDetector(
            onTap: () => _showVehicleOptions(v),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2))],
                    ),
                    child: Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 28))),
                  ),
                ),
                const SizedBox(height: 6),
                Text(brand.isNotEmpty ? brand : type,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyLarge?.color)),
                if (brand.isNotEmpty)
                  Text(type,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddTile(ThemeData theme) {
    return GestureDetector(
      onTap: _openAddVehicleSheet,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.green.withOpacity(0.4),
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, size: 30, color: Colors.green),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('Add',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.green)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ── Reviews list ───────────────────────────────────────────────────────────
  Widget _buildReviewsList(ThemeData theme) {
    if (_reviewsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text("No reviews yet",
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _reviews.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _reviewCard(r, theme),
        )).toList(),
      ),
    );
  }

  Widget _reviewCard(_ReviewItem r, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 22,
              backgroundImage: NetworkImage(r.avatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(r.name,
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color)),
                  const Spacer(),
                  Text(r.time,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500])),
                ]),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) => Icon(Icons.star,
                      size: 13,
                      color: i < r.rating.toInt()
                          ? Colors.orange : Colors.grey[300])),
                ),
                const SizedBox(height: 6),
                Text(r.text,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRAWER BACKGROUND PAINTER
// Subtle darker-green polygon shapes on the green gradient
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerBgPainter extends CustomPainter {
  final bool isDark;
  _DrawerBgPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.07);

    // Large polygon — top-right area
    final Path p1 = Path()
      ..moveTo(w * 0.40, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.35)
      ..lineTo(w * 0.55, h * 0.20)
      ..close();
    canvas.drawPath(p1, paint);

    // Medium polygon — bottom-left
    final Path p2 = Path()
      ..moveTo(0, h * 0.65)
      ..lineTo(w * 0.45, h * 0.80)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p2, paint);

    // Small polygon — mid-right
    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? Colors.black.withOpacity(0.03) : Colors.black.withOpacity(0.06);

    final Path p3 = Path()
      ..moveTo(w * 0.60, h * 0.10)
      ..lineTo(w, h * 0.28)
      ..lineTo(w, h * 0.10)
      ..close();
    canvas.drawPath(p3, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
