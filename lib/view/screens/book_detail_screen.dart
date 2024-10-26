import 'dart:io';
import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/helper/date_formatter.dart';
import 'package:calibre_tablet/services/external_reader.dart';
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
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return GetBuilder(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: AppColor.blackSecondary,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: AppColor.blackSecondary,
              ),
              body: CarouselSlider.builder(
                  itemCount: controller.files.length,
                  options: CarouselOptions(
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      viewportFraction: 1,
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
                          height: double.infinity,
                          width: width * 0.28,
                          decoration: BoxDecoration(
                            color: AppColor.blackSecondary,
                            image: const DecorationImage(
                                image: AssetImage(AppIcons.iconBook)),
                            border: Border.all(
                                color: AppColor.blackSecondary, width: 1),
                          ),
                          child: file.coverImagePath == null
                              ? const SizedBox()
                              : Image.file(
                                  File(file.coverImagePath!),
                                  fit: BoxFit.contain,
                                ),
                        ),
                        SizedBox(
                          width: width * 0.035,
                        ),
                        Container(
                          color: AppColor.blackSecondary,
                          height: double.infinity,
                          width: width * 0.60,
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
                                      fontSize: 42,
                                      fontFamily: AppStyle.helveticaBold,
                                      fontWeight: AppStyle.w600),
                                  SizedBox(
                                    height: height * 0.006,
                                  ),
                                  (file.author ?? " ").toText(
                                      color: AppColor.whitePrimary,
                                      fontSize: 32,
                                      fontFamily: AppStyle.helveticaRegular),
                                  SizedBox(
                                    height: height * 0.005,
                                  ),
                                  (file.publishedDate == null
                                          ? ""
                                          : (formatIsoDateToLongDate(
                                              file.publishedDate!)))
                                      .toText(
                                          color: AppColor.whiteSecondary,
                                          fontSize: 30,
                                          fontFamily:
                                              AppStyle.helveticaRegular),
                                  SizedBox(
                                    height: height * 0.05,
                                  ),
                                  (file.description ?? " ").toText(
                                      maxLine: 19,
                                      color: AppColor.whitePrimary,
                                      fontSize: 38,
                                      fontFamily: AppStyle.helveticaLight,
                                      fontWeight: AppStyle.w300,
                                      lineHeight: 1.3)
                                ],
                              ).paddingSymmetric(vertical: height * 0.002),
                              Container(
                                color: AppColor.blackSecondary,
                                height: height * 0.08,
                                width: width * 0.60,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        DetailFooter(
                                            height: height,
                                            width: width,
                                            title: "Pages",
                                            subtitle:
                                                "${file.totalPages ?? " "}"),
                                        DetailFooter(
                                            width: width,
                                            height: height,
                                            title: "Date Downloaded",
                                            subtitle: (file.downloadDate == null
                                                ? ""
                                                : (formatIsoDateToLongDate(
                                                    file.downloadDate!)))),
                                        // InkWell(
                                        //   onDoubleTap: () {
                                        //     controller
                                        //         .markBookAsReadAndSync(file);
                                        //   },
                                        // child:
                                        DetailFooter(
                                            height: height,
                                            width: width,
                                            title: "Read Status",
                                            subtitle:
                                                file.readStatus ?? "Unread",
                                            isRead: true),
                                        //),
                                      ],
                                    ),
                                    "OPEN BOOK"
                                        .toText(
                                            color: AppColor.whitePrimary,
                                            fontSize: 52,
                                            fontFamily: AppStyle.helveticaBold,
                                            fontWeight: AppStyle.w700)
                                        .onPress(() async {
                                      if (file.filePath != null) {
                                        openFile(file.filePath!);
                                      }
                                    }),
                                  ],
                                ).paddingSymmetric(
                                    vertical: height * 0.01,
                                    horizontal: width * 0.01),
                              ),
                            ],
                          ),
                        )
                      ],
                    ).paddingSymmetric(
                        horizontal: width * 0.02, vertical: height * 0.055);
                  }));
        });
  }
}

class DetailFooter extends StatelessWidget {
  const DetailFooter({
    super.key,
    required this.title,
    required this.subtitle,
    required this.height,
    required this.width,
    this.isRead,
  });

  final String title;
  final String subtitle;
  final double height;
  final double width;
  final bool? isRead;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title.toText(
            color: AppColor.whitePrimary,
            fontSize: 30,
            fontFamily: AppStyle.helveticaBold,
            fontWeight: AppStyle.w500),
        SizedBox(
          height: height * 0.005,
        ),
        isRead == true
            ? Icon(
                Icons.done,
                color: subtitle == "1"
                    ? AppColor.greenPrimary
                    : AppColor.blackSecondary,
              )
            : subtitle.toText(
                color: AppColor.whitePrimary,
                fontSize: 28,
                fontFamily: AppStyle.helveticaRegular),
      ],
    ).paddingOnly(right: width * 0.02);
  }
}
