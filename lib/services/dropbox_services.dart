import 'dart:convert';
import 'package:calibre_tablet/helper/database_helper.dart';
import 'package:calibre_tablet/view/widgets/custom_snackbar.dart';
import 'package:dropbox_client/dropbox_client.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:typed_data';
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
      final res =
          await Dropbox.init(dropboxClientId, dropboxKey, dropboxSecret);
      print("result");
      return res;
    } catch (e) {
      return false;
    }
  }

  Future<bool?> authorize() async {
    final result = await Dropbox.authorize();
    await Future.delayed(const Duration(seconds: 30));
    print('result');
    return result;
  }

  Future<String?> getAccessToken() async {
    final result = await Dropbox.getAccessToken();
    print('result');
    return result;
  }

  Future<bool?> authorizeWithAccessToken(String token) async {
    String accessToken = token;
    final result = await Dropbox.authorizeWithAccessToken(accessToken);
    print("Authorized with token : $result");
    return result;
  }

  Future getAccountName() async {
    final user = await Dropbox.getAccountName();
    print('user = $user');
  }

  Future listFolder(path) async {
    List list = [];
    final result = await Dropbox.listFolder(path);
    list.clear();
    list.addAll(result);
  }

  Future<String> getExternalStoragePath() async {
    // Get the path to external storage
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  Future<bool> syncDropboxFiles() async {
    bool filesDownloadedAndAdded = false;
    try {
      // Start from the app's folder in Dropbox
      var authorFolders =
          await Dropbox.listFolder(""); // Access 'calTablet' directory
      if (authorFolders['success'] == true) {
        // Handle success
        var paths = authorFolders['paths'];
        print("Paths: $paths");
        final dir = await getApplicationDocumentsDirectory();

        // int downloadedBooksCount = 0;
        // for (var authorFolder in authorFolders) {
        //   var books = await Dropbox.listFolder(authorFolder['pathLower']);
        //
        //   for (var bookFolder in books) {
        //     // if (downloadedBooksCount >= 1) {
        //     //   // Stop downloading if 2 books have already been downloaded
        //     //   print('Limit of 2 books reached. Stopping further downloads.');
        //     //   return true;
        //     // }
        //
        //     var bookFiles = await Dropbox.listFolder(bookFolder['pathLower']);
        //
        //     String? coverPath;
        //     String? epubPath;
        //     String? opfPath;
        //
        //     // Retrieve files (cover image, EPUB, and OPF metadata)
        //     for (var file in bookFiles) {
        //       String fileName = file['name'];
        //       String filePath = file['pathLower'];
        //
        //       if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
        //         coverPath = filePath;
        //       } else if (fileName.endsWith('.epub')) {
        //         epubPath = filePath;
        //       } else if (fileName.endsWith('.opf')) {
        //         opfPath = filePath;
        //       }
        //     }
        //
        //     // Proceed if all required files are found
        //     if (coverPath != null && epubPath != null && opfPath != null) {
        //       // Ensure dynamic directory exists before downloading
        //       final dynamicDirPath =
        //           '${dir.path}/${authorFolder['name']}/${bookFolder['name']}';
        //       final dynamicDir = Directory(dynamicDirPath);
        //
        //       if (!await dynamicDir.exists()) {
        //         await dynamicDir.create(
        //             recursive: true); // Create the directory if necessary
        //       }
        //
        //       // Construct correct local paths
        //       String localCoverPath =
        //           '${dynamicDir.path}/${coverPath.split('/').last}';
        //       String localEpubPath =
        //           '${dynamicDir.path}/${epubPath.split('/').last}';
        //       String localOpfPath =
        //           '${dynamicDir.path}/${opfPath.split('/').last}';
        //
        //       // Extract metadata from OFP file before downloading to check if the book exists
        //
        //       bool? existsInDB = await db.isFileInDatabase(localOpfPath);
        //       if (existsInDB) {
        //         print('Book  already exists in the database. Skipping download.');
        //         continue; // Skip this book, no need to download
        //       }
        //       // Download files locally
        //       await Future.wait([
        //         Dropbox.download(coverPath, localCoverPath),
        //         Dropbox.download(epubPath, localEpubPath),
        //         Dropbox.download(opfPath, localOpfPath),
        //       ]);
        //       // Extract metadata from OPF file and store in SQLite
        //       await extractAndStoreMetadataFromOFP(
        //           localCoverPath, localEpubPath, localOpfPath);
        //       downloadedBooksCount++;
        //     }
        //   }
        // }
        return true;
      } else {
        // Handle error
        var errorMessage = authorFolders['message'];
        print("Error: $errorMessage");
        await SharedPref.storeUserAuthorization(false);
        showToast(message: "${errorMessage.toString()}", isError: true);
        return false;
      }
    } catch (e) {
      print('Error syncing with Dropbox: $e');
      return false;
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

  Future<void> updateReadStatusInOPF(String opfPath, bool readStatus) async {
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
      } else {
        print('OPF file not found at: $opfPath');
      }
    } catch (e) {
      print('Error updating OPF file: $e');
    }
  }

  Future<void> uploadFileToDropbox(
      String localFilePath, String dropboxFilePath) async {
    try {
      // Initialize the Dropbox client (if you haven't already)
      // await Dropbox.init('YOUR_DROPBOX_APP_KEY');
      // await Dropbox.authenticate(); // Authenticate the user

      // Upload the updated OPF file to Dropbox
      File file = File(localFilePath);
      await Dropbox.upload(file.path, dropboxFilePath);

      print('File uploaded to Dropbox successfully.');
    } catch (e) {
      print('Error uploading file to Dropbox: $e');
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
