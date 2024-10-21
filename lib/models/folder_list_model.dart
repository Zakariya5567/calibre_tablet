class FolderListModel {
  bool success;
  String? message;
  dynamic paths;

  FolderListModel({
    required this.success,
    this.message,
    this.paths,
  });

  factory FolderListModel.fromJson(Map<String, dynamic> json) {
    return FolderListModel(
      success: json['success'],
      message: json['message'],
      paths: json["paths"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      "paths": paths,
    };
  }
}

class FolderFilePath {
  String? name;
  String? pathLower;
  String? pathDisplay;

  FolderFilePath({
    this.name,
    this.pathLower,
    this.pathDisplay,
  });

  factory FolderFilePath.fromJson(Map<String, dynamic> json) {
    return FolderFilePath(
      name: json['name'],
      pathLower: json['pathLower'],
      pathDisplay: json['pathDisplay'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pathLower': pathLower,
      'pathDisplay': pathDisplay,
    };
  }
}
