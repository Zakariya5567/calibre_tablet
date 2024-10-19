import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {

  static const String  _authorized = "authorized";
  static const String  _accessToken = "accessToken";


  static Future<void> storeUserAuthorization(bool value)async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(_authorized, value);
  }

  static Future<bool?> get getUserAuthorization async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getBool(_authorized);
    return value;
  }

  //==================================

  static Future<void> storeAccessToken(String? value)async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(value == null) return;
    sharedPreferences.setString(_accessToken, value);
  }

  static Future<String?> get getAccessToken async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final value = sharedPreferences.getString(_accessToken);
    return value;
  }

}