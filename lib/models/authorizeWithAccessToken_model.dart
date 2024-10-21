class AuthorizeWithAccessTokenModel {
  bool? success;
  String? message;
  String? accessToken;

  AuthorizeWithAccessTokenModel({
    this.success,
    this.message,
    this.accessToken,
  });

  factory AuthorizeWithAccessTokenModel.fromJson(Map<String, dynamic> json) =>
      AuthorizeWithAccessTokenModel(
        success: json["success"],
        message: json["message"],
        accessToken: json["access_token"],
      );

  Map<String, dynamic> toJson() =>
      {"success": success, "message": message, "access_token": accessToken};
}
