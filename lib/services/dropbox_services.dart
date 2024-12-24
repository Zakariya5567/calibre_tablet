import 'dart:convert';
import 'package:calibre_tablet/controller/home_controller.dart';
import 'package:calibre_tablet/helper/database_helper.dart';
import 'package:calibre_tablet/main.dart';
import 'package:calibre_tablet/models/folder_list_model.dart';
import 'package:calibre_tablet/services/api_services.dart';
import 'package:calibre_tablet/view/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:xml/xml.dart';
import '../helper/shared_preferences.dart';
import 'package:get/get.dart';
import '../view/widgets/folder_selection_dialog.dart';

class DropboxService {
  DatabaseHelper db = DatabaseHelper();
  ApiServices apiServices = ApiServices();

  ///======================================
  Future<bool> syncDropboxFiles() async {
    HomeController controller = Get.put(HomeController());
    controller.setTotalDownloading(name: "Connecting Dropbox...");

    try {
      // Step 1: Fetch folder list from Dropbox
      FolderListResponse result = await apiServices.getFolderList("");
      if (!result.success) {
        return await _handleDropboxFailure(result, controller);
      }

      // Step 2: Check stored folder libraries
      List<FolderFilePath>? storedFolders =
          await SharedPref.getSelectedLibraries();
      if (storedFolders.isEmpty) {
        // Step 3: Get folders from Dropbox and prompt user selection
        List<FolderFilePath>? selectedFolders = await promptUserToSelectFolders(
          controller,
          result.folderListModel?.entries,
        );
        if (selectedFolders != null) {
          await SharedPref.storeSelectedLibraries(selectedFolders);
          await _syncSelectedFolders(controller, selectedFolders);
        }
      } else {
        // Step 4: Sync stored folders directly
        await _syncSelectedFolders(controller, storedFolders);
      }

      return true;
    } catch (e) {
      // Handle any unexpected errors
      _handleSyncError(controller, e);
      return false;
    }
  }

  /// Handles failures during the Dropbox folder listing step
  Future<bool> _handleDropboxFailure(
    FolderListResponse result,
    HomeController controller,
  ) async {
    controller.setErrorSyncResponseProgress();
    if (result.refresh == true) {
      controller.setTotalDownloading(name: "Connecting Dropbox...");
      bool refreshSuccess = await apiServices.refreshToken();
      if (refreshSuccess) {
        return await syncDropboxFiles(); // Retry sync after refreshing token
      }
    }
    return false;
  }

  /// Prompts the user to select folders from the Dropbox list
  Future<List<FolderFilePath>?> promptUserToSelectFolders(
    HomeController controller,
    List<Entry>? dropboxFolders,
  ) async {
    if (dropboxFolders == null || dropboxFolders.isEmpty) return null;

    controller.setTotalDownloading(name: null);
    List<FolderFilePath> folderOptions = dropboxFolders.map((folder) {
      return FolderFilePath(
        pathDisplay: folder.pathDisplay,
        name: folder.name,
        pathLower: folder.pathLower,
      );
    }).toList();

    return await showDialog<List<FolderFilePath>>(
      context: navKey.currentContext!,
      builder: (BuildContext context) {
        return FolderSelectionDialog(folders: folderOptions);
      },
    );
  }

  /// Syncs the selected Dropbox folders
  Future<void> _syncSelectedFolders(
    HomeController controller,
    List<FolderFilePath> folders,
  ) async {
    controller.setTotalDownloading(name: null);
    await syncLibrariesFormDropboxFolder(controller, folders);
  }

  /// Handles unexpected sync errors
  void _handleSyncError(HomeController controller, dynamic error) {
    controller.setTotalDownloading(name: null);
    controller.setErrorSyncResponseProgress();
    debugPrint('Error syncing with Dropbox: $error');
  }

  ///=======================================

