import 'package:calibre_tablet/helper/database_helper.dart';
import 'package:calibre_tablet/helper/shared_preferences.dart';
import 'package:calibre_tablet/models/file_model.dart';
import 'package:calibre_tablet/services/api_services.dart';
import 'package:calibre_tablet/services/dropbox_services.dart';
import 'package:calibre_tablet/view/screens/auth_screen.dart';
import 'package:calibre_tablet/view/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../helper/connection_checker.dart';
import '../helper/permission_helper.dart';

class HomeController extends GetxController {
  DatabaseHelper databaseHelper = DatabaseHelper();
  DropboxService dropboxService = DropboxService();
  ApiServices apiServices = ApiServices();
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
    isLoading = false;
    update();
  }

  ///===============================
  Future<void> getServices() async {
    try {
      setErrorSyncResponseProgress();

      // Step 1: Request storage permission
      if (!await requestManageExternalStoragePermission()) return;

      // Step 2: Select a folder
      String? selectedFolder = await selectFolder();
      if (selectedFolder == null) {
        showToast(message: "Storage Not Selected", isError: true);
        return;
      }

      // Step 3: Check internet connection
      if (!await checkInternet()) return;

      // Step 4: Check authorization and sync
      setLoading(true);
      if (await SharedPref.getUserAuthorization != true) {
        // User is not authorized; redirect to login
        await Get.to(DropboxAuthScreen());
      }

      await _authenticateAndSync();
    } catch (e) {
      debugPrint("Error in getServices: $e");
      setErrorSyncResponseProgress();
    } finally {
      setErrorSyncResponseProgress();
    }
  }

  /// Handles authentication and syncing with Dropbox
  Future<void> _authenticateAndSync() async {
    setTotalDownloading(name: "Connecting Dropbox...");
    String? accessToken = await SharedPref.getAccessToken;
    String? refreshToken = await SharedPref.getRefreshToken;

    if (accessToken == null) {
      await SharedPref.storeUserAuthorization(false);
      await getServices(); // Restart the process to re-authenticate
    } else if (refreshToken == null) {
      bool refreshResult = await apiServices.refreshToken();
      await _syncDropboxFiles(refreshResult);
    } else {
      await _syncDropboxFiles(true);
    }
  }

  /// Syncs files from Dropbox and handles success/error cases
  Future<void> _syncDropboxFiles(bool isAuthorized) async {
    if (!isAuthorized) {
      setErrorSyncResponseProgress();
      debugPrint("Authorization failed. Unable to sync Dropbox files.");
      return;
    }

    bool syncResult = await dropboxService.syncDropboxFiles();
    if (syncResult) {
      await fetchAllFiles();
    } else {
      setErrorSyncResponseProgress();
      debugPrint("Dropbox file sync failed.");
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
}
