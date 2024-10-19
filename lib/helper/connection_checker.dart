import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:calibre_tablet/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../view/widgets/custom_snackbar.dart';

Future<bool> checkInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult.contains(ConnectivityResult.mobile)) {
    if (await InternetConnectionChecker().hasConnection) {
      debugPrint("Connected with mobile");
      return true;
    } else {
      debugPrint("no connection");
      showToast(
          message: AppConstant.checkYourInternetConnection, isError: true);
      return false;
    }
  } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
    if (await InternetConnectionChecker().hasConnection) {
      debugPrint("Connected with wifi");
      return true;
    } else {
      debugPrint("no connection");
      showToast(
          message: AppConstant.checkYourInternetConnection, isError: true);
      return false;
    }
  } else {
    debugPrint(" not Connected");
    showToast(message: AppConstant.checkYourInternetConnection, isError: true);
    return false;
  }
}
