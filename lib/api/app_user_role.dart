/// Values accepted by `POST /api/auth/update-role` and stored on the user model
/// (`kaf8_backend` Sequelize enum).
abstract final class AppUserRole {
  AppUserRole._();

  /// Shipper — Flutter role card "Looking for Transportation" (`customer`).
  static const String client = 'client';

  /// Flutter "Service Provider" / fleet transporter.
  static const String transporter = 'transporter';

  /// Additional provider role in backend schema.
  static const String serviceProvider = 'serviceProvider';

  static const String administrator = 'administrator';
}
