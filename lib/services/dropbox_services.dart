import 'dart:convert';
import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/helper/database_helper.dart';
import 'package:calibre_tablet/main.dart';
import 'package:calibre_tablet/models/AccessToken_model.dart';
import 'package:calibre_tablet/models/authorizeWithAccessToken_model.dart';
import 'package:calibre_tablet/models/base_model.dart';
import 'package:calibre_tablet/models/folder_list_model.dart';
import 'package:calibre_tablet/view/widgets/custom_snackbar.dart';
import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:xml/xml.dart';
import '../helper/shared_preferences.dart';
import '../models/dropbox_config.dart';
import 'package:get/get.dart';
import '../view/widgets/folder_selection_dialog.dart';

class DropboxService {
  DatabaseHelper db = DatabaseHelper();

  Future<bool?> initDropbox() async {
    DropboxConfig dropboxConfig = await loadDropboxConfig();
    String dropboxClientId = dropboxConfig.clientId;
    String dropboxKey = dropboxConfig.key;
    String dropboxSecret = dropboxConfig.secret;
    try {
      final result =
          await Dropbox.init(dropboxClientId, dropboxKey, dropboxSecret);
      BaseModel baseModel = BaseModel.fromJson(result);
      if (baseModel.success == true) {
        return baseModel.success;
      } else {
        showToast(
            message: baseModel.message ?? "Dropbox initialization error",
            isError: true);
        return baseModel.success;
      }
    } catch (e) {
      showToast(message: "Dropbox initialization error", isError: true);
      return false;
    }
  }

  Future<bool?> authorize() async {
    HomeController controller = Get.put(HomeController());
    controller.setTotalDownloading(name: "Connecting Dropbox .....");
    final result = await Dropbox.authorize();

    ///================== First time to get dropbox files ====================///
    await Future.delayed(const Duration(seconds: 5));
    final BaseModel baseModel = BaseModel.fromJson(result);
    if (baseModel.success == true) {
      return baseModel.success;
    } else {
      showToast(
          message: baseModel.message ?? "Authorization error", isError: true);
      return baseModel.success;
    }
  }

  Future<String?> getAccessToken() async {
    var result = await Dropbox.getAccessToken();
    AccessTokenModel accessTokenModel = AccessTokenModel.fromJson(result!);
    if (accessTokenModel.success == true) {
      return accessTokenModel.accessToken;
    } else {
      showToast(
          message: accessTokenModel.message ?? "Access Token error",
          isError: true);
      return null;
    }
  }

  Future<bool?> authorizeWithAccessToken(String token) async {
    String accessToken = token;
    final result = await Dropbox.authorizeWithAccessToken(accessToken);
    AuthorizeWithAccessTokenModel authorizeWithAccessTokenModel =
        AuthorizeWithAccessTokenModel.fromJson(result);
    if (authorizeWithAccessTokenModel.success == true) {
      return authorizeWithAccessTokenModel.success;
    } else {
      showToast(
          message: authorizeWithAccessTokenModel.message ??
              "Access Token Authorization error",
          isError: true);
      return authorizeWithAccessTokenModel.success;
    }
  }

