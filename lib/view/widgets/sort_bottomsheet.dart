import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/main.dart';
import 'package:calibre_tablet/utils/icons.dart';
import 'package:calibre_tablet/utils/style.dart';
import 'package:calibre_tablet/view/widgets/custom_radio.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';
import 'button_icon.dart';

sortBottomSheet() {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: navKey.currentContext!,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return GetBuilder<HomeController>(builder: (controller) {
        return Container(
            height: 1200.h,
          decoration: const BoxDecoration(
            color: AppColor.blackSecondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonIcon(
                      height: 90.h,
                      width: 90.h,
                      icon: AppIcons.iconCross,
                      onTap: () {
                        Get.back();
                      },
                    ),
                    AppConstant.sortBy.toText(
                      color: AppColor.whitePrimary,
                      fontFamily: AppStyle.helveticaMedium,
                      fontSize: 36,
                    ),
                    30.width,
                  ],
                ),
                40.height,

                ASCDESCItem(
                  title: "Ascending",
                  iconData: AppIcons.iconAscending,
                  onTap: () {
                    controller.seOrderBy("ascending");
                    Get.back();
                  },
                  isActive: controller.selectedOrderBy == "ascending",
                ),
                ASCDESCItem(
                  title: "Descending",
                  iconData: AppIcons.iconDescending,
                  onTap: () {
                    controller.seOrderBy("descending");
                    Get.back();
                  },
                  isActive: controller.selectedOrderBy == "descending",
                ),

                30.height,
                // Sort by Author
                SortItem(
                  title: "Author",
                  iconData: Icons.person,
                  onTap: () {
                    controller.setSelectedSort("authorSort");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "authorSort",
                ),

                // Sort by Book Title
                SortItem(
                  title: "Book Title",
                  iconData: Icons.book,
                  onTap: () {
                    controller.setSelectedSort("title");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "title",
                ),

                // Sort by Date Published
                SortItem(
                  title: "Date Published",
                  iconData: Icons.date_range,
                  onTap: () {
                    controller.setSelectedSort("publishedDate");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "publishedDate",
                ),

                // Sort by Date Downloaded
                SortItem(
                  title: "Date Downloaded",
                  iconData: Icons.download,
                  onTap: () {
                    controller.setSelectedSort("downloadDate");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "downloadDate",
                ),

              ],
            ).paddingSymmetric(horizontal: 40.w, vertical: 40.h),
          ),
        );
      });
    },
  );
}

class SortItem extends StatelessWidget {
  const SortItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.isActive,
    required this.iconData,
  });

  final String title;
  final VoidCallback onTap;
  final bool isActive;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      color: AppColor.blackPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                iconData,
                color: AppColor.whitePrimary,
              ),
              20.width,
              title.toText(
                color: AppColor.whitePrimary,
                fontFamily: AppStyle.helveticaRegular,
                fontSize: 28,
              ),
            ],
          ),
          CustomRadio(isActive: isActive, onTap: onTap)
        ],
      ).paddingAll(28.h),
    ).paddingOnly(bottom: 10.h).onPress(onTap);
  }
}

class ASCDESCItem extends StatelessWidget {
  const ASCDESCItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.isActive,
    required this.iconData,
  });

  final String title;
  final VoidCallback onTap;
  final bool isActive;
  final String iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      width: 380.w,
      decoration: BoxDecoration(
          color: AppColor.blackPrimary,
          border: Border.all(
              color: isActive ? AppColor.greenPrimary : AppColor.blackPrimary)),
      child: Row(
        children: [
          SvgPicture.asset(
            iconData,
            height: 90.h,
            width: 90.h,
            fit: BoxFit.cover,
          ),
          30.width,
          title
              .toText(
                textAlign: TextAlign.center,
                color: AppColor.whitePrimary,
                fontFamily: AppStyle.helveticaRegular,
                fontSize: 28,
              )
              .paddingOnly(bottom: 10.h),
        ],
      ).paddingAll(28.h),
    ).align(Alignment.centerRight).paddingOnly(bottom: 15.h).onPress(onTap);
  }
}
