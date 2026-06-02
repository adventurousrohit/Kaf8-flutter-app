import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Controller/order_controller.dart';
import '../Service/socket_service.dart';

/// Customer live-tracking screen.
/// Connects to the Socket.IO server, joins the order room, and updates a
/// marker on the map as the driver emits location events.
class TrackingScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const TrackingScreen({super.key, required this.order});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  LatLng? _driverLatLng;
  String _liveStatus = '';
  final _socket = SocketService();

  static const _defaultPosition = LatLng(48.8566, 2.3522); // Paris

  String get _orderId => widget.order['id']?.toString() ?? '';
  String get _from =>
      widget.order['departureAddress']?.toString() ?? 'Pickup';
  String get _to =>
      widget.order['receiverAddress']?.toString() ?? 'Dropoff';
  String get _statusStr =>
      _liveStatus.isNotEmpty
          ? _liveStatus
          : (widget.order['statusOrder']?.toString() ?? 'active');

  @override
  void initState() {
    super.initState();
    _liveStatus = widget.order['statusOrder']?.toString() ?? 'active';
    _initSocket();
  }

  Future<void> _initSocket() async {
    await _socket.connect();
    _socket.joinOrderRoom(_orderId);

    _socket.onDriverLocation((lat, lng) {
      final pos = LatLng(lat, lng);
      setState(() => _driverLatLng = pos);
      _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
    });

    _socket.onOrderStatusUpdate((status) {
      setState(() => _liveStatus = status);
    });
  }

  @override
  void dispose() {
    _socket.offDriverLocation();
    _socket.offOrderStatusUpdate();
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
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your driver'),
      ),
    };
  }

  Color get _statusColor {
    switch (_statusStr) {
      case 'active':    return Colors.blue;
      case 'delivered': return Colors.green;
      case 'canceled':  return Colors.red;
      default:          return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
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
              zoom: 14,
            ),
            onMapCreated: (c) => _mapController = c,
            markers: _markers,
            zoomControlsEnabled: false,
          ),

          // Status banner
          Positioned(
            top: 12, left: 16, right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    decoration: BoxDecoration(
                        color: _statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    OrderController.statusLabel(_statusStr),
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _statusColor),
                  ),
                ],
              ),
            ),
          ),

          // Waiting for driver overlay
          if (_driverLatLng == null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 14)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.green),
                    const SizedBox(height: 12),
                    Text('Waiting for driver location…',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                    const SizedBox(height: 4),
                    Text('The map updates automatically',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
                  ],
                ),
              ),
            ),

          // Bottom info card
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _addressRow(
                      Icons.my_location, 'Pickup', _from, Colors.green, theme),
                  const SizedBox(height: 10),
                  _addressRow(
                      Icons.location_on, 'Dropoff', _to, Colors.red, theme),
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
