import 'package:open_filex/open_filex.dart';

void openFile(String filePath) async {
  try {
    // Using open_file package
    final result = await OpenFilex.open(filePath);

    // OR using open_filex package
    // final result = await OpenFilex.open(filePath);

    if (result.type == ResultType.done) {
      print('File opened successfully');
    } else {
      print('Error: ${result.message}');
    }
  } catch (e) {
    print("Error opening file: $e");
  }
}
