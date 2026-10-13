import 'package:get/get.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(num amount) {
    final lang = Get.locale?.languageCode ?? 'en';
    final formatted = amount.toStringAsFixed(2);

    switch (lang) {
      case 'fr':
      case 'es':
      case 'pt':
        // European standard format: 25,50 €
        return '${formatted.replaceAll('.', ',')} €';
      case 'en':
      default:
        return '€$formatted';
    }
  }
}
