import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  var selectedLanguage = "English".obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguageName();
  }

  Future<void> _loadSavedLanguageName() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale_code');
    if (code == 'fr_FR' || code == 'fr') {
      selectedLanguage.value = 'Français';
    } else if (code == 'es_ES' || code == 'es') {
      selectedLanguage.value = 'Español';
    } else if (code == 'pt_PT' || code == 'pt') {
      selectedLanguage.value = 'Português';
    } else {
      selectedLanguage.value = 'English';
    }
  }

  void updateLanguage(String lang) {
    selectedLanguage.value = lang;
  }
}
