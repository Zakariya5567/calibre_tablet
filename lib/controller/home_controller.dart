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
    update();
  }

  // Future<void> getServices() async {
  //   Get.to(DropboxAuthScreen());
  // }

  // First Method to get services from dropbox
  Future<void> getServices() async {
    setErrorSyncResponseProgress();

    // Allow Phone storage permission to download data
    bool? isGranted = await requestManageExternalStoragePermission();
    if (isGranted == false) {
      showToast(message: "Storage Permission denied", isError: true);
      return;
    }

    // Select Folder in Internal storage
    String? selectedFolder = await selectFolder();
    if (selectedFolder == null) {
      showToast(message: "Storage Not Selected", isError: true);
      return;
    }

    // Check internet connection
    final hasInternet = await checkInternet();
    if (!hasInternet) return;

    // Show Loading  and check user already LoggedIn Or Not.
    setLoading(true);
    bool? isAuthorized = await SharedPref.getUserAuthorization;

    // Check if user already loggedIn or Not
    if (isAuthorized != true) {
      await Get.to(DropboxAuthScreen());
      await authenticateWithAccessTokenAndSync();
    } else {
      // User Already logged in now proceed Next.
      await authenticateWithAccessTokenAndSync();
    }
  }

  Future<void> authenticateWithAccessTokenAndSync() async {
    String? accessToken = await SharedPref.getAccessToken;
    String? refToken = await SharedPref.getRefreshToken;
    if (accessToken == null) {
      await getServices();
    } else if (refToken == null) {
      bool refResult = await apiServices.refreshToken();
      syncDropboxFilesFromApis(refResult);
    } else {
      syncDropboxFilesFromApis(true);
    }
  }

  syncDropboxFilesFromApis(bool result) async {
    if (result == true) {
      // Sync Files from dropbox
      if (await dropboxService.syncDropboxFiles() == true) {
        await fetchAllFiles();
      } else {
        setTotalDownloading(name: null);
      }
    } else {
      debugPrint("Something went wrong");
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
