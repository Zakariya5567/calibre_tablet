import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/helper/database_helper.dart';
import 'package:calibre_tablet/helper/debouncer.dart';
import 'package:calibre_tablet/helper/shared_preferences.dart';
import 'package:calibre_tablet/services/dropbox_services.dart';
import 'package:calibre_tablet/utils/colors.dart';
import 'package:calibre_tablet/utils/icons.dart';
import 'package:calibre_tablet/view/screens/book_grid_view.dart';
import 'package:calibre_tablet/view/shimmers/book_grid_shimmer.dart';
import 'package:calibre_tablet/view/widgets/button_icon.dart';
import 'package:calibre_tablet/view/widgets/custom_snackbar.dart';
import 'package:calibre_tablet/view/widgets/custom_text_field.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:calibre_tablet/view/widgets/filter_bottomsheet.dart';
import 'package:calibre_tablet/view/widgets/no_data_found.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../helper/permission_helper.dart';
import '../../main.dart';
import '../../models/folder_list_model.dart';
import '../../utils/style.dart';
import '../widgets/folder_selection_dialog.dart';
import '../widgets/sort_bottomsheet.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DatabaseHelper db = DatabaseHelper();
  DropboxService dropboxService = DropboxService();
  HomeController homeController = Get.put(HomeController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Debouncer debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  initializeData() async {
    bool? firstInstall = await SharedPref.getFirstInstall;
    homeController.clearData();
    homeController.fetchAllFiles();
    if (firstInstall != true) {
      await SharedPref.storeFirstInstall(true);
      homeController.getServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColor.defaultStatusBar,
      child: GetBuilder(
          init: HomeController(),
          builder: (controller) {
            return Scaffold(
                key: _scaffoldKey,
                backgroundColor: AppColor.blackPrimary,
                appBar: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: AppColor.blackPrimary,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.sync),
                            onPressed: () {
                              if (controller.isLoading == true) {
                                showToast(
                                    message:
                                        "Sync in progress, please wait.....",
                                    isError: false);
                              } else {
                                homeController.getServices();
                              }
                            }),
                        homeController.isSearching
                            ? CustomTextField(
                                width: width * 0.6,
                                hintText: "Search",
                                fillColor: AppColor.whitePrimary,
                                controller: homeController.searchController,
                                onChanged: (value) {
                                  debouncer.run(() {
                                    homeController.fetchSearchFiles();
                                  });
                                },
                                suffixIcon: ButtonIcon(
                                  color: AppColor.blackPrimary,
                                  icon: AppIcons.iconCross,
                                  onTap: () {
                                    homeController.setSearching();
                                  },
                                ),
                              )
                            : const SizedBox(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                homeController.setSearching();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_alt_outlined),
                              onPressed: () {
                                filterBottomSheet();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.sort),
                              onPressed: () {
                                sortBottomSheet();
                              },
                            ),
                          ],
                        )
                      ],
                    )),
                body: homeController.isLoading == true
                    ? Stack(
                        children: [
                          SizedBox(
                            height: height,
                            width: width,
                          ),
                          const BookGridShimmer(),
                          SizedBox(
                            width: width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Logo of the Error that no data found

                                /// Sync progress
                                controller.syncName == null
                                    ? const SizedBox()
                                    : (controller.syncName ?? "")
                                        .toText(
                                          textAlign: TextAlign.center,
                                          fontSize: 42,
                                          fontFamily: AppStyle.helveticaMedium,
                                          fontWeight: AppStyle.w500,
                                          color: AppColor.whitePrimary,
                                        )
                                        .paddingOnly(bottom: 10.h),

                                /// Download progress
                                controller.itemLibrariesName == null
                                    ? const SizedBox()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          (controller.itemLibrariesName ?? "")
                                              .toText(
                                            textAlign: TextAlign.center,
                                            fontSize: 36,
                                            fontFamily:
                                                AppStyle.helveticaMedium,
                                            fontWeight: AppStyle.w500,
                                            color: AppColor.whitePrimary,
                                          ),
                                          "  ${controller.librariesProgress.toString()} /  ${controller.totalLibrariesItems.toString()}"
                                              .toText(
                                            textAlign: TextAlign.center,
                                            fontSize: 36,
                                            fontFamily:
                                                AppStyle.helveticaMedium,
                                            fontWeight: AppStyle.w500,
                                            color: AppColor.whitePrimary,
                                          ),
                                        ],
                                      ).paddingOnly(bottom: 10.h),
                                //
                                // /// Authors
                                // controller.itemAuthorsName == null
                                //     ? const SizedBox()
                                //     : Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.center,
                                //         children: [
                                //           (controller.itemAuthorsName ?? "")
                                //               .toText(
                                //             textAlign: TextAlign.center,
                                //             fontSize: 36,
                                //             fontFamily:
                                //                 AppStyle.helveticaMedium,
                                //             fontWeight: AppStyle.w500,
                                //             color: AppColor.whitePrimary,
                                //           ),
                                //           "  ${controller.authorsProgress.toString()} / ${controller.totalAuthorsItems.toString()}"
                                //               .toText(
                                //             textAlign: TextAlign.center,
                                //             fontSize: 36,
                                //             fontFamily:
                                //                 AppStyle.helveticaMedium,
                                //             fontWeight: AppStyle.w500,
                                //             color: AppColor.whitePrimary,
                                //           )
                                //         ],
                                //       ).paddingOnly(bottom: 10.h),

                                // ///BOOKS
                                // controller.itemBooksName == null
                                //     ? const SizedBox()
                                //     : Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.center,
                                //         children: [
                                //           (controller.itemBooksName ?? "")
                                //               .toText(
                                //             textAlign: TextAlign.center,
                                //             fontSize: 36,
                                //             fontFamily:
                                //                 AppStyle.helveticaMedium,
                                //             fontWeight: AppStyle.w500,
                                //             color: AppColor.whitePrimary,
                                //           ),
                                //           "  ${controller.booksProgress.toString()} / ${controller.totalBooksItems.toString()}"
                                //               .toText(
                                //             textAlign: TextAlign.center,
                                //             fontSize: 36,
                                //             fontFamily:
                                //                 AppStyle.helveticaMedium,
                                //             fontWeight: AppStyle.w500,
                                //             color: AppColor.whitePrimary,
                                //           )
                                //         ],
                                //       ).paddingOnly(bottom: 10.h),

                                controller.totalAuthorsItems == null
                                    ? SizedBox()
                                    : LinearProgressIndicator(
                                        backgroundColor:
                                            AppColor.whiteSecondary,
                                        color: AppColor.greenPrimary,
                                        value: controller.totalAuthorsItems! > 0
                                            ? controller.authorsProgress! /
                                                controller.totalAuthorsItems!
                                            : 0,
                                        minHeight: 15.h,
                                      ).paddingSymmetric(
                                        horizontal: 50.w, vertical: 10.h),
                                controller.totalAuthorsItems == null
                                    ? const SizedBox()
                                    : Text(
                                        'Downloading: ${(controller.authorsProgress! / controller.totalAuthorsItems! * 100).toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppStyle.helveticaBold,
                                            color: AppColor.whitePrimary),
                                      ),
                              ],
                            ),
                          )
                        ],
                      )
                    : homeController.files.isEmpty
                        ? const NoDataFound(
                            icon: AppIcons.iconBook, title: "No Books Found")
                        : Padding(
                            padding: const EdgeInsets.all(20.0),
                            child:
                                BookGridView(homeController: homeController)));
          }),
    );
  }
}
