import 'package:calibre_tablet/helper/connection_checker.dart';
import 'package:calibre_tablet/helper/database_helper.dart';
import 'package:calibre_tablet/helper/shared_preferences.dart';
import 'package:calibre_tablet/models/file_model.dart';
import 'package:calibre_tablet/services/dropbox_services.dart';
import 'package:calibre_tablet/view/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../helper/permission_helper.dart';

class HomeController extends GetxController {
  DatabaseHelper databaseHelper = DatabaseHelper();
  DropboxService dropboxService = DropboxService();

  String selectedFiler = "all"; // Default to showing all books
  String selectedSort = "title"; // Default to showing all books
  String selectedOrderBy = "ascending"; // Default sort order

  String? syncName;

  setTotalDownloading({required String? name}) {
    syncName = name;
    update();
  }

  /// Libraries downloading progress;
  int? totalLibrariesItems;
  String? itemLibrariesName;
  int? librariesProgress;

  setTotalLibrariesDownloading({required int? items, required String? name}) {
    itemLibrariesName = name;
    totalLibrariesItems = items;
    update();
  }

  setDownloadingLibrariesProgress(int count) {
    librariesProgress = count;
    update();
  }

  /// Authors downloading progress;
  int? totalAuthorsItems;
  String? itemAuthorsName;
  int? authorsProgress;

  setTotalAuthorsDownloading({required int? items, required String? name}) {
    itemAuthorsName = name;
    totalAuthorsItems = items;
    update();
  }

  setDownloadingAuthorsProgress(int count) {
    authorsProgress = count;
    update();
  }

  /// Books downloading progress;
  int? totalBooksItems;
  String? itemBooksName;
  int? booksProgress;

  setTotalBooksDownloading({required int? items, required String? name}) {
    itemBooksName = name;
    totalBooksItems = items;
    update();
  }

  setDownloadingBooksProgress(int count) {
    booksProgress = count;
    update();
  }

  int currentPage = 0;
  setPageIndex(index) async {
    currentPage = index;
    update();
  }

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

  setErrorSyncResponseProgress() {
    syncName = null;

    totalLibrariesItems = null;
    itemLibrariesName = null;
    librariesProgress = null;

    totalAuthorsItems = null;
    itemAuthorsName = null;
    authorsProgress = null;

    totalBooksItems = null;
    itemBooksName = null;
    booksProgress = null;
    update();
  }

  Future<void> getServices() async {
    bool? isGranted = await requestManageExternalStoragePermission();
    if (isGranted == false) {
      showToast(message: "Storage Permission denied", isError: true);
      return;
    }

    String? selectedFolder = await selectFolder();
    if (selectedFolder == null) {
      showToast(message: "Storage Not Selected", isError: true);
      return;
    }

    final hasInternet = await checkInternet();
    if (!hasInternet) return;

    setLoading(true);
    bool? isAuthorized = await SharedPref.getUserAuthorization;

    try {
      if (await dropboxService.initDropbox() != true) {
        setLoading(false);
        return;
      }

      if (isAuthorized != true) {
        if (await dropboxService.authorize() == true) {
          await handleAuthorizationAndSync();
        }
      } else {
        await authenticateWithAccessTokenAndSync();
      }
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> handleAuthorizationAndSync() async {
    try {
      String? token = await dropboxService.getAccessToken();
      if (token != null) {
        print("Access Token : $token");
        await SharedPref.storeAccessToken(token);
        await authenticateWithAccessTokenAndSync();
      } else {
        throw Exception("Failed to retrieve access token");
      }
    } catch (e) {
      handleError(e);
    }
  }

  // Future<void> handleAuthorizationAndUpdate(FileModel file) async {
  //   try {
  //     String? token = await dropboxService.getAccessToken();
  //     if (token != null) {
  //       print("Access Token : $token");
  //       await SharedPref.storeAccessToken(token);
  //       await authenticateWithAccessTokenAndUpdate(file);
  //     } else {
  //       throw Exception("Failed to retrieve access token");
  //     }
  //   } catch (e) {
  //     handleError(e);
  //   }
  // }

  Future<void> authenticateWithAccessTokenAndSync() async {
    String? token = await SharedPref.getAccessToken;

    if (token == null) {
      showAuthorizationError();
      return;
    }

    try {
      if (await dropboxService.authorizeWithAccessToken(token) == true) {
        SharedPref.storeUserAuthorization(true);

        if (await dropboxService.syncDropboxFiles() == true) {
          await fetchAllFiles();
        } else {
          showSyncError();
        }
      } else {
        showAuthorizationError();
      }
    } catch (e) {
      handleError(e);
    }
  }

  // Future<void> authenticateWithAccessTokenAndUpdate(FileModel file) async {
  //   String? token = await SharedPref.getAccessToken;
  //
  //   if (token == null) {
  //     showAuthorizationError();
  //     return;
  //   }
  //
  //   try {
  //     if (await dropboxService.authorizeWithAccessToken(token) == true) {
  //       SharedPref.storeUserAuthorization(true);
  //       String opfPath = file.fileMetaPath!;
  //
  //       int startIndex =
  //           opfPath.indexOf('/app_flutter/') + '/app_flutter/'.length;
  //       // Extract the part from that index to the end
  //       String dropboxOpfPath = "/${opfPath.substring(startIndex)}";
  //
  //       await dropboxService.updateReadStatusAndUpload(
  //           opfPath, dropboxOpfPath, true);
  //       await databaseHelper.markBookAsRead(
  //           file.id!); // Call the function to mark the book as read
  //       await fetchAllFiles();
  //     } else {
  //       showAuthorizationError();
  //     }
  //   } catch (e) {
  //     handleError(e);
  //   }
  // }

  void handleError(e) {
    SharedPref.storeUserAuthorization(false);
    showToast(
      message: "Something Went Wrong: $e. Please try again later",
      isError: true,
    );
  }

  void showAuthorizationError() {
    SharedPref.storeUserAuthorization(false);
    showToast(
      message: "Authorization Error: Please authorize with Dropbox",
      isError: true,
    );
  }

  void showSyncError() {
    SharedPref.storeUserAuthorization(false);
    showToast(
      message: "Error syncing with Dropbox",
      isError: true,
    );
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

  // void markBookAsReadAndSync(FileModel file) async {
  //   final hasInternet = await checkInternet(isDisplayMessage: false);
  //   if (!hasInternet) return;
  //
  //   bool? isAuthorized = await SharedPref.getUserAuthorization;
  //   try {
  //     if (await dropboxService.initDropbox() != true) {
  //       return;
  //     }
  //
  //     if (isAuthorized != true) {
  //       if (await dropboxService.authorize() == true) {
  //         await handleAuthorizationAndUpdate(file);
  //       }
  //     } else {
  //       await authenticateWithAccessTokenAndUpdate(file);
  //     }
  //   } catch (e) {
  //     handleError(e);
  //   }
  // }
}
