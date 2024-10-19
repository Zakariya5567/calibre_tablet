import 'dart:convert';

import 'package:flutter/services.dart';

class DropboxConfig {
  final String clientId;
  final String key;
  final String secret;
  final String accessToken;

  DropboxConfig({
    required this.clientId,
    required this.key,
    required this.secret,
    required this.accessToken,
  });

  // Factory constructor to create an instance from JSON
  factory DropboxConfig.fromJson(Map<String, dynamic> json) {
    return DropboxConfig(
      clientId: json['dropbox_clientId'],
      key: json['dropbox_key'],
      secret: json['dropbox_secret'],
      accessToken: json['access_token'],
    );
  }

  // Method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'dropbox_clientId': clientId,
      'dropbox_key': key,
      'dropbox_secret': secret,
      'access_token': accessToken,
    };
  }
}

Future<DropboxConfig> loadDropboxConfig() async {
  // Load the JSON file from assets
  String jsonString = await rootBundle.loadString('assets/dropbox.json');

  // Decode the JSON and create a DropboxConfig instance
  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  return DropboxConfig.fromJson(jsonData);
}
