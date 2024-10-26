import 'package:calibre_tablet/main.dart';
import 'package:calibre_tablet/models/folder_list_model.dart';
import 'package:calibre_tablet/utils/colors.dart';
import 'package:calibre_tablet/view/widgets/extention/int_extension.dart';
import 'package:calibre_tablet/view/widgets/extention/string_extension.dart';
import 'package:flutter/material.dart';
import '../../utils/style.dart';
import 'package:get/get.dart';

class FolderSelectionDialog extends StatefulWidget {
  final List<FolderFilePath> folders;

  FolderSelectionDialog({required this.folders});

  @override
  _FolderSelectionDialogState createState() => _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends State<FolderSelectionDialog> {
  List<FolderFilePath> selectedFolders = [];
  bool isSelectAll = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: AppColor.blackSecondary,
      alignment: Alignment.center,
      title: Column(
        children: [
          "Select Libraries to Download".toText(
              textAlign: TextAlign.center,
              color: AppColor.whitePrimary,
              fontSize: 42,
              fontFamily: AppStyle.helveticaBold,
              fontWeight: AppStyle.w600),
          100.height,
          Container(
              height: 120.h,
              color: AppColor.blackPrimary,
              child: CheckboxListTile(
                title: "Select All".toText(
                    color: AppColor.whitePrimary,
                    fontSize: 34,
                    fontFamily: AppStyle.helveticaRegular,
                    fontWeight: AppStyle.w400),
                checkColor: AppColor.whitePrimary,
                fillColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? AppColor.greenPrimary
                        : AppColor.whitePrimary),
                value: isSelectAll,
                onChanged: (bool? value) {
                  setState(() {
                    isSelectAll = value ?? false;
                    for (var folder in widget.folders) {
                      folder.isSelected = isSelectAll;
                      if (isSelectAll) {
                        if (!selectedFolders.contains(folder)) {
                          selectedFolders.add(folder);
                        }
                      } else {
                        selectedFolders.clear();
                      }
                    }
                  });
                },
              )),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Container(
        width: MediaQuery.sizeOf(navKey.currentContext!).width / 2,
        child: SingleChildScrollView(
          child: ListBody(
            children: widget.folders.map((folder) {
              return Container(
                height: 120.h,
                color: AppColor.blackPrimary,
                child: CheckboxListTile(
                  checkColor: AppColor.whitePrimary,
                  checkboxShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    side: BorderSide(color: AppColor.whitePrimary),
                  ),
                  fillColor: WidgetStateProperty.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? AppColor.greenPrimary
                          : AppColor.whitePrimary),
                  title: (folder.name ?? " ").toText(
                      color: AppColor.whitePrimary,
                      fontSize: 34,
                      fontFamily: AppStyle.helveticaRegular,
                      fontWeight: AppStyle.w400),
                  value: folder.isSelected,
                  onChanged: (bool? selected) {
                    setState(() {
                      folder.isSelected = selected ?? false;
                      if (folder.isSelected!) {
                        selectedFolders.add(folder);
                      } else {
                        selectedFolders.remove(folder);
                        isSelectAll =
                            selectedFolders.length == widget.folders.length;
                      }
                    });
                  },
                ),
              ).paddingOnly(bottom: 10.h);
            }).toList(),
          ),
        ),
      ),
      actionsPadding: EdgeInsets.only(top: 0, bottom: 30.h, right: 50.w),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, selectedFolders), // Pass selected folders
          child: "Continue".toText(
              textAlign: TextAlign.center,
              color: AppColor.whitePrimary,
              fontSize: 42,
              fontFamily: AppStyle.helveticaRegular,
              fontWeight: AppStyle.w600),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context), // Close without selection
          child: "Cancel".toText(
              textAlign: TextAlign.center,
              color: AppColor.whitePrimary,
              fontSize: 42,
              fontFamily: AppStyle.helveticaRegular,
              fontWeight: AppStyle.w600),
        ),
      ],
    );
  }
}

// class FolderSelectionDialog extends StatefulWidget {
//   final List<FolderFilePath> folders;
//
//   FolderSelectionDialog({required this.folders});
//
//   @override
//   _FolderSelectionDialogState createState() => _FolderSelectionDialogState();
// }
//
// class _FolderSelectionDialogState extends State<FolderSelectionDialog> {
//   List<FolderFilePath> selectedFolders = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       insetPadding: EdgeInsets.zero,
//       backgroundColor: AppColor.blackSecondary,
//       alignment: Alignment.center,
//       title: "Select Libraries to Download".toText(
//           textAlign: TextAlign.center,
//           color: AppColor.whitePrimary,
//           fontSize: 42,
//           fontFamily: AppStyle.helveticaBold,
//           fontWeight: AppStyle.w600),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       content: Container(
//         width: MediaQuery.sizeOf(navKey.currentContext!).width / 2,
//         child: SingleChildScrollView(
//           child: ListBody(
//             children: widget.folders.map((folder) {
//               return Container(
//                 height: 120.h,
//                 color: AppColor.blackPrimary,
//                 child: CheckboxListTile(
//                   checkColor: AppColor.whitePrimary,
//                   checkboxShape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(2)),
//                       side: BorderSide(color: AppColor.whitePrimary)),
//                   fillColor: WidgetStateProperty.resolveWith(
//                       (Set<WidgetState> states) {
//                     if (states.contains(WidgetState.selected)) {
//                       return AppColor.greenPrimary; // Color when checked
//                     }
//                     return AppColor.whitePrimary; // Color when unchecked
//                   }),
//                   title: (folder.name ?? " ").toText(
//                       color: AppColor.whitePrimary,
//                       fontSize: 34,
//                       fontFamily: AppStyle.helveticaRegular,
//                       fontWeight: AppStyle.w400),
//                   value: folder.isSelected,
//                   onChanged: (bool? selected) {
//                     setState(() {
//                       folder.isSelected = selected ?? false;
//                       if (folder.isSelected ?? false) {
//                         selectedFolders.add(folder);
//                       } else {
//                         selectedFolders.remove(folder);
//                       }
//                     });
//                   },
//                 ),
//               ).paddingOnly(bottom: 10.h);
//             }).toList(),
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () =>
//               Navigator.pop(context, selectedFolders), // Pass selected folders
//           child: Text("Continue"),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context), // Close without selection
//           child: Text("Cancel"),
//         ),
//       ],
//     );
//   }
// }
