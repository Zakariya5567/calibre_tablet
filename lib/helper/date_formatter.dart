import 'package:intl/intl.dart';

String formatIsoDateToLongDate(String isoDate) {
  // Parse the ISO string back to a DateTime object
  DateTime parsedDate = DateTime.parse(isoDate);

  // Format the DateTime object to 'MMMM, dd, yyyy' (e.g., March 21, 2024)
  return DateFormat('MMMM dd, yyyy').format(parsedDate);
}
