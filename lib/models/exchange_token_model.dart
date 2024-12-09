import 'dart:convert';

ExchangeTokenModel exchangeTokenModelFromJson(String str) =>
    ExchangeTokenModel.fromJson(json.decode(str));
String exchangeTokenModelToJson(ExchangeTokenModel data) =>
    json.encode(data.toJson());

class ExchangeTokenModel {
  String? accessToken;
  String? tokenType;
  int? expiresIn;
  String? refreshToken;
  String? scope;
  String? uid;
  String? accountId;

  ExchangeTokenModel({
    this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.refreshToken,
    this.scope,
    this.uid,
    this.accountId,
  });

  factory ExchangeTokenModel.fromJson(Map<String, dynamic> json) =>
      ExchangeTokenModel(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        expiresIn: json["expires_in"],
        refreshToken: json["refresh_token"],
        scope: json["scope"],
        uid: json["uid"],
        accountId: json["account_id"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "expires_in": expiresIn,
        "refresh_token": refreshToken,
        "scope": scope,
        "uid": uid,
        "account_id": accountId,
      };
}
