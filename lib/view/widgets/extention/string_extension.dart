import 'package:calibre_tablet/utils/colors.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:flutter/material.dart';

extension StringExtension on String {
  Widget toText(
          {Color? color,
          double? fontSize,
          int? maxLine,
          TextAlign? textAlign,
          TextOverflow? overflow,
          String? fontFamily,
          FontWeight? fontWeight,
          Color? backgroundColor,
          double? lineHeight,
          bool? isBold,
          bool? isMedium}) =>
      Text(
        this,
        maxLines: maxLine,
        textAlign: textAlign,
        style: TextStyle(
          height: lineHeight,
          backgroundColor: backgroundColor,
          color: color ?? AppColor.blackSecondary,
          fontSize: (fontSize ?? 12).toInt().h,
          fontFamily: fontFamily,
          fontStyle: FontStyle.normal,
          overflow: overflow ?? TextOverflow.ellipsis,
          fontWeight: fontWeight ??
              (isBold == true
                  ? FontWeight.bold
                  : (isMedium == true ? FontWeight.w500 : FontWeight.w400)),
        ),
      );
}
