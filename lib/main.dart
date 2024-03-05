import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/infoHandler/app_info.dart';
import 'package:portu_go_driver/splashScreen/splash_screen.dart';
import 'package:provider/provider.dart';

/// ## CHANGELOG
///
/// ### (23/01/2024)
/// The initial 'main.dart' file created by the Flutter app itself was modified before the start of development.
/// The reason for those changes is due to my constant need to restart the function, since we'll be implementing
/// the live location for both the passengers as well as the drivers. Therefore, I modified the initial 'main.dart'
/// to basically make the app work better, playing an important role.
///
/// The utilization of 'WidgetsFlutterBinding.ensureInitialized()' for instance, makes asynchronous operations
/// before running the app (like initializing Firebase or other services) way more viable.
///
/// ### (31/01/2024)
/// Added Firebase connection. Credentials are all located at 'google-services.json'
///
/// ### (03/03/2024)
/// Added a 'ChangeNotifierProvider' widget for handling FCM.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Checking the host's platform (necessary for Firebase to work):
  if (Platform.isAndroid) {
    // Checking if the app is successfully connected to Firebase:
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDGhMovcs7Ov_nrrlefs3PhbnpQVdPvL8Y',
          appId: '1:455303617152:android:8e3f04b5e3756f51dae465',
          messagingSenderId: '455303617152',
          projectId: 'portugo-c7f05',
          storageBucket: 'portugo-c7f05.appspot.com',
          databaseURL: 'https://portugo-c7f05-default-rtdb.europe-west1.firebasedatabase.app',
          // Values located in 'google-services.json'.
      )
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MyApp(
      child: ChangeNotifierProvider(
        create: (context) => AppInfo(),
        child: MaterialApp(
          title: 'PortuGO Driver',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.indigo7),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      )
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget? child;

  MyApp({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
