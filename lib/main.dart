import 'package:calibre_tablet/utils/colors.dart';
import 'package:calibre_tablet/view/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'helper/permission_helper.dart';
import 'helper/scroll_behaviour.dart';

GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        navigatorKey: navKey,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            ),
          );
        },
        onGenerateRoute: (settings) {
          debugPrint('setting===========${settings.name}');
          print("Name ${settings.name}");
          List<String> parts = settings.name!.split('/');
          // Get the last part of the split string
          print("Parts $parts");
          String routeName = parts[1];
          print("Routes is : $routeName");
          String uuid = parts.last;
          return MaterialPageRoute(
            builder: (context) {
              return MainScreen();
            },
          );
        },
        debugShowCheckedModeBanner: false,
        title: 'CalibreTablet',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: const MaterialColor(0x219942, AppColor.primaryColor),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }),
        ),
        //home:  PDFListScreen());
        home: const MainScreen());
  }
}
