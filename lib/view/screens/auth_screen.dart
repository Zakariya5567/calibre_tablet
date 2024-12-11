import 'package:calibre_tablet/helper/shared_preferences.dart';
import 'package:calibre_tablet/services/api_services.dart';
import 'package:calibre_tablet/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DropboxAuthScreen extends StatefulWidget {
  @override
  _DropboxAuthScreenState createState() => _DropboxAuthScreenState();
}

class _DropboxAuthScreenState extends State<DropboxAuthScreen> {
  late final WebViewController _controller;
  ApiServices apiServices = ApiServices();

  bool isLoading = true;

  setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint("Page loading progress: $progress%");
            if (progress == 100) {
              setLoading(false);
            }
          },
          onPageStarted: (String url) {
            debugPrint("Page started loading: $url");
          },
          onPageFinished: (String url) {
            debugPrint("Page finished loading: $url");
          },
          onHttpError: (HttpResponseError error) {
            debugPrint("HTTP error: ${error.toString()}");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("Web resource error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) async {
            debugPrint("Navigation to: ${request.url}");

            // Check if the URL matches your redirect URI
            if (request.url.startsWith(
                'https://www.dropbox.com/1/oauth2/authorize_submit')) {
              final uri = Uri.parse(request.url);

              // Extract the "code" query parameter
              final code = uri.queryParameters['code'];

              if (code != null) {
                debugPrint("Authorization code: $code");
                SharedPref.storeUserAuthorization(true);
                SharedPref.storeAuthorization(code);
                await apiServices.tokenExchange();
                Get.back(result: code);
              } else {
                debugPrint("Authorization code not found.");
              }
              // Prevent further navigation to the redirect URL
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://www.dropbox.com/oauth2/authorize?client_id=pzpv8lytvlnadby&redirect_uri=$redirectUri&token_access_type=offline&response_type=code&force_reapprove=true'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whitePrimary,
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),
          isLoading == false
              ? SizedBox()
              : Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.blackPrimary,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
