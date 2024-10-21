import 'package:calibre_tablet/helper/database_helper.dart';
import 'package:calibre_tablet/models/AccessToken_model.dart';
import 'package:calibre_tablet/models/authorizeWithAccessToken_model.dart';
import 'package:calibre_tablet/models/base_model.dart';
import 'package:calibre_tablet/models/folder_list_model.dart';
import 'package:calibre_tablet/view/widgets/custom_snackbar.dart';
import 'package:dropbox_client/dropbox_client.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:xml/xml.dart';
import '../helper/shared_preferences.dart';
import '../models/dropbox_config.dart';

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
    final result = await Dropbox.authorize();
    await Future.delayed(const Duration(seconds: 10));
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
    try {
      // Start from the app's folder in Dropbox (root folder for 'calTablet')
      var result =
          await Dropbox.listFolder(""); // Access the base 'calTablet' directory
      FolderListModel folderListModel = FolderListModel.fromJson(result);

      // Check if the folder listing was successful
      if (!folderListModel.success) {
        // If Dropbox call fails, disable user authorization and show an error
        await SharedPref.storeUserAuthorization(false);
        showToast(message: folderListModel.message ?? "", isError: true);
        return false;
      }

      // Get the list of author folders from Dropbox
      final authorFolders = folderListModel.paths;
      // Get the application's document directory to store files locally
      final dir = await getApplicationDocumentsDirectory();

      // int downloadedBooksCount = 0; // Track the number of books downloaded

      // Iterate through each author folder
      for (var authorFolder in authorFolders) {
        // List the contents (books) of the current author folder
        var bookResult = await Dropbox.listFolder(authorFolder['pathLower']);
        FolderListModel booksPath = FolderListModel.fromJson(bookResult);

        // Skip this folder if there was an error in listing its contents
        if (!booksPath.success) continue;

        // Get the list of book folders under the current author folder
        final books = booksPath.paths;

        // Iterate through each book folder
        for (var bookFolder in books) {
          // if (downloadedBooksCount >= 5) {
          //   // Stop downloading if 2 books have already been downloaded
          //   print('Limit of 2 books reached. Stopping further downloads.');
          //   return true;
          // }
          // List the contents (files) of the current book folder
          var bookFilesResult =
              await Dropbox.listFolder(bookFolder['pathLower']);
          FolderListModel booksFilesPath =
              FolderListModel.fromJson(bookFilesResult);

          // Skip if there was an error in listing the book's files
          if (!booksFilesPath.success) continue;

          // Initialize file paths for cover, EPUB, and OPF metadata
          String? coverPath, epubPath, opfPath;

          // Iterate through the files in the book folder to find specific file types
          for (var file in booksFilesPath.paths) {
            String fileName = file['name'];
            String filePath = file['pathLower'];

            // Check and assign file paths based on their extensions
            if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
              coverPath = filePath; // Assign cover image path
            } else if (fileName.endsWith('.epub')) {
              epubPath = filePath; // Assign EPUB file path
            } else if (fileName.endsWith('.opf')) {
              opfPath = filePath; // Assign OPF metadata file path
            }
          }

          // Proceed only if all required files (cover, EPUB, OPF) are found
          if (coverPath != null && epubPath != null && opfPath != null) {
            // Create the local directory path where book files will be stored
            final dynamicDirPath =
                '${dir.path}/${authorFolder['name']}/${bookFolder['name']}';
            final dynamicDir = Directory(dynamicDirPath);

            // Ensure the directory exists, create it if it doesn't
            if (!await dynamicDir.exists()) {
              await dynamicDir.create(recursive: true);
            }

            // Generate local paths for cover, EPUB, and OPF files
            String localCoverPath =
                '${dynamicDir.path}/${coverPath.split('/').last}';
            String localEpubPath =
                '${dynamicDir.path}/${epubPath.split('/').last}';
            String localOpfPath =
                '${dynamicDir.path}/${opfPath.split('/').last}';

            // Check if the book already exists in the database based on the OPF file
            bool existsInDB = await db.isFileInDatabase(localOpfPath);
            if (existsInDB) {
              // If the book is already in the database, skip downloading it
              print('Book already exists in the database. Skipping download.');
              continue;
            }

            // Download the cover, EPUB, and OPF files in parallel using Future.wait()
            await Future.wait([
              downloadFile(coverPath, localCoverPath),
              downloadFile(epubPath, localEpubPath),
              downloadFile(opfPath, localOpfPath),
            ]);

            // Once files are downloaded, extract metadata from the OPF file and store it in the database
            await extractAndStoreMetadataFromOFP(
                localCoverPath, localEpubPath, localOpfPath);

            // Increment the counter for downloaded books
            // downloadedBooksCount++;
          }
        }
      }

      // Return true indicating a successful sync
      return true;
    } catch (e) {
      // Catch and log any errors that occur during the sync process
      print('Error syncing with Dropbox: $e');
      showToast(message: 'Error syncing with Dropbox: $e', isError: true);
      return false; // Return false if an error occurs
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
          message: download.message ?? "File download Error", isError: false);
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

        // Extract description
        final descriptionElements = document.findAllElements('dc:description');
        String description = descriptionElements.isNotEmpty
            ? descriptionElements.first.text
            : 'No description available';

        // Clean up the description by removing any HTML tags
        description = description.replaceAll(RegExp(r'<[^>]*>'), '');

        // Extract published date
        final publishedDateString =
            document.findAllElements('dc:date').single.text;
        DateTime publishedDateTime = DateTime.parse(publishedDateString);
        String publishedDate =
            DateFormat("MMM d, yyyy").format(publishedDateTime);

        // Extract readStatus from <meta> element
        final readStatusMeta = document.findAllElements('meta').where((meta) {
          return meta.getAttribute('name') ==
              'calibre:user_metadata:#read_status';
        }).firstOrNull; // Safely handle if not found

        final readStatus = readStatusMeta != null
            ? (readStatusMeta.getAttribute('content') == 'true' ? '1' : '0')
            : '0';

        // Extract pages from <meta> element
        final pagesMeta = document.findAllElements('meta').where((meta) {
          return meta.getAttribute('name') == 'calibre:user_metadata:#pages';
        }).firstOrNull; // Safely handle if not found

        final pages = pagesMeta != null
            ? int.tryParse(pagesMeta.getAttribute('content') ?? '0') ?? 0
            : 0;

        // Use current timestamp as the download date
        String downloadDate = DateFormat("MMM d, yyyy").format(DateTime.now());

        //Store the metadata and cover image path in the database
        await db.saveFileToDatabase(
          title: title.isEmpty ? 'Unknown Title' : title,
          author: author.isEmpty ? 'Unknown Author' : author,
          description:
              description.isEmpty ? 'No description available' : description,
          publishedDate: publishedDate.isEmpty ? 'Unknown' : publishedDate,
          readStatus: readStatus,
          downloadDate: downloadDate,
          filePath: epubPath,
          fileMetaPath: opfPath,
          totalPages: pages,
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

  Future<bool?> updateReadStatusInOPF(String opfPath, bool readStatus) async {
    try {
      final file = File(opfPath);
      if (await file.exists()) {
        String opfContent = await file.readAsString();

        // Parse the OPF content as XML
        final document = XmlDocument.parse(opfContent);

        // Find the meta tag for read_status or create it if it doesn't exist
        var readStatusMeta = document.findAllElements('meta').where((meta) {
          return meta.getAttribute('name') ==
              'calibre:user_metadata:#read_status';
        }).firstOrNull;

        if (readStatusMeta != null) {
          // Update the content attribute for read_status
          readStatusMeta.setAttribute('content', readStatus ? 'true' : 'false');
        } else {
          // If the meta tag for read_status doesn't exist, create one
          final metadata = document.findAllElements('metadata').firstOrNull;
          if (metadata != null) {
            metadata.children.add(XmlElement(
              XmlName('meta'),
              [
                XmlAttribute(
                    XmlName('name'), 'calibre:user_metadata:#read_status'),
                XmlAttribute(XmlName('content'), readStatus ? 'true' : 'false'),
              ],
            ));
          }
        }

        // Save the updated OPF content back to the file
        await file.writeAsString(document.toXmlString(pretty: true));
        print('OPF file updated successfully.');
        return true;
      } else {
        print('OPF file not found at: $opfPath');
        return false;
      }
    } catch (e) {
      print('Error updating OPF file: $e');
      return false;
    }
  }

  Future<bool?> uploadFileToDropbox(
      String localFilePath, String dropboxFilePath) async {
    try {
      // Upload the updated OPF file to Dropbox
      File file = File(localFilePath);
      final result = await Dropbox.upload(file.path, dropboxFilePath);
      BaseModel baseModel = BaseModel.fromJson(result);
      if (baseModel.success == true) {
        showToast(
            message: baseModel.message ?? "File Updated Successfully",
            isError: false);
        return true;
      } else {
        showToast(
            message: baseModel.message ?? "File Updated Error", isError: true);
        return false;
      }
    } catch (e) {
      print('Error uploading file to Dropbox: $e');
      return false;
    }
  }

  Future<void> updateReadStatusAndUpload(
      String localOpfPath, String dropboxOpfPath, bool readStatus) async {
    // Step 1: Update the OPF file locally
    await updateReadStatusInOPF(localOpfPath, readStatus);

    // Step 2: Upload the updated OPF file to Dropbox
    await uploadFileToDropbox(localOpfPath, dropboxOpfPath);
  }
}
