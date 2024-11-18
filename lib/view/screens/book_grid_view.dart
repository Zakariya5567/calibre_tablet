import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/utils/colors.dart';
import 'package:calibre_tablet/utils/icons.dart';
import 'package:calibre_tablet/utils/style.dart';
import 'package:calibre_tablet/view/screens/book_detail_screen.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:io';
import 'package:get/get.dart';

class BookGridView extends StatelessWidget {
  const BookGridView({super.key, required this.homeController});
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
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
                    width: width * 0.092,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.blackPrimary,
                      image: const DecorationImage(
                          image: AssetImage(AppIcons.iconBook)),
                      border: Border.all(
                          color: AppColor.blackSecondary, width: 0.1),
                    ),
                    child: file.coverImagePath == null
                        ? const SizedBox()
                        : Image.file(
                            File(file.coverImagePath!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(
                    width: width * 0.225,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: width * 0.18,
                                  child: (file.title ?? "").toText(
                                      color: AppColor.whitePrimary,
                                      fontSize: 30,
                                      maxLine: 2,
                                      fontFamily: AppStyle.helveticaMedium,
                                      fontWeight: AppStyle.w400),
                                ),
                                (file.readStatus != null &&
                                        file.readStatus == "1")
                                    ? Icon(
                                        size: height * 0.027,
                                        Icons.check_circle_outline_outlined,
                                        color: AppColor.greenPrimary,
                                      )
                                    : const SizedBox(
                                        width: 30,
                                      )
                              ],
                            ),
                            SizedBox(height: height * 0.003),
                            (file.author ?? "").toText(
                                color: AppColor.whiteSecondary,
                                fontSize: 22,
                                maxLine: 2,
                                fontFamily: AppStyle.helveticaMedium,
                                fontWeight: AppStyle.w500),
                          ],
                        ).paddingSymmetric(
                          horizontal: width * 0.01,
                        ),
                        SizedBox(height: height * 0.003),

                        ///-===============
                        SizedBox(
                            height: height * 0.147,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Html(
                                data: file.description ??
                                    "No description available",
                                style: {
                                  "html": Style(
                                      color: AppColor.whiteSecondary,
                                      fontFamily: AppStyle.helveticaRegular,
                                      fontSize: FontSize(10)),
                                  "b": Style(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.whiteSecondary,
                                      fontFamily: AppStyle.helveticaRegular,
                                      fontSize: FontSize(10)),
                                  "i": Style(
                                      fontStyle: FontStyle.italic,
                                      color: AppColor.whiteSecondary,
                                      fontFamily: AppStyle.helveticaRegular,
                                      fontSize: FontSize(10)),
                                  "u": Style(
                                      textDecoration: TextDecoration.underline,
                                      color: AppColor.whiteSecondary,
                                      fontFamily: AppStyle.helveticaRegular,
                                      fontSize: FontSize(10)),
                                },
                              ).paddingSymmetric(
                                horizontal: width * 0.005,
                              ),
                            ))

                        ///-===============
                        // (file.description ?? " ").toText(
                        //     color: AppColor.whiteSecondary,
                        //     fontSize: 22,
                        //     fontFamily: AppStyle.helveticaRegular,
                        //     maxLine: 8),
                      ],
                    ).paddingSymmetric(vertical: height * 0.005),
                  )
                ],
              ),
            ),
          );
        });
  }
}
