import 'dart:io';
import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/services/external_reader.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/icons.dart';
import '../../utils/style.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({
    super.key,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  Widget build(BuildContext context) => GetBuilder(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: AppColor.blackPrimary,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColor.blackPrimary,
            ),
            body: CarouselSlider.builder(
                itemCount: controller.files.length,
                options: CarouselOptions(
                    autoPlay: false,
                    enableInfiniteScroll: false,
                    // enlargeCenterPage: true,
                    viewportFraction: 1,
                    // aspectRatio: 1.0,
                    initialPage: controller.currentPage,
                    onPageChanged: (currentIndex, reason) {
                      controller.setPageIndex(currentIndex);
                    }),
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  final file = controller.files[itemIndex];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 750.w,
                        height: 1470.h,
                        decoration: BoxDecoration(
                          color: AppColor.blackPrimary,
                          image: const DecorationImage(
                              image: AssetImage(AppIcons.iconBook)),
                          border: Border.all(
                              color: AppColor.redPrimary, width: 0.1),
                        ),
                        child: Image.file(
                          File(file.coverImagePath!),
                          fit: BoxFit.cover,
                          width: 750.w,
                          height: 1470.h,
                        ),
                      ),
                      60.width,
                      Container(
                        color: AppColor.blackPrimary,
                        height: 1470.h,
                        width: 2050.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (file.title ?? " ").toText(
                                    color: AppColor.whitePrimary,
                                    fontSize: 36,
                                    fontFamily: AppStyle.gothamBold),
                                10.height,
                                (file.author ?? " ").toText(
                                    color: AppColor.whitePrimary,
                                    fontSize: 28,
                                    fontFamily: AppStyle.gothamRegular),
                                10.height,
                                (file.publishedDate ?? " ").toText(
                                    color: AppColor.whiteSecondary,
                                    fontSize: 28,
                                    fontFamily: AppStyle.gothamRegular),
                                100.height,
                                (file.description ?? " ").toText(
                                  maxLine: 30,
                                  color: AppColor.whitePrimary,
                                  fontSize: 28,
                                  fontWeight: AppStyle.w500,
                                  fontFamily: AppStyle.gothamRegular,
                                )
                              ],
                            ).paddingSymmetric(
                                vertical: 10.h, horizontal: 30.w),
                            Container(
                              color: AppColor.blackPrimary,
                              height: 120.h,
                              width: 2050.w,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      DetailFooter(
                                          title: "Pages",
                                          subtitle:
                                              "${file.totalPages ?? " "}"),
                                      DetailFooter(
                                          title: "Date Downloaded",
                                          subtitle: file.downloadDate ?? " "),
                                      DetailFooter(
                                          title: "Read Status",
                                          subtitle: file.readStatus ?? "Unread",
                                          isRead: true),
                                    ],
                                  ),
                                  "OPEN BOOK"
                                      .toText(
                                          color: AppColor.whitePrimary,
                                          fontSize: 36,
                                          fontFamily: AppStyle.gothamBold)
                                      .onPress(() async {
                                    if (file.filePath != null) {
                                      openFile(file.filePath!);
                                    }
                                  }),
                                ],
                              ).paddingSymmetric(
                                  vertical: 10.h, horizontal: 30.w),
                            ),
                          ],
                        ),
                      )
                    ],
                  ).paddingOnly(
                      left: 50.w, right: 50.w, bottom: 80.h, top: 80.h);
                }));
      });
}

class DetailFooter extends StatelessWidget {
  const DetailFooter(
      {super.key, required this.title, required this.subtitle, this.isRead});

  final String title;
  final String subtitle;
  final bool? isRead;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title.toText(
            color: AppColor.whitePrimary,
            fontSize: 28,
            fontFamily: AppStyle.gothamMedium),
        10.height,
        isRead == true
            ? Icon(
                Icons.done,
                color: subtitle == "1"
                    ? AppColor.greenPrimary
                    : AppColor.blackPrimary,
              )
            : subtitle.toText(
                color: AppColor.whitePrimary,
                fontSize: 28,
                fontFamily: AppStyle.gothamRegular),
      ],
    ).paddingOnly(right: 40.w);
  }
}
