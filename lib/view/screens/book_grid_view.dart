import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/utils/colors.dart';
import 'package:calibre_tablet/utils/icons.dart';
import 'package:calibre_tablet/utils/style.dart';
import 'package:calibre_tablet/view/screens/book_detail_screen.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';

class BookGridView extends StatelessWidget {
  const BookGridView({super.key, required this.homeController});
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: homeController.files.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final file = homeController.files[index];
          return GestureDetector(
            onTap: () {
              homeController.setPageIndex(index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              color: AppColor.blackPrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 260.w,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.blackSecondary,
                      image: const DecorationImage(
                          image: AssetImage(AppIcons.iconBook)),
                      border:
                          Border.all(color: AppColor.redPrimary, width: 0.2),
                    ),
                    child: file.coverImagePath == null
                        ? const SizedBox()
                        : Image.file(
                            File(file.coverImagePath!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(
                    width: 660.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 550.w,
                              child: (file.title ?? " ").toText(
                                  color: AppColor.whitePrimary,
                                  fontSize: 26,
                                  maxLine: 2,
                                  fontFamily: AppStyle.gothamMedium),
                            ),
                            (file.readStatus != null && file.readStatus == "1")
                                ? Icon(
                                    size: 50.h,
                                    Icons.check_circle_outline_outlined,
                                    color: AppColor.greenPrimary,
                                  )
                                : SizedBox(
                                    width: 50.h,
                                  )
                          ],
                        ),
                        5.height,
                        (file.author ?? " ").toText(
                            color: AppColor.whitePrimary,
                            fontSize: 22,
                            maxLine: 2,
                            fontFamily: AppStyle.gothamRegular),
                        10.height,
                        (file.description ?? " ").toText(
                            color: AppColor.whitePrimary,
                            fontSize: 22,
                            fontFamily: AppStyle.gothamRegular,
                            maxLine: 9),
                      ],
                    ).paddingAll(20.h),
                  )
                ],
              ),
            ),
          );
        });
  }
}
