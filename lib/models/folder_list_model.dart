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
      pathLower: json['pathLower'],
      pathDisplay: json['pathDisplay'],
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pathLower': pathLower,
      'pathDisplay': pathDisplay,
      'isSelected': isSelected,
    };
  }
}
