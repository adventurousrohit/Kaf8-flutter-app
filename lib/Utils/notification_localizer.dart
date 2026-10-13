import 'package:get/get.dart';

String localizeNotificationTitle(Object? value) {
  final title = value?.toString().trim() ?? '';
  if (title.isEmpty) return 'notification'.tr;

  final normalized = title
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  const titleKeys = {
    'notification': 'notification',
    'goods': 'notification_goods',
    'goods update': 'notification_goods',
    'goods notification': 'notification_goods',
    'vehicle': 'notification_vehicle',
    'vehicle update': 'notification_vehicle',
    'vehicle notification': 'notification_vehicle',
    'order': 'notification_order',
    'new order': 'notification_new_order',
    'order update': 'notification_order_updated',
    'order updated': 'notification_order_updated',
    'order status update': 'notification_order_updated',
    'order status updated': 'notification_order_updated',
    'booking': 'notification_booking',
    'new booking': 'notification_new_booking',
    'booking update': 'notification_booking_updated',
    'booking updated': 'notification_booking_updated',
    'booking status updated': 'notification_booking_updated',
    'delivery': 'notification_delivery',
    'new delivery': 'notification_new_delivery',
    'new status': 'notification_new_status',
    'vehicle status updated': 'notification_vehicle_status_updated',
    'accepted': 'notification_accepted',
    'request accepted': 'notification_accepted',
    'order accepted': 'notification_order_accepted',
    'order placed': 'notification_order_placed',
    'order confirmed': 'notification_order_confirmed',
    'order delivered': 'notification_order_delivered',
    'order cancelled': 'notification_order_cancelled',
    'order canceled': 'notification_order_cancelled',
    'booking accepted': 'notification_booking_accepted',
    'booking confirmed': 'notification_booking_confirmed',
    'delivery accepted': 'notification_delivery_accepted',
  };

  final key = titleKeys[normalized];
  return key == null ? title : key.tr;
}
