import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_endpoints.dart';

/// **Customer module** — Flutter role "Looking for Transportation" / backend `client`.
///
/// Covers: home (search transporters), bookings, addresses, payments, favorites,
/// notifications, tracking (read), feedback, packages.
final class CustomerApiService {
  CustomerApiService(this._client);

  final ApiClient _client;

  // --- User profile ---
  Future<http.Response> getMyProfile() =>
      _client.get(ApiEndpoints.userProfile);

  // --- Orders (bookings) ---
  Future<http.Response> listOrders({Map<String, String>? query}) =>
      _client.get(ApiEndpoints.orderList, query: query);

  Future<http.Response> listOrdersByStatus(
    String status, {
    Map<String, String>? query,
  }) =>
      _client.get(ApiEndpoints.ordersByStatus(status), query: query);

  /// Multipart: text fields + file field name `photos` (up to 5) per backend.
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

  // --- Search (find transporters) ---
  Future<http.Response> searchTransporters({Map<String, String>? query}) =>
      _client.get(ApiEndpoints.searchTransporters, query: query);

  Future<http.Response> searchOrders(Object body) =>
      _client.post(ApiEndpoints.searchOrders, body: body);

  Future<http.Response> searchUsers({Map<String, String>? query}) =>
      _client.get(ApiEndpoints.searchUsers, query: query);

  // --- Packages ---
  Future<http.Response> listPackages() => _client.get(ApiEndpoints.packages);

  Future<http.Response> getPackage(String id) =>
      _client.get(ApiEndpoints.packageById(id));

  Future<http.Response> createPackage(Object body) =>
      _client.post(ApiEndpoints.packages, body: body);

  Future<http.Response> updatePackage(String id, Object body) =>
      _client.put(ApiEndpoints.packageById(id), body: body);

  Future<http.Response> deletePackage(String id) =>
      _client.delete(ApiEndpoints.packageById(id));

  // --- Addresses ---
  Future<http.Response> createAddress(Object body) =>
      _client.post(ApiEndpoints.addressCreate, body: body);

  Future<http.Response> listAddresses() =>
      _client.get(ApiEndpoints.addressAll);

  Future<http.Response> getAddress(String id) =>
      _client.get(ApiEndpoints.addressById(id));

  Future<http.Response> updateAddress(String id, Object body) =>
      _client.put(ApiEndpoints.addressUpdate(id), body: body);

  Future<http.Response> deleteAddress(String id) =>
      _client.delete(ApiEndpoints.addressDelete(id));

  Future<http.Response> setDefaultAddress(String id) =>
      _client.patch(ApiEndpoints.addressSetDefault(id));

  // --- Favorites (transporters) ---
  Future<http.Response> listFavorites() =>
      _client.get(ApiEndpoints.favoritesList);

  Future<http.Response> addFavorite(String transporterId) =>
      _client.post(ApiEndpoints.favoriteAdd(transporterId));

  Future<http.Response> removeFavorite(String transporterId) =>
      _client.delete(ApiEndpoints.favoriteRemove(transporterId));

  Future<http.Response> isFavorite(String transporterId) =>
      _client.get(ApiEndpoints.favoriteCheck(transporterId));

  // --- Payments ---
  Future<http.Response> listPaymentMethods() =>
      _client.get(ApiEndpoints.paymentsMethods);

  Future<http.Response> savePaymentMethod(Object body) =>
      _client.post(ApiEndpoints.paymentsMethods, body: body);

  Future<http.Response> processPayment(Object body) =>
      _client.post(ApiEndpoints.paymentsProcess, body: body);

  // --- Notifications ---
  Future<http.Response> createNotification(Object body) =>
      _client.post(ApiEndpoints.notificationCreate, body: body);

  Future<http.Response> listNotifications(String userId) =>
      _client.get(ApiEndpoints.notificationListByUser(userId));

  // --- Tracking (read-only flows for customer) ---
  Future<http.Response> trackingDetails(String orderId) =>
      _client.get(ApiEndpoints.trackingDetails(orderId));

  Future<http.Response> trackingDriverLocation(String orderId) =>
      _client.get(ApiEndpoints.trackingLocation(orderId));

  Future<http.Response> trackingHistory(String orderId) =>
      _client.get(ApiEndpoints.trackingHistory(orderId));

  Future<http.Response> trackingEta(String orderId) =>
      _client.get(ApiEndpoints.trackingEta(orderId));

  // --- Feedback ---
  Future<http.Response> submitFeedback(Object body) =>
      _client.post(ApiEndpoints.feedbackSubmit, body: body);

  Future<http.Response> getFeedbackForOrder(String orderId) =>
      _client.get(ApiEndpoints.feedbackByOrderId(orderId));

  Future<http.Response> createFeedbackForOrder(String orderId, Object body) =>
      _client.post(ApiEndpoints.feedbackCreateForOrder(orderId), body: body);

  Future<http.Response> listAllFeedbacks() =>
      _client.get(ApiEndpoints.feedbackAll);

  // --- Transporter discovery (read-only) ---
  Future<http.Response> listTransporters({Map<String, String>? query}) =>
      _client.get(ApiEndpoints.transporterAll, query: query);

  Future<http.Response> getTransporterProfile(String id) =>
      _client.get(ApiEndpoints.transporterProfile(id));

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

  Future<http.Response> rateTransporter(String id, Object body) =>
      _client.post(ApiEndpoints.transporterRate(id), body: body);

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
