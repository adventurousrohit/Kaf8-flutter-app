/// Networking layer for `kaf8_backend`: endpoints, HTTP client, and per-module services.
///
/// - [CustomerApiService] — shipper / "Looking for Transportation".
/// - [ServiceProviderApiService] — "Become a Service Provider?" (`ServiceHome`).
/// - [AuthApiService] — shared auth.
library;

export 'api_client.dart';
export 'api_endpoints.dart';
export 'app_user_role.dart';
export 'auth_api_service.dart';
export 'customer_api_service.dart';
export 'service_provider_api_service.dart';
