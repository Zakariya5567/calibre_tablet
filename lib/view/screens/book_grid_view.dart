import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/models/file_model.dart';
import 'package:calibre_tablet/utils/colors.dart';
import 'package:calibre_tablet/utils/icons.dart';
import 'package:calibre_tablet/utils/style.dart';
import 'package:calibre_tablet/view/screens/book_detail_screen.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:flutter/material.dart';
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
        itemCount: 20,
        //homeController.files.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final file =FileModel();
          //homeController.files[index];
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
                   width: width*0.092,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.blackPrimary,
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
                    width: width*0.225,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: width*0.18,
                              child: (file.title ?? "").toText(
                                  color: AppColor.whitePrimary,
                                  fontSize: 26,
                                  maxLine: 2,
                                  fontFamily: AppStyle.gothamMedium),
                              ),

                              (file.readStatus != null && file.readStatus == "1")
                                ?
                              Icon(
                                    size: height*0.03,
                                    Icons.check_circle_outline_outlined,
                                    color: AppColor.greenPrimary,
                                  )
                                : const SizedBox(
                                    width: 30,
                                  )
                          ],
                        ),
                        SizedBox(height:  height*0.005),

                        (file.author ?? "").toText(
                            color: AppColor.whiteSecondary,
                            fontSize: 22,
                            maxLine: 2,
                            fontFamily: AppStyle.gothamRegular),
                        SizedBox(height:  height*0.01),

                        (file.description ?? " ").toText(
                            color: AppColor.whiteSecondary,
                            fontSize: 22,
                            fontFamily: AppStyle.gothamRegular,
                            maxLine: 9),
                      ],
                    ).paddingSymmetric(
                        horizontal: width*0.01,
                        vertical: height*0.02
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
