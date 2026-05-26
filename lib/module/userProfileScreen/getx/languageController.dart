import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LanguageController extends GetxController {

  var selectedLanguage = "English".obs;

  void updateLanguage(String lang) {
    selectedLanguage.value = lang;
  }
}