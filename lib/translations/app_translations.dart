import 'package:get/get.dart';
import 'en_us.dart';
import 'fr_fr.dart';
import 'es_es.dart';
import 'pt_pt.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
        'fr_FR': frFr,
        'es_ES': esEs,
        'pt_PT': ptPt,
      };
}
