import 'dart:io';
import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/models/file_model.dart';
import 'package:calibre_tablet/utils/constant.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import '../../utils/colors.dart';
import '../../utils/icons.dart';
import '../../utils/style.dart';
import '../widgets/no_data_found.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({
    super.key,
    required this.coverImage,
    required this.file,
  });
  final Widget coverImage;
  final FileModel file;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  EpubController? _epubReaderController;
  HomeController homeController = Get.put(HomeController());
  @override
  initState() {
    initializeView();
    super.initState();
  }

  bool isLoading = true;
  initializeView() async {
    _epubReaderController = EpubController(
        document: EpubDocument.openFile(File(widget.file.filePath ?? "")));
    setState(() {
      isLoading = false;
    });
    if (widget.file.readStatus == "0") {
      homeController.onBookRead(widget.file.id!);
    }
  }

  @override
  void dispose() {
    _epubReaderController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColor.blackPrimary,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColor.blackPrimary,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColor.blackPrimary),
              )
            : Row(
                children: [
                  Container(
                    width: 800.w,
                    height: 1620.h,
                    decoration: BoxDecoration(
                      color: AppColor.blackPrimary,
                      image: const DecorationImage(
                          image: AssetImage(AppIcons.iconBook)),
                      border:
                          Border.all(color: AppColor.redPrimary, width: 0.2),
                    ),
                    child: widget.coverImage,
                  ),
                  20.width,
                  Column(
                    children: [
                      Container(
                        color: AppColor.blackPrimary,
                        height: 160.h,
                        width: 2050.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (widget.file.title ?? " ").toText(
                                color: AppColor.whitePrimary,
                                fontSize: 36,
                                fontFamily: AppStyle.gothamBold),
                            10.height,
                            (widget.file.author ?? " ").toText(
                                color: AppColor.whitePrimary,
                                fontSize: 28,
                                fontFamily: AppStyle.gothamRegular),
                            10.height,
                            (widget.file.publishedDate ?? " ").toText(
                                color: AppColor.whiteSecondary,
                                fontSize: 28,
                                fontFamily: AppStyle.gothamRegular),
                          ],
                        ).paddingSymmetric(vertical: 10.h, horizontal: 30.w),
                      ),
                      20.height,
                      Container(
                          color: AppColor.whitePrimary,
                          height: 1310.h,
                          width: 2050.w,
                          child: EpubView(
                            builders: EpubViewBuilders<DefaultBuilderOptions>(
                              errorBuilder: (ctx, e) => const NoDataFound(
                                  defaultColor: AppColor.blackPrimary,
                                  icon: AppIcons.iconBook,
                                  title:
                                      "Something went wrong\nTry again later"),
                              loaderBuilder: (ctx) => const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColor.blackPrimary)),
                              options: const DefaultBuilderOptions(),
                              chapterDividerBuilder: (_) => const Divider(),
                            ),
                            controller: _epubReaderController!,
                          )).paddingOnly(left: 30.w),
                      20.height,
                      Container(
                        color: AppColor.blackPrimary,
                        height: 110.h,
                        width: 2050.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                DetailFooter(
                                    title: "Pages",
                                    subtitle:
                                        "${widget.file.totalPages ?? " "}"),
                                DetailFooter(
                                    title: "Date Downloaded",
                                    subtitle: widget.file.downloadDate ?? " "),
                                DetailFooter(
                                    title: "Read Status",
                                    subtitle: widget.file.readStatus == "1"
                                        ? "Read"
                                        : "Unread"),
                              ],
                            ),
                            "OPEN BOOK".toText(
                                color: AppColor.whitePrimary,
                                fontSize: 36,
                                fontFamily: AppStyle.gothamBold),
                          ],
                        ).paddingSymmetric(vertical: 10.h, horizontal: 30.w),
                      ),
                    ],
                  )
                ],
              ).paddingOnly(left: 30.w, right: 30.w, bottom: 50.h),
      );
}

class DetailFooter extends StatelessWidget {
  const DetailFooter({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title.toText(
            color: AppColor.whitePrimary,
            fontSize: 28,
            fontFamily: AppStyle.gothamMedium),
        15.height,
        subtitle.toText(
            color: AppColor.whitePrimary,
            fontSize: 28,
            fontFamily: AppStyle.gothamRegular),
      ],
    ).paddingOnly(right: 30.w);
  }
}
