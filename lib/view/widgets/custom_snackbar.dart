import 'package:calibre_tablet/main.dart';
import 'package:calibre_tablet/utils/style.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showToast(
    {required String message, required bool isError}) {
  return ScaffoldMessenger.of(navKey.currentContext!)
      .showSnackBar(_customSnackBar(navKey.currentContext!, message, isError));
}

SnackBar _customSnackBar(BuildContext context, String message, bool isError) {
  return SnackBar(
    duration: const Duration(seconds: 3),
    dismissDirection: DismissDirection.up,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    padding: EdgeInsets.zero,
    content: Container(
      decoration: BoxDecoration(
          color: isError ? AppColor.redPrimary : AppColor.greenPrimary,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: AppColor.blackSecondary,
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(-4, 4),
            ),
          ]),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: message.toText(
              textAlign: TextAlign.start,
              fontSize: 26,
              color: AppColor.whitePrimary,
              fontFamily: AppStyle.gothamMedium),
        ),
      ),
    ),
  );
}
