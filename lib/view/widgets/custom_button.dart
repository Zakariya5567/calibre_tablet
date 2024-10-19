import 'package:calibre_tablet/utils/style.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/widget_extension.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'extention/border_extension.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.buttonName,
    required this.onPressed,
    this.buttonTextColor = AppColor.whitePrimary,
    this.buttonColor = AppColor.greenPrimary,
    this.borderColor = AppColor.greenPrimary,
    this.height,
    this.width,
    this.radius = 5,
    this.textSize = 16,
  });

  final String buttonName;
  final VoidCallback onPressed;
  final Color buttonTextColor;
  final Color buttonColor;
  final Color borderColor;
  final double? height;
  final double? width;
  final double radius;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Container(
            height: height ?? 55.h,
            width: width ?? 358.w,
            decoration: BoxDecoration(
              borderRadius: borderRadiusCircular(radius),
              border: Border.all(color: borderColor),
              color: buttonColor,
            ),
            child: Text(
              buttonName,
              style: TextStyle(
                  color: buttonTextColor,
                  fontSize: textSize,
                  fontWeight: AppStyle.w600),
            ).center));
  }
}
