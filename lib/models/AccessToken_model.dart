class AccessTokenModel {
  bool? success;
  String? message;
  String? accessToken;

  AccessTokenModel({
    this.success,
    this.message,
    this.accessToken,
  });

  factory AccessTokenModel.fromJson(Map<String, dynamic> json) =>
      AccessTokenModel(
        success: json["success"],
        message: json["message"],
        accessToken: json["accessToken"],
      );

  Map<String, dynamic> toJson() =>
      {"success": success, "message": message, "accessToken": accessToken};
}
