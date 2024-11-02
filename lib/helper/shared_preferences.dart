import 'dart:convert';

import 'package:calibre_tablet/models/libraries_path_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/folder_list_model.dart';

class SharedPref {
  static const String _authorized = "authorized";
  static const String _accessToken = "accessToken";
  static const String _localFolderPath = "localFolderPath";
  static const String _firstInstall = "_firstInstall";
  static const String _dropboxLibrariesPath = "_dropboxLibrariesPath";

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
}
