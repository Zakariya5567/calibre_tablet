import 'dart:convert';

RefreshTokenModel refreshTokenModelFromJson(String str) =>
    RefreshTokenModel.fromJson(json.decode(str));
String refreshTokenModelToJson(RefreshTokenModel data) =>
    json.encode(data.toJson());

class RefreshTokenModel {
  String? accessToken;
  String? tokenType;
  int? expiresIn;

  RefreshTokenModel({
    this.accessToken,
    this.tokenType,
    this.expiresIn,
  });

  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) =>
      RefreshTokenModel(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        expiresIn: json["expires_in"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "expires_in": expiresIn,
      };
}
