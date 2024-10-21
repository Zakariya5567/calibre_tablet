// import 'package:permission_handler/permission_handler.dart';
//
// Future<void> requestManageExternalStoragePermission() async {
//   // Check the permission status
//   var status = await Permission.manageExternalStorage.status;
//
//   // If the permission is denied or permanently denied, request it
//   if (status.isDenied) {
//     // Request the permission
//     status = await Permission.manageExternalStorage.request();
//   }
//
//   // If the permission is permanently denied, handle that separately
//   if (status.isPermanentlyDenied) {
//     // Optionally open the app settings to allow the user to manually enable it
//     await openAppSettings();
//   }
//
//   if (status.isGranted) {
//     // Permission is granted, proceed with storage operations
//     print('Manage external storage permission granted.');
//   } else {
//     // Handle the denied status (show a dialog or a message to the user)
//     print('Manage external storage permission denied.');
//   }
// }
