import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Controller/order_controller.dart';
import '../Service/socket_service.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const MapScreen({super.key, required this.order});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _driverLatLng;
  StreamSubscription<Position>? _positionStream;
  final _socket = SocketService();

  static const _defaultPosition = LatLng(48.8566, 2.3522); // Paris

  String get _orderId => widget.order['id']?.toString() ?? '';
  String get _from => widget.order['departureAddress']?.toString() ?? 'Pickup';
  String get _to => widget.order['receiverAddress']?.toString() ?? 'Dropoff';
  String get _receiver => widget.order['receiverName']?.toString() ?? '';
  String get _phone => widget.order['receiverPhone']?.toString() ?? '';
  String get _status => OrderController.statusLabel(
      widget.order['statusOrder']?.toString() ?? 'active');
  double get _cost =>
      double.tryParse(widget.order['deliveryCost']?.toString() ?? '0') ?? 0;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _startLocationStream();
  }

  Future<void> _initSocket() async {
    await _socket.connect();
    _socket.joinOrderRoom(_orderId);
  }

  void _startLocationStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // emit every 5 meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: settings).listen(
      (position) {
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() => _driverLatLng = latLng);
        _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
        _socket.emitLocation(_orderId, position.latitude, position.longitude);
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _socket.disconnect();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> get _markers {
    if (_driverLatLng == null) return {};
    return {
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Your location'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Active Delivery',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _driverLatLng ?? _defaultPosition,
              zoom: 15,
            ),
            onMapCreated: (c) => _mapController = c,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Status pill
          Positioned(
            top: 12, left: 16, right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_status · €${_cost.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                  ),
                ],
              ),
            ),
          ),

          // No GPS yet overlay
          if (_driverLatLng == null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.green),
                    const SizedBox(height: 12),
                    Text('Getting your location…',
                        style: GoogleFonts.inter(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
                  ],
                ),
              ),
            ),

          // Bottom delivery info card
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _addressRow(Icons.my_location, 'Pickup', _from,
                      Colors.green, theme),
                  const SizedBox(height: 10),
                  _addressRow(Icons.location_on, 'Dropoff', _to,
                      Colors.red, theme),

                  if (_receiver.isNotEmpty) ...[
                    Divider(height: 20, color: theme.dividerColor),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_receiver,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyLarge?.color)),
                        ),
                        Text(_phone,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressRow(
      IconData icon, String label, String address, Color color, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
              const SizedBox(height: 2),
              Text(address,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
