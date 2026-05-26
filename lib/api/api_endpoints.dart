/// Backend API paths for `kaf8_backend` (`src/app.js` mounts unless noted).
///
/// **Flutter modules vs backend**
/// - **Customer** (`RoleSelectionScreen` → "Looking for Transportation") →
///   backend role [AppUserRole.client]. Use [CustomerApiService].
/// - **Service provider** (same screen → "Become a Service Provider?", code
///   `selectedRole == 'driver'`, `ServiceHome`) → backend roles
///   [AppUserRole.transporter] / [AppUserRole.serviceProvider].
///   Use [ServiceProviderApiService].
///
/// There is no separate third "driver" API in this repo: the delivery person
/// is modeled as a **transporter** / provider user.
///
/// Usage: [ApiConfig.resolve], [ApiClient], and `package:kaf8/core/api/kaf_api.dart`.
library;

/// Base URL for the Node server (override at build time).
///
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://your-api.example.com
/// ```
abstract final class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://8.231.67.123:5000',
  );

  /// Full URL for a path beginning with `/api/...`.
  static Uri resolve(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$p');
  }
}

/// Relative paths (always start with `/api`). Use with [ApiConfig.baseUrl].
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // --- Auth (`app.use('/api/auth', authRoutes)`) ---
  static const String authUpdateRole = '/api/auth/update-role';
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authForgotPassword = '/api/auth/forgot-password';
  static const String authSendOtp = '/api/auth/send-otp';
  static const String authVerifyOtp = '/api/auth/verify-otp';
  static const String authVerifyResetCode = '/api/auth/verify-reset-code';
  static const String authResetPassword = '/api/auth/reset-password';
  static const String authRefreshToken = '/api/auth/refresh-token';

  // --- User (`/api/user`) ---
  static const String userProfile = '/api/user/profile';
  static const String userAll = '/api/user/all';
  static String userById(String id) => '/api/user/$id';
  static String userUpdate(String id) => '/api/user/update/$id';
  static String userDelete(String id) => '/api/user/delete/$id';

  // --- Transporter (`/api/transporter`) ---
  static const String transporterAll = '/api/transporter/all';
  static String transporterAvailability(String id) =>
      '/api/transporter/$id/availability';
  static String transporterProfile(String id) => '/api/transporter/$id';
  static String transporterRate(String id) => '/api/transporter/$id/rate';
  static const String transporterCreate = '/api/transporter/create';
  static String transporterUpdate(String id) => '/api/transporter/update/$id';
  static String transporterDelete(String id) => '/api/transporter/delete/$id';

  /// Query: `latitude`, `longitude`, `radius` (see backend comment).
  static const String transporterNearby =
      '/api/transporter/transporters/nearby';
  static String transporterStatus(String id) => '/api/transporter/$id/status';

  // --- Order (`/api/order`) ---
  /// Query: pagination params from backend middleware.
  static const String orderList = '/api/order/orders';
  static String ordersByStatus(String status) => '/api/order/status/$status';
  static const String orderCreate = '/api/order/create';
  static String orderDelete(String orderId) => '/api/order/$orderId';

  // --- Search (`/api/search`) ---
  static const String searchTransporters = '/api/search/transporters';
  static const String searchOrders = '/api/search/orders';
  static const String searchUsers = '/api/search/users';

  // --- Notification (`/api/notification`) ---
  static const String notificationCreate = '/api/notification/notifications';
  static String notificationListByUser(String userId) =>
      '/api/notification/notifications/$userId';

  // --- Packages (`app.use('/api', packageRoutes)`) ---
  static const String packages = '/api/packages';
  static String packageById(String id) => '/api/packages/$id';

  // --- Tracking (`/api/tracking`) ---
  static String trackingDetails(String orderId) => '/api/tracking/$orderId';
  static String trackingLocation(String orderId) =>
      '/api/tracking/$orderId/location';
  static String trackingUpdateStatus(String orderId) =>
      '/api/tracking/$orderId/status';
  static String trackingHistory(String orderId) =>
      '/api/tracking/$orderId/history';
  static String trackingEta(String orderId) => '/api/tracking/$orderId/eta';

  // --- Feedback (`/api/feedback`) ---
  static const String feedbackSubmit = '/api/feedback/submit';
  static String feedbackByOrderId(String orderId) => '/api/feedback/$orderId';
  static String feedbackCreateForOrder(String orderId) =>
      '/api/feedback/$orderId';
  static const String feedbackAll = '/api/feedback';

  // --- Payments (`/api/payments`) ---
  static const String paymentsProcess = '/api/payments/process';
  static const String paymentsMethods = '/api/payments/methods';

  // --- Vehicle (`/api/vehicle`) ---
  static const String vehicleCreate = '/api/vehicle/create';
  static const String vehicleAll = '/api/vehicle/all';
  static String vehicleById(String id) => '/api/vehicle/$id';
  static String vehicleUpdate(String id) => '/api/vehicle/$id';
  static String vehicleDelete(String id) => '/api/vehicle/$id';
  static String vehiclePhotoUpload(String id) => '/api/vehicle/$id/photo';
  static String vehiclePhotoDelete(String id) => '/api/vehicle/$id/photo';

  // --- Address (`/api/address`) — all routes require auth on router ---
  static const String addressCreate = '/api/address/create';
  static const String addressAll = '/api/address/all';
  static String addressById(String id) => '/api/address/$id';
  static String addressUpdate(String id) => '/api/address/$id';
  static String addressDelete(String id) => '/api/address/$id';
  static String addressSetDefault(String id) => '/api/address/$id/set-default';

  // --- Favorites (`app.use('/api', favoriteTransporterRoutes)`) ---
  static String favoriteAdd(String transporterId) =>
      '/api/transporter/$transporterId/favorite';
  static String favoriteRemove(String transporterId) =>
      '/api/transporter/$transporterId/favorite';
  static const String favoritesList = '/api/favorites';
  static String favoriteCheck(String transporterId) =>
      '/api/transporter/$transporterId/favorite';

  // --- Docs / health (no auth) ---
  static const String swaggerJson = '/swagger.json';
  static const String apiDocs = '/api-docs';

  // ---------------------------------------------------------------------------
  // Defined in backend `src/routes/` but NOT registered in `src/app.js` yet.
  // Mount them on the server (e.g. `/api/statistics`) before calling.
  // ---------------------------------------------------------------------------

  /// Intended mount: `app.use('/api/statistics', statisticsRoutes)`.
  static const String statisticsRoot = '/api/statistics';
  static const String statisticsOverview = '/api/statistics';
  static const String statisticsEarnings = '/api/statistics/earnings';
  static const String statisticsOrders = '/api/statistics/orders';

  /// Intended mount: `app.use('/api/notification-settings', notificationSettingsRoutes)`.
  static const String notificationSettingsRoot = '/api/notification-settings';
  static const String notificationSettingsGet = '/api/notification-settings';
  static const String notificationSettingsPut = '/api/notification-settings';

  /// Intended mount: `app.use('/api/export', exportRoutes)` (admin).
  static const String exportData = '/api/export';
}
