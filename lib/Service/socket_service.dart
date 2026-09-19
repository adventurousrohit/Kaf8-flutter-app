import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_service.dart';

/// Singleton that manages the Socket.IO connection for real-time tracking.
///
/// Usage:
///   final socket = SocketService();
///   await socket.connect();
///   socket.joinOrderRoom(orderId);
///   socket.onDriverLocation((lat, lng) { ... });
///   socket.dispose();
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await ApiService.getAccessToken();

    // Strip /api from baseUrl to get the raw host
    final host = ApiService.baseUrl.replaceAll('/api', '');

    _socket = io.io(
      host,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token ?? ''})
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.connect();
  }

  void joinOrderRoom(String orderId) {
    _socket?.emit('join_order_room', {'orderId': orderId});
  }

  /// Driver emits their GPS position to the order room.
  void emitLocation(String orderId, double lat, double lng) {
    _socket?.emit('driver_location_update', {
      'orderId': orderId,
      'lat': lat,
      'lng': lng,
    });
  }

  /// Subscribe to driver location updates (customer side).
  void onDriverLocation(void Function(double lat, double lng) callback) {
    _socket?.on('driver_location_update', (data) {
      try {
        final lat = (data['lat'] as num).toDouble();
        final lng = (data['lng'] as num).toDouble();
        callback(lat, lng);
      } catch (_) {}
    });
  }

  /// Subscribe to order status changes.
  void onOrderStatusUpdate(void Function(String status) callback) {
    _socket?.on('order_status_update', (data) {
      try {
        callback(data['status'] as String);
      } catch (_) {}
    });
  }

  void offDriverLocation() => _socket?.off('driver_location_update');
  void offOrderStatusUpdate() => _socket?.off('order_status_update');

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
