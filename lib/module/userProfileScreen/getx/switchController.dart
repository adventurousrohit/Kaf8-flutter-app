import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SwitchController extends GetxController {

  var isDefault = false.obs;

  void toggleDefault(bool value) {
    isDefault.value = value;
  }
}