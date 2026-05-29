import 'package:get/get.dart';
import '../Service/api_service.dart';

class UserProfileController extends GetxController {
  final Rx<Map<String, dynamic>?> profile = Rx(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final token = await ApiService.getAccessToken();
    if (token == null || token.isEmpty) return;
    isLoading.value = true;
    final res = await ApiService.getProfile();
    isLoading.value = false;
    if (res['success'] == true && res['data'] is Map) {
      profile.value = Map<String, dynamic>.from(res['data'] as Map);
    }
  }

  Future<void> refreshProfile() => loadProfile();

  void clearProfile() => profile.value = null;

  String get displayName {
    final p = profile.value;
    if (p == null) return '';
    final full = p['fullName']?.toString() ?? '';
    if (full.isNotEmpty) return full;
    final first = p['firstName']?.toString() ?? '';
    final last = p['lastName']?.toString() ?? '';
    return '$first $last'.trim();
  }

  String? get avatarUrl => profile.value?['avatar']?.toString();
}
