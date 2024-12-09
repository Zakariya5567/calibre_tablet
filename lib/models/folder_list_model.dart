// To parse this JSON data, do
//
//     final folderListModel = folderListModelFromJson(jsonString);

import 'dart:convert';

FolderListModel folderListModelFromJson(String str) =>
    FolderListModel.fromJson(json.decode(str));

String folderListModelToJson(FolderListModel data) =>
    json.encode(data.toJson());

class FolderListResponse {
  final FolderListModel? folderListModel;
  final bool success;
  final bool refresh;

  FolderListResponse(
      {this.folderListModel, required this.success, required this.refresh});
}

class FolderListModel {
  List<Entry>? entries;

  FolderListModel({
    this.entries,
  });

  factory FolderListModel.fromJson(Map<String, dynamic> json) =>
      FolderListModel(
        entries: json["entries"] == null
            ? []
            : List<Entry>.from(json["entries"]!.map((x) => Entry.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "entries": entries == null
            ? []
            : List<dynamic>.from(entries!.map((x) => x.toJson())),
      };
}

class Entry {
  String? tag;
  String? name;
  String? pathLower;
  String? pathDisplay;
  String? id;

  Entry({
    this.tag,
    this.name,
    this.pathLower,
    this.pathDisplay,
    this.id,
  });

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        tag: json[".tag"],
        name: json["name"],
        pathLower: json["path_lower"],
        pathDisplay: json["path_display"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        ".tag": tag,
        "name": name,
        "path_lower": pathLower,
        "path_display": pathDisplay,
        "id": id,
      };
}

// class FolderListModel {
//   bool success;
//   String? message;
//   dynamic paths;
//
//   FolderListModel({
//     required this.success,
//     this.message,
//     this.paths,
//   });
//
//   factory FolderListModel.fromJson(Map<String, dynamic> json) {
//     return FolderListModel(
//       success: json['success'],
//       message: json['message'],
//       paths: json["paths"],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'success': success,
//       'message': message,
//       "paths": paths,
//     };
//   }
// }

class FolderFilePath {
  String? name;
  String? pathLower;
  String? pathDisplay;
  bool? isSelected;

  FolderFilePath({
    this.name,
    this.pathLower,
    this.pathDisplay,
    this.isSelected = false,
  });

  factory FolderFilePath.fromJson(Map<String, dynamic> json) {
    return FolderFilePath(
      name: json['name'],
      pathLower: json['path_lower'],
      pathDisplay: json['path_display'],
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path_lower': pathLower,
      'path_display': pathDisplay,
      'isSelected': isSelected,
    };
  }
}
