import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaf8/home/parcelDetailsScreen.dart';
import 'package:kaf8/Service/location_service.dart';
import 'package:geolocator/geolocator.dart';

import '../../../components/delivery_textWidget.dart';
import '../../../small-widgets/app_assets.dart';
import '../../../small-widgets/app_colors.dart';

class homeorder extends StatefulWidget {
  const homeorder({super.key});

  @override
  State<homeorder> createState() => _homeorderState();
}

class _homeorderState extends State<homeorder> {
  GoogleMapController? _mapController;
  String _currentAddress = "Fetching location...";
  String _destinationAddress = "Tap map to set destination";
  LatLng? _currentLatLng;
  LatLng? _destinationLatLng;
  bool _isSearchVisible = false;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(25.0343, -77.3963), // Nassau, Bahamas
    zoom: 14.4746,
  );

  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchLocation() async {
    Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      _currentLatLng = LatLng(position.latitude, position.longitude);
      String? address = await LocationService.getAddressFromLatLng(position);
      setState(() {
        if (address != null) _currentAddress = address;
        _markers.add(
          Marker(
            markerId: const MarkerId('origin'),
            position: _currentLatLng!,
            infoWindow: const InfoWindow(title: 'Origin'),
          ),
        );
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLatLng!, 14.4746),
      );
    }
  }

  void _onMapTap(LatLng position) async {
    setState(() {
      _destinationLatLng = position;
      _markers.removeWhere((m) => m.markerId.value == 'destination');
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      );
    });

    // Fetch address for the tapped destination
    try {
      Position destPos = Position(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      String? address = await LocationService.getAddressFromLatLng(destPos);
      if (address != null) {
        setState(() {
          _destinationAddress = address;
        });
      }
    } catch (e) {
      debugPrint("Error fetching destination address: $e");
    }
  }

  void _onSearchChanged(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _isSearching = true);
    final suggestions = await LocationService.getSuggestions(query);
    setState(() {
      _suggestions = suggestions;
      _isSearching = false;
    });
  }

  void _searchDestination(String query) async {
    if (query.isEmpty) return;
    Position? position = await LocationService.getLatLngFromAddress(query);
    if (position != null) {
      LatLng destination = LatLng(position.latitude, position.longitude);
      _onMapTap(destination);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(destination, 14.4746),
      );
    } else {
      Get.snackbar("Error", "Could not find the location",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(Icons.arrow_back_ios, color: theme.iconTheme.color, size: 18),
              const SizedBox(width: 4),
              Text(
                "Back",
                style: GoogleFonts.poppins(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Google Map filling the background
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentLatLng != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentLatLng!, 14.4746),
                );
              }
            },
            onTap: _onMapTap,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),
          // Search Bar
          if (_isSearchVisible)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: _suggestions.isNotEmpty
                          ? const BorderRadius.vertical(top: Radius.circular(30))
                          : BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search destination...",
                        border: InputBorder.none,
                        icon: const Icon(Icons.search, color: Colors.green),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.green)),
                              )
                            : null,
                      ),
                      onSubmitted: (value) {
                        _searchDestination(value);
                        setState(() {
                          _isSearchVisible = false;
                          _suggestions = [];
                        });
                      },
                    ),
                  ),
                  if (_suggestions.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.vertical(bottom: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_suggestions[index],
                                style: GoogleFonts.poppins(fontSize: 13)),
                            onTap: () {
                              _searchController.text = _suggestions[index];
                              _searchDestination(_suggestions[index]);
                              setState(() {
                                _isSearchVisible = false;
                                _suggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          // Draggable Bottom Sheet UI
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.3, // Map shows ~70% when collapsed
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLocationCard(context),
                      const SizedBox(height: 25),
                      _buildFavoriteCard(context),
                      const SizedBox(height: 6),
                      _buildFavoriteCard(context),
                      const SizedBox(height: 30),
                      // Confirm Booking Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF46890D),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            Get.to(const ParcelDetailsScreen());
                          },
                          child: const Text("Confirm Booking",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: 290,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            _locationTile(context, Icons.home, Colors.green, "Supported",
                _currentAddress),
            const Divider(height: 30),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                });
              },
              child: _locationTile(context, Icons.location_on, Colors.green,
                  "Destination", _destinationAddress,
                  isMap: true),
            ),
          ],
        ),
      ),
    );
  }
  Widget _locationTile(BuildContext context, IconData icon, Color color, String title, String subtitle, {bool isMap = false}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Color(0XFF00C853), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style:  GoogleFonts.poppins(color: Colors.grey, fontSize: 10,fontWeight:FontWeight.w500)),
              Text(subtitle, style:   GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12,color: theme.textTheme.bodyMedium?.color)),
            ],
          ),
        ),
        if (isMap)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Color(0XFF00C853), borderRadius: BorderRadius.circular(20)),
            child:  Text("Map", style: GoogleFonts.roboto(color: Colors.white, fontSize: 12.86,fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
  Widget _buildFavoriteCard(BuildContext context) {
    final theme = Theme.of(context);
    return
      Container(
        width: double.infinity,
        height: 170,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: 20, top: 0),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(12.72)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BahamasTextWidget(
                  text: "Delivery Driver",
                  fontSize: 8.82,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                Image.asset(AppAssets.tag,width: 15,height: 15,)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(AppAssets.person1,width: 32,height: 32,),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BahamasTextWidget(
                        text: "Wade Warren",
                        fontSize: 11.84,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 2,),
                      Row(
                        children: [
                          Icon(Icons.location_on_sharp,color: theme.iconTheme.color,size: 5.83,),
                          SizedBox(width: 2,),
                          const BahamasTextWidget(
                            text: "123 Main St, Apt 4B, City, State",
                            fontSize: 5.83,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 8.83, color: Colors.amber),
                          const SizedBox(width: 4),
                          const BahamasTextWidget(
                            text: "4.8",
                            fontSize: 8.83,
                            fontWeight: FontWeight.w600,
                          ),
                          BahamasTextWidget(
                            text: " (1.2k)",
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(onTap: (){
                },
                    child: Image.asset(AppAssets.voice,width: 22,height: 22,)),
                const SizedBox(width: 8),
                Image.asset(AppAssets.phone,width: 22,height: 22,),
              ],
            ),
            const SizedBox(height: 10),
            BahamasTextWidget(
              text: "Delivery Vehicles",
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                _buildVehicleCard(context, "Moterbike", AppAssets.bike),
                const SizedBox(width: 10),
                _buildVehicleCard(context, "Lorry", AppAssets.truck2),
              ],
            ),
          ],
        ),
      );  }
  Widget _buildVehicleCard(BuildContext context, String name, String imagePath) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 45,
        width: 172,
        padding: EdgeInsets.only(right: 35),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              imagePath,
              height:57,
              width: 46,
              fit: BoxFit.contain,
            ),
            BahamasTextWidget(
              text: name,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.54),
            ),
          ],
        ),
      ),
    );
  }
}
