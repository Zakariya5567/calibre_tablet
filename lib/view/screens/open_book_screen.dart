import 'dart:io';
import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/file_model.dart';
import '../../utils/colors.dart';
import 'package:epub_view/epub_view.dart';

import '../../utils/icons.dart';
import '../widgets/no_data_found.dart';

class OpenBookScreen extends StatefulWidget {
  const OpenBookScreen({
    super.key,
    required this.file,
  });
  final FileModel file;

  @override
  State<OpenBookScreen> createState() => _OpenBookScreenState();
}

class _OpenBookScreenState extends State<OpenBookScreen> {
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
      homeController.markBookAsReadAndSync(widget.file);
    }
  }

  @override
  void dispose() {
    _epubReaderController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        //backgroundColor: AppColor.blackPrimary,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_outlined,
                color: AppColor.blackPrimary,
              )),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColor.blackPrimary),
              )
            : EpubView(
                builders: EpubViewBuilders<DefaultBuilderOptions>(
                  errorBuilder: (ctx, e) => const NoDataFound(
                      defaultColor: AppColor.blackPrimary,
                      icon: AppIcons.iconBook,
                      title: "Something went wrong\nTry again later"),
                  loaderBuilder: (ctx) => const Center(
                      child: CircularProgressIndicator(
                          color: AppColor.blackPrimary)),
                  options: const DefaultBuilderOptions(),
                  chapterDividerBuilder: (_) => const Divider(
                    color: AppColor.blackPrimary,
                    height: 3,
                  ),
                ),
                controller: _epubReaderController!,
                onDocumentError: (_) => const NoDataFound(
                    defaultColor: AppColor.blackPrimary,
                    icon: AppIcons.iconBook,
                    title: "Something went wrong\nTry again later"),
              ),
      );
}
