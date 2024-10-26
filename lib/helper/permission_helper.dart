import 'package:calibre_tablet/helper/shared_preferences.dart';
import 'package:calibre_tablet/view/widgets/custom_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

Future<bool?> requestManageExternalStoragePermission() async {
  // Check the permission status
  var status = await Permission.manageExternalStorage.status;

  // If the permission is denied or permanently denied, request it
  if (status.isDenied) {
    // Request the permission
    status = await Permission.manageExternalStorage.request();
  }

  // If the permission is permanently denied, handle that separately
  if (status.isPermanentlyDenied) {
    // Optionally open the app settings to allow the user to manually enable it
    await openAppSettings();
  }

  if (status.isGranted) {
    // Permission is granted, proceed with storage operations
    print('Manage external storage permission granted.');
    return true;
  } else {
    // Handle the denied status (show a dialog or a message to the user)
    print('Manage external storage permission denied.');
    showToast(message: "External storage permission denied.", isError: true);
    return false;
  }
}

Future<String?> selectFolder() async {
  try {
    String? selectedStorage = await SharedPref.getLocalFolderPath;
    if (selectedStorage != null) {
      return selectedStorage;
    } else {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        // The user canceled the picker
        showToast(
            message: "Please select directory to store files", isError: true);
        print("No directory selected.");
      } else {
        // A directory path is selected
        SharedPref.storeLocalFolderPath(selectedDirectory);
        print("Selected Directory: $selectedDirectory");
      }
      return selectedDirectory;
    }
  } catch (e) {
    showToast(message: "Error : ${e.toString()}", isError: true);
    return null;
  }
}
