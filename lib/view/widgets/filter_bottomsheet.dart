import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/main.dart';
import 'package:calibre_tablet/utils/icons.dart';
import 'package:calibre_tablet/utils/style.dart';
import 'package:calibre_tablet/view/widgets/custom_radio.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';
import 'button_icon.dart';

filterBottomSheet() {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: navKey.currentContext!,
    builder: (BuildContext context) {
      return GetBuilder<HomeController>(
        builder: (controller) {
          return Container(
            height: 700.h,
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
                      AppConstant.filterBy.toText(
                        color: AppColor.whitePrimary,
                        fontFamily: AppStyle.helveticaMedium,
                        fontSize: 36,
                      ),
                      30.width,
                    ],
                  ),
                  50.height,
                  FilterItem(
                    onTap: () {
                      controller.setSelectedFilter("1");
                      Get.back();
                    },
                    title: "Read",
                    isActive: controller.selectedFiler == "1" ? true : false,
                  ),
                  FilterItem(
                    onTap: () {
                      controller.setSelectedFilter("0");
                      Get.back();
                    },
                    title: "Unread",
                    isActive: controller.selectedFiler == "0" ? true : false,
                  ),
                  FilterItem(
                    onTap: () {
                      controller.setSelectedFilter("all");
                      Get.back();
                    },
                    title: "All",
                    isActive: controller.selectedFiler == "all" ? true : false,
                  ),
                ],
              ).paddingSymmetric(horizontal: 40.w, vertical: 40.h),
            ),
          );
        },
      );
    },
  );
}

class FilterItem extends StatelessWidget {
  const FilterItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.isActive,
  });

  final String title;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      color: AppColor.blackPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title.toText(
              color: AppColor.whitePrimary,
              fontFamily: AppStyle.helveticaRegular,
              fontSize: 28),
          CustomRadio(isActive: isActive, onTap: onTap),
        ],
      ).paddingAll(28.h),
    ).paddingOnly(bottom: 10.h).onPress(onTap);
  }
}

///===================================
// filterBottomSheet() {
//   return showModalBottomSheet(
//     backgroundColor: Colors.transparent,
//     context: navKey.currentContext!,
//     builder: (BuildContext context) {
//       return
//         GetBuilder<HomeController>(
//           builder:(controller) {
//             return Container(
//             height: 700.h,
//             decoration: const BoxDecoration(
//                 color: AppColor.blackSecondary,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 )),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//
//                       ButtonIcon(
//                         height: 90.h,
//                         width: 90.h,
//                         icon: AppIcons.iconCross,onTap: (){Get.back();},),
//                      AppConstant.filterBy.toText(color: AppColor.whitePrimary,fontFamily: AppStyle.helveticaMedium,fontSize: 36),
//                       30.width,
//                     ],
//                   ),
//                   50.height,
//                   FilterItem(
//                     onTap: (){
//                       controller.setSelectedFilter("Name");
//                       Get.back();
//                     },
//                     title:  AppConstant.filterByName,
//                     isActive: controller.selectedFiler == "Name" ? true :false,
//                   ),
//                   FilterItem(
//                       onTap: (){
//                         controller.setSelectedFilter("Author");
//                         Get.back();
//                       },
//                       title: AppConstant.filterByAuthor,
//                       isActive: controller.selectedFiler == "Author" ? true :false,
//                   ),
//                 ],
//               ).paddingSymmetric(horizontal: 40.w, vertical: 40.h),
//             ),
//                   );
//           }
//         );
//     },
//   );
// }
// class FilterItem extends StatelessWidget {
//   const FilterItem({super.key,required this.onTap,required this.title,required this.isActive});
//
//   final String title;
//   final VoidCallback onTap;
//   final bool isActive;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 120.h,
//       color: AppColor.blackPrimary,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//            title.toText(color: AppColor.whitePrimary,fontFamily: AppStyle.helveticaRegular,fontSize: 28),
//            CustomRadio(isActive: isActive, onTap: onTap)
//         ],
//       ).paddingAll(28.h),
//     ).paddingOnly(bottom: 10.h).onPress(onTap);
//   }
// }
