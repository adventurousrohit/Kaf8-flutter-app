import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_endpoints.dart';

/// **Service provider module** — Flutter card "Become a Service Provider?" uses
/// `selectedRole == 'driver'` and routes to `selfLogin` / `ServiceHome`.
/// Backend roles: typically `transporter` or `serviceProvider` ([AppUserRole]).
///
/// Covers: transporter profile & availability, vehicles & photos, delivery
/// tracking updates, bookings list, optional statistics when mounted.
final class ServiceProviderApiService {
  ServiceProviderApiService(this._client);

  final ApiClient _client;

  // --- Transporter (self / fleet) ---
  Future<http.Response> createTransporterProfile(Object body) =>
      _client.post(ApiEndpoints.transporterCreate, body: body);

  Future<http.Response> listTransporters({Map<String, String>? query}) =>
      _client.get(ApiEndpoints.transporterAll, query: query);

  Future<http.Response> getTransporterProfile(String id) =>
      _client.get(ApiEndpoints.transporterProfile(id));

  Future<http.Response> updateTransporter(String id, Object body) =>
      _client.put(ApiEndpoints.transporterUpdate(id), body: body);

  Future<http.Response> deleteTransporter(String id) =>
      _client.delete(ApiEndpoints.transporterDelete(id));

  Future<http.Response> updateAvailability(String id, Object body) =>
      _client.patch(ApiEndpoints.transporterAvailability(id), body: body);

  Future<http.Response> findNearbyTransporters({
    required String latitude,
    required String longitude,
    String? radius,
  }) {
    return _client.get(
      ApiEndpoints.transporterNearby,
      query: {
        'latitude': latitude,
        'longitude': longitude,
        if (radius != null) 'radius': radius,
      },
    );
  }

  /// Backend: **administrator** role only (`checkRole('administrator')`).
  Future<http.Response> updateTransporterStatus(String id, Object body) =>
      _client.patch(ApiEndpoints.transporterStatus(id), body: body);

  // --- Vehicles (backend expects multipart; file field name `photo`) ---
  Future<http.Response> createVehicle({
    required Map<String, String> fields,
    http.MultipartFile? photo,
  }) {
    return _client.postMultipart(
      ApiEndpoints.vehicleCreate,
      fields: fields,
      files: [if (photo != null) photo],
    );
  }

  Future<http.Response> listVehicles({Map<String, String>? query}) =>
      _client.get(ApiEndpoints.vehicleAll, query: query);

  Future<http.Response> getVehicle(String id) =>
      _client.get(ApiEndpoints.vehicleById(id));

  Future<http.Response> updateVehicle(
    String id, {
    Map<String, String> fields = const {},
    http.MultipartFile? photo,
  }) {
    return _client.putMultipart(
      ApiEndpoints.vehicleUpdate(id),
      fields: fields,
      files: [if (photo != null) photo],
    );
  }

  Future<http.Response> deleteVehicle(String id) =>
      _client.delete(ApiEndpoints.vehicleDelete(id));

  /// Same field name as create/update: `photo`.
  Future<http.Response> uploadVehiclePhoto(
    String id,
    http.MultipartFile file,
  ) {
    return _client.postMultipart(
      ApiEndpoints.vehiclePhotoUpload(id),
      files: [file],
    );
  }

  Future<http.Response> deleteVehiclePhoto(String id) =>
      _client.delete(ApiEndpoints.vehiclePhotoDelete(id));

  // --- Orders (deliveries / bookings tab) ---
  Future<http.Response> listOrders({Map<String, String>? query}) =>
      _client.get(ApiEndpoints.orderList, query: query);

  Future<http.Response> listOrdersByStatus(
    String status, {
    Map<String, String>? query,
  }) =>
      _client.get(ApiEndpoints.ordersByStatus(status), query: query);

  Future<http.Response> createOrder({
    required Map<String, String> fields,
    List<http.MultipartFile> photos = const [],
  }) {
    return _client.postMultipart(
      ApiEndpoints.orderCreate,
      fields: fields,
      files: photos,
    );
  }

  Future<http.Response> deleteOrder(String orderId) =>
      _client.delete(ApiEndpoints.orderDelete(orderId));

  // --- Tracking (provider updates + reads) ---
  Future<http.Response> trackingDetails(String orderId) =>
      _client.get(ApiEndpoints.trackingDetails(orderId));

  Future<http.Response> trackingDriverLocation(String orderId) =>
      _client.get(ApiEndpoints.trackingLocation(orderId));

  Future<http.Response> updateDeliveryStatus(String orderId, Object body) =>
      _client.put(ApiEndpoints.trackingUpdateStatus(orderId), body: body);

  Future<http.Response> trackingHistory(String orderId) =>
      _client.get(ApiEndpoints.trackingHistory(orderId));

  Future<http.Response> trackingEta(String orderId) =>
      _client.get(ApiEndpoints.trackingEta(orderId));

  // --- Search / packages (if provider app needs them) ---
  Future<http.Response> searchOrders(Object body) =>
      _client.post(ApiEndpoints.searchOrders, body: body);

  Future<http.Response> listPackages() => _client.get(ApiEndpoints.packages);

  Future<http.Response> getPackage(String id) =>
      _client.get(ApiEndpoints.packageById(id));

  // --- Notifications ---
  Future<http.Response> createNotification(Object body) =>
      _client.post(ApiEndpoints.notificationCreate, body: body);

  Future<http.Response> listNotifications(String userId) =>
      _client.get(ApiEndpoints.notificationListByUser(userId));

  // --- Profile (user row) ---
  Future<http.Response> getMyProfile() =>
      _client.get(ApiEndpoints.userProfile);

  // --- Optional backend routes (mount in `app.js` first) ---
  Future<http.Response> statisticsOverview() =>
      _client.get(ApiEndpoints.statisticsOverview);

  Future<http.Response> statisticsEarnings() =>
      _client.get(ApiEndpoints.statisticsEarnings);

  Future<http.Response> statisticsOrders() =>
      _client.get(ApiEndpoints.statisticsOrders);

  Future<http.Response> getNotificationSettings() =>
      _client.get(ApiEndpoints.notificationSettingsGet);

  Future<http.Response> updateNotificationSettings(Object body) =>
      _client.put(ApiEndpoints.notificationSettingsPut, body: body);
}