  Future<bool> syncDropboxFiles() async {
    HomeController controller = Get.put(HomeController());
    controller.setTotalDownloading(name: "Connecting Dropbox .....");
    try {
      ///================== First time to get dropbox files ====================///
      // controller.setTotalDownloading(name: "Syncing libraries");
      // Start from the app's folder in Dropbox (root folder for 'calTablet')
      var result =
          await Dropbox.listFolder(""); // Access the base 'calTablet' directory
      FolderListModel folderListModel = FolderListModel.fromJson(result);
      // Check if the folder listing was successful
      if (!folderListModel.success) {
        // If Dropbox call fails, disable user authorization and show an error
        await SharedPref.storeUserAuthorization(false);
        controller.setErrorSyncResponseProgress();
        showToast(message: folderListModel.message ?? "", isError: true);
        return false;
      } else {
        List<FolderFilePath>? storedFolder =
            await SharedPref.getSelectedLibraries();
        if (storedFolder.isEmpty) {
          final dropboxFolders = folderListModel.paths;
          List<FolderFilePath> allFolder = [];
          for (var dropboxFolder in dropboxFolders) {
            allFolder.add(FolderFilePath(
              pathDisplay: dropboxFolder['pathDisplay'],
              name: dropboxFolder['name'],
              pathLower: dropboxFolder['pathLower'],
            ));
          }
          controller.setTotalDownloading(name: null);
          List<FolderFilePath>? selectedFolders =
              await showDialog<List<FolderFilePath>>(
            context: navKey.currentContext!,
            builder: (BuildContext context) {
              return FolderSelectionDialog(folders: allFolder);
            },
          );
          if (selectedFolders != null) {
            await SharedPref.storeSelectedLibraries(selectedFolders);
            await syncLibrariesFormDropboxFolder(controller, selectedFolders);
          }
        } else {
          controller.setTotalDownloading(name: null);
          await syncLibrariesFormDropboxFolder(controller, storedFolder);
        }
      }
      return true;
    } catch (e) {
      controller.setTotalDownloading(name: null);
      controller.setErrorSyncResponseProgress();
      // Catch and log any errors that occur during the sync process
      print('Error syncing with Dropbox: $e');
      showToast(message: 'Error syncing with Dropbox: $e', isError: true);
      return false; // Return false if an error occurs
    }
  }

  Future<bool> syncLibrariesFormDropboxFolder(
      HomeController controller, List<FolderFilePath> librariesFolders) async {
    try {
      final dir = await SharedPref.getLocalFolderPath;

      for (int lib = 0; lib < librariesFolders.length; lib++) {
        var librariesFolder = librariesFolders[lib];

        controller.setTotalLibrariesDownloading(
            items: librariesFolders.length,
            name: "Downloading ..... ${librariesFolder.name}");
        controller.setDownloadingLibrariesProgress(lib);

        var librariesResult =
            await Dropbox.listFolder(librariesFolder.pathLower!);
        FolderListModel librariesPath =
            FolderListModel.fromJson(librariesResult);
        if (!librariesPath.success) continue;

        final libraries = librariesPath.paths;

        for (int auth = 0; auth < libraries.length; auth++) {
          var authorFolder = libraries[auth];
          controller.setTotalAuthorsDownloading(
              items: libraries.length,
              name: "Downloading ..... ${authorFolder["name"]}");
          controller.setDownloadingAuthorsProgress(auth);

          var bookResult = await Dropbox.listFolder(authorFolder['pathLower']);
          FolderListModel booksPath = FolderListModel.fromJson(bookResult);
          if (!booksPath.success) continue;

          final books = booksPath.paths;

          // Download all books of this author in parallel, with a batch size of 3
          await _downloadBooksInBatches(books, authorFolder, dir, controller);
        }
      }
      return true;
    } catch (e) {
      print('Error syncing with Dropbox: $e');
      showToast(message: 'Error syncing with Dropbox: $e', isError: true);
      return false;
    }
  }

