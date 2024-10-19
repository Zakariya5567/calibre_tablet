import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/widget_extension.dart';
import 'package:flutter/material.dart';

class ButtonIcon extends StatelessWidget {
  const ButtonIcon(
      {super.key,
      this.onTap,
      this.color,
      this.height,
      this.width,
      required this.icon,
      this.userImage});

  final VoidCallback? onTap;
  final String icon;
  final Color? color;
  final double? height;
  final double? width;
  final String? userImage;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      icon,
      height: height ?? 40.h,
      width: width ?? 40.h,
      color: color,
      // colorFilter: ColorFilter.mode(color ?? greyPrimary, BlendMode.src),
    ).onPress(onTap ?? () {});
  }
}
