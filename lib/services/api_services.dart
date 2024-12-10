import 'dart:convert';
import 'dart:io';

import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../helper/shared_preferences.dart';
import '../models/base_model.dart';
import '../models/dropbox_config.dart';
import '../models/exchange_token_model.dart';
import '../models/folder_list_model.dart';
import '../models/refresh_token_model.dart';
import '../view/widgets/custom_snackbar.dart';
import 'api_repo.dart';

class ApiServices {
  ApiRepo apiRepo = ApiRepo();

  // ********************** Exchange Token **********************

  ExchangeTokenModel exchangeTokenModel = ExchangeTokenModel();
  Future<bool> tokenExchange() async {
    final homeController = Get.find<HomeController>();
    homeController.setTotalDownloading(name: "Connecting Dropbox .....");
    DropboxConfig dropboxConfig = await loadDropboxConfig();
    String dropboxClientId = dropboxConfig.clientId;
    String dropboxSecret = dropboxConfig.secret;
    String? authCode = await SharedPref.getAuthorizationCode;
    try {
      final response = await apiRepo.postRequest(
        url: 'https://api.dropboxapi.com/oauth2/token',
        data: {
          'code': authCode,
          'grant_type': 'authorization_code',
          'client_id': dropboxClientId,
          'client_secret': dropboxSecret,
          'redirect_uri': 'https://www.dropbox.com/1/oauth2/authorize_submit',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        exchangeTokenModel = ExchangeTokenModel.fromJson(response.data);
        SharedPref.storeAccessToken(exchangeTokenModel.accessToken);
        SharedPref.storeRefreshToken(exchangeTokenModel.refreshToken);
        bool result = await refreshToken();
        return result;
      } else if (response.statusCode == 401) {
        bool result = await refreshToken();
        return result;
      } else {
        errorOnAccessToken(
            response.statusCode(), response.statusMessage, homeController);
        return false;
      }
    } catch (e) {
      errorOnAccessToken(e.toString(), "", homeController);
      return false;
    }
  }

  errorOnAccessToken(String statusCode, String statusMessage,
      HomeController homeController) async {
    await SharedPref.storeUserAuthorization(false);
    homeController.setErrorSyncResponseProgress();
    showToast(message: "$statusCode $statusMessage", isError: true);
  }

  // ********************** Refresh Token **********************

  RefreshTokenModel refreshTokenModel = RefreshTokenModel();
  Future<bool> refreshToken() async {
    final homeController = Get.find<HomeController>();
    DropboxConfig dropboxConfig = await loadDropboxConfig();
    String dropboxClientId = dropboxConfig.clientId;
    String dropboxSecret = dropboxConfig.secret;
    String? refreshToken = await SharedPref.getRefreshToken;

    try {
      final response = await apiRepo.postRequest(
        url: 'https://api.dropboxapi.com/oauth2/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': dropboxClientId,
          'client_secret': dropboxSecret,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        refreshTokenModel = RefreshTokenModel.fromJson(response.data);
        SharedPref.storeAccessToken(refreshTokenModel.accessToken);
        return true;
      } else if (response.statusCode == 401) {
        await SharedPref.storeUserAuthorization(false);
        showToast(
            message: "${response.statusCode} ${response.statusMessage}",
            isError: true);
        homeController.setErrorSyncResponseProgress();
        homeController.getServices();
        return false;
      } else {
        showToast(
            message: "${response.statusCode} ${response.statusMessage}",
            isError: true);
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // ********************** Get Folder List **********************
  FolderListModel folderListModel = FolderListModel();
  Future<FolderListResponse> getFolderList(String path) async {
    String? accessToken = await SharedPref.getAccessToken;

    try {
      final response = await apiRepo.postRequest(
          url: "https://api.dropboxapi.com/2/files/list_folder",
          data: {
            "path": path,
            "recursive": false,
            "include_media_info": false,
            "include_deleted": false,
          },
          options: Options(
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              }));
      if (response.statusCode == 200 || response.statusCode == 201) {
        folderListModel = FolderListModel.fromJson(response.data);
        return FolderListResponse(
            success: true, folderListModel: folderListModel, refresh: false);
      } else if (response.statusCode == 401) {
        return FolderListResponse(
            success: false, folderListModel: null, refresh: true);
      } else {
        showToast(
            message: "${response.statusCode} ${response.statusMessage}",
            isError: true);
        return FolderListResponse(
            success: true, folderListModel: null, refresh: false);
      }
    } catch (e) {
      debugPrint(e.toString());
      showToast(
          message: "Something went wrong, Try again later", isError: true);
      return FolderListResponse(
          success: false, folderListModel: null, refresh: false);
    }
  }

  // ********************** Download File **********************

  BaseModel baseModel = BaseModel();
  Future<void> downloadFile(String filePath, String localPath) async {
    String? accessToken = await SharedPref.getAccessToken;
    try {
      final response = await apiRepo.downloadRequest(
        url: "https://content.dropboxapi.com/2/files/download",
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Dropbox-API-Arg': jsonEncode({'path': filePath}),
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await File(localPath).writeAsBytes(response.data);
        debugPrint("File downloaded and saved to $localPath");
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        debugPrint("${response.statusCode}");
      } else {
        debugPrint("${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
