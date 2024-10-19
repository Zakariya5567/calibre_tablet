import 'package:calibre_tablet/utils/style.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/colors.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle,
      this.iconHeight,
      this.iconWidth,
      this.widgetHeight,
      this.defaultColor});

  final String icon;
  final String title;
  final Color? defaultColor;
  final String? subtitle;
  final double? iconHeight;
  final double? iconWidth;
  final double? widgetHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widgetHeight ?? double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo of the Error that no data found
          Image.asset(
            icon,
            color: defaultColor ?? AppColor.whitePrimary,
            height: iconHeight ?? 150.h,
            width: iconWidth ?? 150.w,
          ).paddingOnly(bottom: 12.h),
          title
              .toText(
                maxLine: 2,
                textAlign: TextAlign.center,
                fontSize: 22,
                fontFamily: AppStyle.gothamMedium,
                fontWeight: AppStyle.w500,
                color: defaultColor ?? AppColor.whitePrimary,
              )
              .paddingOnly(bottom: 5.h),
          subtitle == null
              ? const SizedBox()
              : (subtitle ?? "").toText(
                  maxLine: 2,
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  fontFamily: AppStyle.gothamRegular,
                  fontWeight: AppStyle.w500,
                  color: defaultColor ?? AppColor.whitePrimary,
                ),
        ],
      ).paddingSymmetric(
        horizontal: 65.w,
      ),
    );
  }
}
