import 'package:get/get.dart';
import '../Service/api_service.dart';

class OrderController extends GetxController {
  // Per-tab lists so tabs never overwrite each other
  final RxList<Map<String, dynamic>> pendingOrders  = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> activeOrders   = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> historyOrders  = <Map<String, dynamic>>[].obs;

  // Driver: available orders to pick up
  final RxList<Map<String, dynamic>> availableOrders = <Map<String, dynamic>>[].obs;

  final RxBool isLoadingPending   = false.obs;
  final RxBool isLoadingActive    = false.obs;
  final RxBool isLoadingHistory   = false.obs;
  final RxBool isLoadingAvailable = false.obs;
  final RxBool isCreating         = false.obs;

  final RxString errorMessage = ''.obs;

  Future<void> fetchPending() async {
    isLoadingPending.value = true;
    print("📋 Controller: Fetching Pending Orders...");
    final result = await ApiService.getMyOrders(status: 'pending');
    print("📋 Controller: Pending Orders Result success=${result['success']}");
    isLoadingPending.value = false;
    if (result['success'] == true) {
      pendingOrders.value = _asList(result['data']);
    }
  }

  Future<void> fetchActive() async {
    isLoadingActive.value = true;
    print("📋 Controller: Fetching Active Orders...");
    final result = await ApiService.getMyOrders(status: 'active');
    print("📋 Controller: Active Orders Result success=${result['success']}");
    isLoadingActive.value = false;
    if (result['success'] == true) {
      activeOrders.value = _asList(result['data']);
    }
  }

  Future<void> fetchHistory() async {
    isLoadingHistory.value = true;
    print("📋 Controller: Fetching History Orders...");
    // Fetch both delivered + canceled in parallel and merge
    final results = await Future.wait([
      ApiService.getMyOrders(status: 'delivered'),
      ApiService.getMyOrders(status: 'canceled'),
    ]);
    print("📋 Controller: History Results received");
    isLoadingHistory.value = false;
    final merged = <Map<String, dynamic>>[];
    for (final r in results) {
      if (r['success'] == true) merged.addAll(_asList(r['data']));
    }
    merged.sort((a, b) {
      final dateA = DateTime.tryParse(a['dateOrder'] as String? ?? '') ?? DateTime(0);
      final dateB = DateTime.tryParse(b['dateOrder'] as String? ?? '') ?? DateTime(0);
      return dateB.compareTo(dateA);
    });
    historyOrders.value = merged;
  }

  Future<void> fetchPendingAvailable() async {
    isLoadingAvailable.value = true;
    final result = await ApiService.getPendingAvailableOrders();
    isLoadingAvailable.value = false;
    if (result['success'] == true) {
      availableOrders.value = _asList(result['data']);
    }
  }

  // Keep legacy method for compatibility
  Future<void> fetchMyOrders({String? status}) async {
    if (status == 'pending')   return fetchPending();
    if (status == 'active')    return fetchActive();
    if (status == 'delivered') return fetchHistory();
    // no status → refresh all
    fetchPending();
    fetchActive();
    fetchHistory();
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    isCreating.value = true;
    errorMessage.value = '';
    try {
      final result = await ApiService.createOrder(orderData);
      if (result['success'] == true) {
        fetchPending();
      } else {
        errorMessage.value = result['message'] ?? 'Failed to create order';
      }
      return result;
    } catch (e) {
      errorMessage.value = e.toString();
      return {"success": false, "message": e.toString()};
    } finally {
      isCreating.value = false;
    }
  }

  Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    try {
      final result = await ApiService.acceptOrder(orderId);
      if (result['success'] == true) {
        availableOrders.removeWhere((o) => o['id'] == orderId);
      }
      return result;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status, {String? cancelReason}) async {
    try {
      final result = await ApiService.updateOrderStatus(orderId, status,
          cancelReason: cancelReason);
      if (result['success'] == true) {
        // Refresh relevant lists
        if (status == 'delivered' || status == 'canceled') {
          fetchActive();
          fetchHistory();
        }
      }
      return result;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  static String formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'pending':   return 'Pending';
      case 'active':    return 'In Progress';
      case 'delivered': return 'Delivered';
      case 'canceled':  return 'Cancelled';
      default: return status;
    }
  }

  static String paymentMethodLabel(String? method) {
    if (method == 'pay_now')          return 'Pay Now';
    if (method == 'pay_on_delivery')  return 'Pay on Delivery';
    return method ?? '';
  }
}
