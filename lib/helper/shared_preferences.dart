import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/folder_list_model.dart';

class SharedPref {
  static const String _authorized = "authorized";
  static const String _accessToken = "accessToken";
  static const String _refreshToken = "refreshToken";
  static const String _authorizationCode = "authorizationCode";
  static const String _localFolderPath = "localFolderPath";
  static const String _firstInstall = "_firstInstall";
  static const String _dropboxLibrariesPath = "_dropboxLibrariesPath";

  static const String _sortStatus = "_sortStatus";
  static const String _filterStatus = "_filterStatus";
  static const String _orderByStatus = "_orderByStatus";

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

  //Refresh Token ==================================

  static Future<void> storeRefreshToken(String? value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value == null) return;
    sharedPreferences.setString(_refreshToken, value);
  }

  static Future<String?> get getRefreshToken async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(_refreshToken);
    return value;
  }

  //Authorization Code ==================================

  static Future<void> storeAuthorization(String? value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value == null) return;
    sharedPreferences.setString(_authorizationCode, value);
  }

  static Future<String?> get getAuthorizationCode async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(_authorizationCode);
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

//=============================================================================
  static Future<void> storeSelectedLibraries(
      List<FolderFilePath> selectedFolders) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert the list of FolderFilePath objects to JSON
    List<String> jsonList =
        selectedFolders.map((folder) => json.encode(folder.toJson())).toList();

    // Save the JSON list as a string in SharedPreferences
    await prefs.setStringList(_dropboxLibrariesPath, jsonList);
  }

  // Get User Data

  static Future<List<FolderFilePath>> getSelectedLibraries() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON list from SharedPreferences
    List<String>? jsonList = prefs.getStringList(_dropboxLibrariesPath);

    if (jsonList == null) {
      return [];
    }
    // Convert JSON strings back to FolderFilePath objects
    return jsonList
        .map((item) => FolderFilePath.fromJson(json.decode(item)))
        .toList();
  }

  //First Install ==================================

  static Future<bool?> storeFirstInstall(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(_firstInstall, value);
  }

  static Future<bool?> get getFirstInstall async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getBool(_firstInstall);
    return value;
  }

  //Sort Status ==================================
  static Future<void> storeSortStatus(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_sortStatus, value);
  }
  static Future<String?> get getSortStatus async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(_sortStatus);
    return value;
  }

  //Filter Status ==================================
  static Future<void> storeFilterStatus(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_filterStatus, value);
  }
  static Future<String?> get getFilterStatus async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(_filterStatus);
    return value;
  }

  //Order By Status ==================================
  static Future<void> storeOrderByStatus(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_orderByStatus, value);
  }
  static Future<String?> get getOrderByStatus async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(_orderByStatus);
    return value;
  }


}
