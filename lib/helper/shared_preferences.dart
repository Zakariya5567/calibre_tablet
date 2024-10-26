import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static const String _authorized = "authorized";
  static const String _accessToken = "accessToken";
  static const String _localFolderPath = "localFolderPath";
  static const String _dropboxFolderPath = "_dropboxFolderPath";

  //User Authorization ==================================

  static Future<void> storeUserAuthorization(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(_authorized, value);
  }

  static Future<bool?> get getUserAuthorization async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getBool(_authorized);
    return value;
  }

  //Access Token ==================================

  static Future<void> storeAccessToken(String? value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value == null) return;
    sharedPreferences.setString(_accessToken, value);
  }

  static Future<String?> get getAccessToken async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(_accessToken);
    return value;
  }

  //Local Folder Path==================================

  static Future<void> storeLocalFolderPath(String? value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value == null) return;
    sharedPreferences.setString(_localFolderPath, value);
  }

  static Future<String?> get getLocalFolderPath async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(_localFolderPath);
    return value;
  }

  //Dropbox Folder path ==================================

  static Future<void> storeDropboxFolder(String? value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value == null) return;
    sharedPreferences.setString(_dropboxFolderPath, value);
  }

  static Future<String?> get getDropboxFolder async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(_dropboxFolderPath);
    return value;
  }
}
