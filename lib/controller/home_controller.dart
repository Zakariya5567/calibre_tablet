import 'dart:ffi';
import 'dart:io';

import 'package:calibre_tablet/helper/connection_checker.dart';
import 'package:calibre_tablet/helper/database_helper.dart';
import 'package:calibre_tablet/helper/shared_preferences.dart';
import 'package:calibre_tablet/models/file_model.dart';
import 'package:calibre_tablet/services/dropbox_services.dart';
import 'package:calibre_tablet/view/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class HomeController extends GetxController {
  DatabaseHelper databaseHelper = DatabaseHelper();
  DropboxService dropboxService = DropboxService();

  String selectedFiler = "all"; // Default to showing all books
  String selectedSort = "title"; // Default to showing all books
  String selectedOrderBy = "ascending"; // Default sort order

  // Set the selected filter (read/unread/all)
  void setSelectedFilter(String filter) {
    selectedFiler = filter;
    update();
    fetchAllFiles();
  }

  // Set the selected sort option (ascending/descending)
  void seOrderBy(String sort) {
    selectedOrderBy = sort;
    update();
    fetchAllFiles();
  }

  // Set the selected sort option (title/author/dates)
  void setSelectedSort(String sort) {
    selectedSort = sort;
    update();
    fetchAllFiles();
  }

  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  setSearching() {
    isSearching = !isSearching;
    if (isSearching == false) {
      searchController.clear();
      fetchAllFiles();
    }
    update();
  }

  clearData() {
    selectedFiler = "all";
    selectedSort = "title";
    selectedOrderBy = "ascending";
    searchController.clear();
    update();
  }

  bool isLoading = false;
  setLoading(bool loading) {
    isLoading = loading;
    update();
  }

  Future<void> getServices() async {
    final hasInternet = await checkInternet();
    if (!hasInternet) return;
    setLoading(true);
    bool? isAuthorized = await SharedPref.getUserAuthorization;
    try {
      bool? initialize = await dropboxService.initDropbox();
      if (initialize == true) {
        ///Check before submit
        ///isAuthorized != true
        if (isAuthorized != true) {
          final status = await dropboxService.authorize();
          if (status == true) {
            SharedPref.storeUserAuthorization(true);
            //This statement is not working fine will check the issue in the plugin used
            String? token = await dropboxService.getAccessToken();
            await SharedPref.storeAccessToken(token);
            await authenticateWithAccessTokenAndSync();
          }
        } else {
          await authenticateWithAccessTokenAndSync();
        }
        setLoading(false);
      } else {
        setLoading(false);
      }
    } catch (e) {
      setLoading(false);
      SharedPref.storeUserAuthorization(false);
      showToast(
          message: "Something Went Wrong. Please try again later",
          isError: true);
    }
  }

  Future<void> authenticateWithAccessTokenAndSync() async {
    String? token = await SharedPref.getAccessToken;
    //'sl.B--k1uplvyrTtu4bdd6yLe9or5KCqeZ38U12HDuCrkWnnlrsqvw6_Crzcy1qHuyGyHojAnwW8sxUBW59bRHFYTWghtkTBuJVlGgDPYcH470UPhJlZDE4_Tps6_5V-JnxKC0qnk4ti5rbEd_fhr4sAqA';
    try {
      if (token != null) {
        final authorizedWithToken =
            await dropboxService.authorizeWithAccessToken(token);
        if (authorizedWithToken == true) {
          SharedPref.storeUserAuthorization(true);
          await dropboxService.syncDropboxFiles();
          await fetchAllFiles();
        } else {
          SharedPref.storeUserAuthorization(false);
          showToast(
              message: "Authorization Error : Please Authorized with Dropbox",
              isError: true);
        }
      } else {
        SharedPref.storeUserAuthorization(false);
        showToast(
            message: "Authorization Error : Please Authorized with Dropbox",
            isError: true);
      }
    } catch (e) {
      SharedPref.storeUserAuthorization(false);
      showToast(
          message: "$e Authorization Error : Please Authorized with Dropbox",
          isError: true);
    }
  }

  List<FileModel> files = [];

  Future<void> fetchAllFiles() async {
    files = [];

    // Fetch files with the selected filter and sorting
    files = await databaseHelper.fetchFilesFromDatabase(
      filterByStatus: selectedFiler, // Filter by read/unread/all
      sortOrder: selectedSort,
      orderBy: selectedOrderBy,
      // Ascending or Descending
    );
    update(); // Update the UI with the fetched data
  }

  Future<void> fetchSearchFiles() async {
    files = [];
    // Fetch files with the search text, selected filter, and selected sort order
    files = await databaseHelper.fetchSearchFilesFromDatabase(
      searchText: searchController.text,
      filterByStatus: selectedFiler, // Filter by read/unread/all
      sortOrder: selectedSort,
      orderBy: selectedOrderBy, // Ascending or Descending
    );
    update(); // Update the UI with the fetched data
  }

  void markBookAsReadAndSync(FileModel file) async {
    bool isInternet = await checkInternet();
    if (!isInternet) return;

    bool isRead = true; // or false if you're marking it as unread
    String isReadLocally = '1';
    //   await dropboxService.updateReadStatusAndUpload(file.fileMetaPath!, dropboxOpfPath, true);
    await databaseHelper
        .markBookAsRead(file.id!); // Call the function to mark the book as read
    print('Book marked as read in the database.');
    await fetchAllFiles();
    print('Read status updated and synced with Dropbox.');
  }

  void onBookRead(int bookId) async {
    await databaseHelper
        .markBookAsRead(bookId); // Call the function to mark the book as read
    print('Book marked as read in the database.');
    fetchAllFiles();
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
            ? (readStatusMeta.getAttribute('content') == 'true'
                ? 'Read'
                : 'Unread')
            : 'Unknown';

        // Extract pages from <meta> element
        final pagesMeta = document.findAllElements('meta').where((meta) {
          return meta.getAttribute('name') == 'calibre:user_metadata:#pages';
        }).firstOrNull; // Safely handle if not found

        final pages = pagesMeta != null
            ? int.tryParse(pagesMeta.getAttribute('content') ?? '0') ?? 0
            : 0;

        // Use current timestamp as the download date
        String downloadDate = DateFormat("MMM d, yyyy").format(DateTime.now());

        // Store the metadata and cover image path in the database
        // await db.saveFileToDatabase(
        //   title: title.isEmpty ? 'Unknown Title' : title,
        //   author: author.isEmpty ? 'Unknown Author' : author,
        //   description: description.isEmpty ? 'No description available' : description,
        //   publishedDate: publishedDate.isEmpty ? 'Unknown' : publishedDate,
        //   readStatus: readStatus,
        //   downloadDate: downloadDate,
        //   filePath: epubPath,
        //   fileMetaPath: opfPath,
        //   totalPages: pages,
        //   coverImagePath: coverPath,
        // );

        print("Metadata extraction and database save successful.");
      } else {
        print("OPF file not found at: $opfPath");
      }
    } catch (e) {
      print('Error extracting metadata from OPF: $e');
    }
  }
}
