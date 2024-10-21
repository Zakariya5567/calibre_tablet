class BaseModel {
  bool? success;
  String? message;

  BaseModel({
    this.success,
    this.message,
  });

  factory BaseModel.fromJson(Map<String, dynamic> json) => BaseModel(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
