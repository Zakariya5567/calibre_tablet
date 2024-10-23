import 'dart:io';
import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/view/screens/open_book_screen.dart';
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
  Widget build(BuildContext context){

    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return  GetBuilder(
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
                          width: width*0.28,
                          decoration: BoxDecoration(
                            color: AppColor.blackPrimary,
                            image: const DecorationImage(
                                image: AssetImage(AppIcons.iconBook)),
                            border: Border.all(
                                color: AppColor.redPrimary, width: 0.1),
                          ),
                          child: file.coverImagePath == null ? const SizedBox():Image.file(
                            File(file.coverImagePath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: width*0.035,),
                        Container(
                          color: AppColor.blackPrimary,
                          height: double.infinity,
                          width: width*0.60,
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
                                      fontSize: 52,
                                      fontFamily: AppStyle.gothamBold),
                                  SizedBox(height: height*0.005,),
                                  (file.author ?? " ").toText(
                                      color: AppColor.whitePrimary,
                                      fontSize: 36,
                                      fontFamily: AppStyle.gothamMedium),
                                  SizedBox(height: height*0.005,),
                                  (file.publishedDate ?? " ").toText(
                                      color: AppColor.whiteSecondary,
                                      fontSize: 30,
                                      fontFamily: AppStyle.gothamRegular),
                                  SizedBox(height: height*0.05,),
                                  (file.description ?? " ").toText(
                                    maxLine: 30,
                                    color: AppColor.whitePrimary,
                                    fontSize: 28,
                                    fontWeight: AppStyle.w500,
                                    fontFamily: AppStyle.gothamRegular,
                                  )
                                ],
                              ).paddingSymmetric(
                                  vertical: height*0.002),
                              Container(
                                color: AppColor.blackPrimary,
                                height: height*0.08,
                                width:width*0.60,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        DetailFooter(
                                            height: height,
                                            title: "Pages",
                                            subtitle:
                                            "${file.totalPages ?? " "}"),
                                        DetailFooter(
                                            height: height,
                                            title: "Date Downloaded",
                                            subtitle: file.downloadDate ?? " "),
                                        DetailFooter(
                                            height: height,
                                            title: "Read Status",
                                            subtitle: file.readStatus ?? "Unread",
                                            isRead: true),
                                      ],
                                    ),
                                    "OPEN BOOK"
                                        .toText(
                                        color: AppColor.whitePrimary,
                                        fontSize: 52,
                                        fontFamily: AppStyle.gothamBold)
                                        .onPress(() async {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                            return OpenBookScreen(file: file);
                                          }));
                                    }),
                                  ],
                                ).paddingSymmetric(
                                    vertical: height*0.01, horizontal: width*0.01),
                              ),
                            ],
                          ),
                        )
                      ],
                    ).paddingSymmetric(
                        horizontal: width*0.02, vertical:height*0.055);
                  }));
        });
  }
}

class DetailFooter extends StatelessWidget {
  const DetailFooter(
      {super.key, required this.title, required this.subtitle,required this.height, this.isRead,});

  final String title;
  final String subtitle;
  final double height;
  final bool? isRead;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title.toText(
            color: AppColor.whitePrimary,
            fontSize: 28,
            fontFamily: AppStyle.gothamMedium),
        SizedBox(height:height*0.01 ,),
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
    ).paddingOnly(right: height*0.1);
  }
}
