// To parse this JSON data, do
//
//     final librariesPathModel = librariesPathModelFromJson(jsonString);

import 'dart:convert';

import 'folder_list_model.dart';

LibrariesPathModel librariesPathModelFromJson(String str) =>
    LibrariesPathModel.fromJson(json.decode(str));

String librariesPathModelToJson(LibrariesPathModel data) =>
    json.encode(data.toJson());

class LibrariesPathModel {
  List<FolderFilePath>? dropboxLibrariesPath;

  LibrariesPathModel({
    this.dropboxLibrariesPath,
  });

  factory LibrariesPathModel.fromJson(Map<String, dynamic> json) =>
      LibrariesPathModel(
        dropboxLibrariesPath: json["dropboxLibrariesPath"] == null
            ? []
            : List<FolderFilePath>.from(json["dropboxLibrariesPath"]!
                .map((x) => FolderFilePath.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "dropboxLibrariesPath": dropboxLibrariesPath == null
            ? []
            : List<dynamic>.from(dropboxLibrariesPath!.map((x) => x.toJson())),
      };
}

