import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/colors.dart';
import '../../utils/icons.dart';

class BookGridShimmer extends StatelessWidget {
  const BookGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return GridView.builder(
        shrinkWrap: true,
        itemCount: 16,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
              baseColor: AppColor.blackPrimary,
              highlightColor: AppColor.blackSecondary,
              child: Container(
                width: double.infinity,
                color: AppColor.blackPrimary.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.blackSecondary,
                        image: const DecorationImage(
                            image: AssetImage(AppIcons.iconBook)),
                        border:
                            Border.all(color: AppColor.redPrimary, width: 0.2),
                      ),
                      width: width*0.092,
                    ),
                    Container(
                      width: width*0.225,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height:  height*0.005),
                          Container(
                            width: width*0.10,
                            height: height*0.03,
                            color: AppColor.blackSecondary,
                          ),
                          SizedBox(height:  height*0.006),
                          Container(
                            width: width*0.15,
                            height: height*0.03,
                            color: AppColor.blackSecondary,
                          ),
                          SizedBox(height:  height*0.006),
                          Container(
                            width: width*0.2,
                            height: height*0.03,
                            color: AppColor.blackSecondary,
                          ),
                          SizedBox(height:  height*0.006),
                          Container(
                            width: width*0.2,
                            height: height*0.03,
                            color: AppColor.blackSecondary,
                          ),
                          SizedBox(height:  height*0.006),
                          Container(
                            width: width*0.18,
                            height: height*0.03,
                            color: AppColor.blackSecondary,
                          ),
                          SizedBox(height:  height*0.006),
                          Container(
                            width: width*0.18,
                            height: height*0.03,
                            color: AppColor.blackSecondary,
                          ),
                        ],
                      ).paddingSymmetric(horizontal: width*0.01,vertical: height*0.01),
                    )
                  ],
                ),
              ));
        }).paddingSymmetric(
      horizontal: width*0.015,
      vertical: height*0.02
    );
  }
}

// class CustomerListShimmer extends StatelessWidget {
//   const CustomerListShimmer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: ListView.builder(
//           padding: EdgeInsets.zero,
//           itemCount: 10,
//           shrinkWrap: true,
//           itemBuilder: (context, index) {
//             return Shimmer.fromColors(
//                 baseColor: AppColor.shimmerBaseColor,
//                 highlightColor: AppColor.shimmerHighlightColor,
//                 child: Container(
//                   height: 70.h,
//                   decoration: BoxDecoration(
//                       border: Border(
//                           bottom: BorderSide(
//                     color: AppColor.whitePrimary.withOpacity(0.5),
//                     width: 1.0,
//                   ))),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         height: 45.h,
//                         width: 45.h,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: AppColor.whitePrimary),
//                       ),
//                       5.width,
//                       SizedBox(
//                           height: 60.w,
//                           width: 130.w,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 height: 16.h,
//                                 width: 140.w,
//                                 color: AppColor.whitePrimary,
//                               ),
//                               5.height,
//                               Container(
//                                 height: 16.h,
//                                 width: 100.w,
//                                 color: AppColor.whitePrimary,
//                               ),
//                             ],
//                           )),
//                       10.width,
//                       SizedBox(
//                         width: 140.w,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Container(
//                               height: 45.h,
//                               width: 45.h,
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: AppColor.whitePrimary),
//                             ),
//                             5.width,
//                             Container(
//                               height: 45.h,
//                               width: 45.h,
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: AppColor.whitePrimary),
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ));
//           }).paddingSymmetric(horizontal: 16.w, vertical: 10.h),
//     );
//   }
// }
