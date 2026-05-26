// import 'package:intl/intl.dart';
//
// changeDateFormat(String strDate) {
//   var dateValue = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(strDate);
//   String formattedDate = DateFormat("HH:mm dd/MM/yyyy").format(dateValue);
//   return formattedDate;
// }
//
// changeDateYMD(String strDate) {
//   var dateValue = DateFormat("yyyy-MM-dd").parse(strDate);
//   String formattedDate = DateFormat("dd/MM/yyyy").format(dateValue);
//   return formattedDate;
// }
//
// changeDateFormatDDMMYYYY(String? strDate) {
//   String? startDate = strDate.nullableString();
//   if (startDate == null) {
//     return "";
//   } else {
//     var dateValue = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(startDate);
//     String formattedDate = DateFormat("dd MMM yyyy").format(dateValue);
//     return formattedDate;
//   }
// }
// changeDateFormatHs(String strDate) {
//   var dateValue = DateTime.tryParse(strDate)!.toLocal();
//   String formattedDate = DateFormat("dd-MM-yyyy, HH:mm").format(dateValue);
//   return formattedDate;
// }
//
// changeDateFormatRs(String strDate) {
//   var dateValue = DateTime.tryParse(strDate)!.toLocal();
//   String formattedDate = DateFormat("MMM dd, yyyy HH:mm").format(dateValue);
//   return formattedDate;
// }
//
// extension NullableString on String? {
//   String? nullableString() {
//     String? trimmedInput = this?.trim();
//     if (trimmedInput == null || trimmedInput.isEmpty) {
//       return null;
//     }
//     return trimmedInput;
//   }
// }