  Future<bool> syncLibrariesFormDropboxFolder(
      HomeController controller, List<FolderFilePath> librariesFolders) async {
    await db.clearDatabase();
    await clearFilesInCustomDirectory();
    try {
      final dir = await SharedPref.getLocalFolderPath;

      for (int lib = 0; lib < librariesFolders.length; lib++) {
        var librariesFolder = librariesFolders[lib];

        controller.setTotalLibrariesDownloading(
            items: librariesFolders.length,
            name: "Downloading ..... ${librariesFolder.name}");
        controller.setDownloadingLibrariesProgress(lib);

        FolderListResponse librariesResult =
            await apiServices.getFolderList(librariesFolder.pathLower!);
        if (!librariesResult.success) continue;

        final libraries = librariesResult.folderListModel?.entries;
        if (libraries != null) {
          for (int auth = 0; auth < libraries.length; auth++) {
            var authorFolder = libraries[auth];
            controller.setTotalAuthorsDownloading(
                items: libraries.length,
                name: "Downloading ..... ${authorFolder.name}");
            controller.setDownloadingAuthorsProgress(auth);

            FolderListResponse bookResult =
                await apiServices.getFolderList(authorFolder.pathLower!);

            if (!bookResult.success) continue;

            final books = bookResult.folderListModel?.entries;

            // Download all books of this author in parallel, with a batch size of 3
            if (books != null) {
              await _downloadBooksInBatches(
                  books, authorFolder, dir, controller);
            }
          }
        }
      }
      return true;
    } catch (e) {
      print('Error syncing with Dropbox: $e');
      // showToast(message: 'Error syncing with Dropbox: $e', isError: true);
      return false;
    }
  }

  ///=======================================
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

  ///=======================================
  List<List<dynamic>> _splitIntoBatches(List<dynamic> items, int batchSize) {
    List<List<dynamic>> batches = [];
    for (int i = 0; i < items.length; i += batchSize) {
      batches.add(items.sublist(
          i, i + batchSize > items.length ? items.length : i + batchSize));
    }
    return batches;
  }

  ///=======================================
  Future<void> _downloadBook(dynamic bookFolder, dynamic authorFolder,
      String? dir, HomeController controller) async {
    FolderListResponse bookFilesResult =
        await apiServices.getFolderList(bookFolder.pathLower!);

    // var bookFilesResult = await Dropbox.listFolder(bookFolder['pathLower']);
    // FolderListModel booksFilesPath = FolderListModel.fromJson(bookFilesResult);
    if (!bookFilesResult.success) return;

    final files = bookFilesResult.folderListModel?.entries;
    if (files != null) {
      String? coverPath, epubPath, opfPath;
      for (var file in files) {
        String fileName = file.name ?? " ";
        String filePath = file.pathLower ?? "";

        if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
          coverPath = filePath;
        } else if (fileName.endsWith('.epub')) {
          epubPath = filePath;
        } else if (fileName.endsWith('.opf')) {
          opfPath = filePath;
        }
      }

      if (coverPath != null && epubPath != null && opfPath != null) {
        final dynamicDirPath = '$dir/${authorFolder.name}/${bookFolder.name}';
        final dynamicDir = Directory(dynamicDirPath);
        if (!await dynamicDir.exists()) {
          await dynamicDir.create(recursive: true);
        }

        String localCoverPath =
            '${dynamicDir.path}/${coverPath.split('/').last}';
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
          if (await File(localCoverPath).exists())
            File(localCoverPath).delete(),
          if (await File(localEpubPath).exists()) File(localEpubPath).delete(),
          if (await File(localOpfPath).exists()) File(localOpfPath).delete(),
        ]);

        // Download files in parallel
        await Future.wait([
          apiServices.downloadFile(coverPath, localCoverPath),
          apiServices.downloadFile(epubPath, localEpubPath),
          apiServices.downloadFile(opfPath, localOpfPath),
        ]);

        await extractAndStoreMetadataFromOFP(
            localCoverPath, localEpubPath, localOpfPath);
      }
    }
  }

  ///=======================================
  Future<void> clearFilesInCustomDirectory() async {
    try {
      // Retrieve the stored directory path
      final directoryPath = await SharedPref.getLocalFolderPath;

      if (directoryPath == null || directoryPath.isEmpty) {
        print("Directory path is not available.");
        return;
      }

      // Create a directory object with the retrieved path
      final directory = Directory(directoryPath);

      // Check if the directory exists
      if (!await directory.exists()) {
        print("Directory does not exist.");
        return;
      }

      // List all files and directories within this path
      final files = directory.listSync();

      // Delete each file and directory
      for (var file in files) {
        try {
          if (file is File) {
            await file.delete(); // Delete file
          } else if (file is Directory) {
            await file.delete(
                recursive: true); // Delete directory and its contents
          }
        } catch (e) {
          print("Error deleting file or directory: $e");
        }
      }
      print("Custom directory cleared successfully.");
    } catch (e) {
      print("Error clearing custom directory: $e");
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
        // description = description.replaceAll(RegExp(r'<[^>]*>'), '');

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