  Future<void> _downloadBooksInBatches(List<dynamic> books,
      dynamic authorFolder, String? dir, HomeController controller) async {
    //Parallel download size
    const int batchSize = 10;
    List<List<dynamic>> batches = _splitIntoBatches(books, batchSize);

    for (List<dynamic> batch in batches) {
      // Process the current batch in parallel
      await Future.wait(batch.map((bookFolder) {
        return _downloadBook(bookFolder, authorFolder, dir, controller);
      }).toList());

      // Optional: Add a delay between batches to avoid overwhelming the server or network
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  List<List<dynamic>> _splitIntoBatches(List<dynamic> items, int batchSize) {
    List<List<dynamic>> batches = [];
    for (int i = 0; i < items.length; i += batchSize) {
      batches.add(items.sublist(
          i, i + batchSize > items.length ? items.length : i + batchSize));
    }
    return batches;
  }

  Future<void> _downloadBook(dynamic bookFolder, dynamic authorFolder,
      String? dir, HomeController controller) async {
    var bookFilesResult = await Dropbox.listFolder(bookFolder['pathLower']);
    FolderListModel booksFilesPath = FolderListModel.fromJson(bookFilesResult);
    if (!booksFilesPath.success) return;

    String? coverPath, epubPath, opfPath;

    for (var file in booksFilesPath.paths) {
      String fileName = file['name'];
      String filePath = file['pathLower'];

      if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
        coverPath = filePath;
      } else if (fileName.endsWith('.epub')) {
        epubPath = filePath;
      } else if (fileName.endsWith('.opf')) {
        opfPath = filePath;
      }
    }

    if (coverPath != null && epubPath != null && opfPath != null) {
      final dynamicDirPath =
          '$dir/${authorFolder["name"]}/${bookFolder['name']}';
      final dynamicDir = Directory(dynamicDirPath);
      if (!await dynamicDir.exists()) {
        await dynamicDir.create(recursive: true);
      }

      String localCoverPath = '${dynamicDir.path}/${coverPath.split('/').last}';
      String localEpubPath = '${dynamicDir.path}/${epubPath.split('/').last}';
      String localOpfPath = '${dynamicDir.path}/${opfPath.split('/').last}';

      //If file already exist in the library  skipped download
      // bool existsInDB = await db.isFileInDatabase(localOpfPath);
      // if (existsInDB) return;

      //If file already exist in the library  delete it and  reDownload
      bool existsInDB = await db.isFileInDatabase(localOpfPath);
      if (existsInDB) {
        // Remove entry from database
        await db.deleteFileByPath(localOpfPath);
        print('Book already exists in the database. Deleting old entry.');
      }

      // Delete files in parallel
      await Future.wait([
        if (await File(localCoverPath).exists()) File(localCoverPath).delete(),
        if (await File(localEpubPath).exists()) File(localEpubPath).delete(),
        if (await File(localOpfPath).exists()) File(localOpfPath).delete(),
      ]);

      // Download files in parallel
      await Future.wait([
        downloadFile(coverPath, localCoverPath),
        downloadFile(epubPath, localEpubPath),
        downloadFile(opfPath, localOpfPath),
      ]);

      await extractAndStoreMetadataFromOFP(
          localCoverPath, localEpubPath, localOpfPath);
    }
  }

  Future<void> downloadFile(String filePath, String localPath) async {
    final result = await Dropbox.download(filePath, localPath);
    BaseModel download = BaseModel.fromJson(result);
    if (download.success == true) {
      // showToast(
      //     message: download.message ?? "File download Successfully",
      //     isError: false);
    } else {
      showToast(
          message: download.message ?? "File download Error", isError: true);
    }
  }

  Future<String?> extractAndStoreMetadataFromOFP(
      String coverPath, String epubPath, String opfPath) async {
    try {
      final file = File(opfPath);
      if (await file.exists()) {
        // Read the OPF file content
        String opfContent = await file.readAsString();
        print("Metadata content: $opfContent");

        // Parse the OPF content as XML
        final document = XmlDocument.parse(opfContent);

        // Extract title
        final titleElements = document.findAllElements('dc:title');
        final title =
            titleElements.isNotEmpty ? titleElements.first.text : 'Untitled';

        // Extract all authors and concatenate them
        final authorElements = document.findAllElements('dc:creator');
        final author = authorElements.isNotEmpty
            ? authorElements.map((e) => e.text).toList().join(', ')
            : 'Unknown Author';

        // Extract the 'opf:file-as' attribute for the author sort
        final authorSort = authorElements.isNotEmpty
            ? authorElements
                .map((e) =>
                    e.getAttribute('opf:file-as') ??
                    e.text) // Fallback to text if 'opf:file-as' is not available
                .toList()
                .join(', ')
            : 'Unknown Author';

        // Extract description
        final descriptionElements = document.findAllElements('dc:description');
        String description = descriptionElements.isNotEmpty
            ? descriptionElements.first.text
            : 'No description available';

        // Clean up the description by removing any HTML tags
        description = description.replaceAll(RegExp(r'<[^>]*>'), '');

        // Extract published date
        final publishedDate = document.findAllElements('dc:date').single.text;

        // Extract readStatus from <meta> element
        final readStatusMeta = document.findAllElements('meta').where((meta) {
          return meta.getAttribute('name') ==
              'calibre:user_metadata:#read_status';
        }).firstOrNull; // Safely handle if not found

        String readStatus = '2'; // Default to '0' if not found

        if (readStatusMeta != null) {
          final content = readStatusMeta.getAttribute('content');

          // Try to parse the content in case it's a JSON-like structure
          try {
            final decodedContent = json.decode(content ?? '{}');
            if (decodedContent is Map &&
                decodedContent.containsKey('#value#')) {
              // If it contains '#value#' key, check its value
              readStatus = decodedContent['#value#'] == true
                  ? '1'
                  : decodedContent['#value#'] == false
                      ? '0'
                      : "2";
            } else {
              // Handle simple 'true'/'false' values
              readStatus = content == 'true'
                  ? '1'
                  : content == 'false'
                      ? '0'
                      : '2';
            }
          } catch (e) {
            // If parsing fails, fall back to checking for simple 'true'/'false'
            readStatus = "2";
          }
        }

        final pagesMeta = document.findAllElements('meta').where((meta) {
          return meta.getAttribute('name') == 'calibre:user_metadata:#pages';
        }).firstOrNull; // Safely handle if not found

        int totalPages = 0;
        if (pagesMeta != null) {
          final pagesContent = pagesMeta.getAttribute('content') ?? '{}';
          print('Pages content: $pagesContent'); // Log the content

          // Parse the content as a JSON-like string
          final pagesData = jsonDecode(pagesContent) as Map<String, dynamic>;

          // Extract the #value# field
          final pages = pagesData['#value#'] ?? 0;

          print('Parsed pages: $pages'); // Log the parsed pages

          totalPages = pages;
        } else {
          print('Pages meta not found');
          totalPages = 0; // Return 0 if not found
        }

        // Extract download date
        final downloadDateElement =
            document.findAllElements('meta').where((meta) {
          return meta.getAttribute('name') ==
              'calibre:user_metadata:#date_downloaded';
        }).firstOrNull;

        String downloadDate = 'Unknown';
        if (downloadDateElement != null) {
          final downloadDateString =
              downloadDateElement.getAttribute('content');
          if (downloadDateString != null) {
            try {
              // Parse the JSON-like content to extract the date
              final Map<String, dynamic> downloadDateData =
                  jsonDecode(downloadDateString);

              // Assuming the date value is under the key "#value#"
              downloadDate = downloadDateData['#value#']['__value__'] ?? '';
            } catch (e) {
              print(
                  'Error parsing download date: $downloadDateString. Error: $e');
            }
          }
        }
        //Store the metadata and cover image path in the database
        await db.saveFileToDatabase(
          title: title.isEmpty ? 'Unknown Title' : title,
          author: author.isEmpty ? 'Unknown Author' : author,
          description:
              description.isEmpty ? 'No description available' : description,
          authorSort: authorSort.isEmpty ? "Unknown Author" : authorSort,
          publishedDate: publishedDate.isEmpty
              ? DateTime.now().toIso8601String()
              : publishedDate.toString(),
          readStatus: readStatus,
          downloadDate: downloadDate.isEmpty
              ? DateTime.now().toIso8601String()
              : downloadDate,
          filePath: epubPath,
          fileMetaPath: opfPath,
          totalPages: totalPages,
          coverImagePath: coverPath,
        );

        print("Metadata extraction and database save successful.");
      } else {
        print("OPF file not found at: $opfPath");
      }
    } catch (e) {
      print('Error extracting metadata from OPF: $e');
    }
  }
}
