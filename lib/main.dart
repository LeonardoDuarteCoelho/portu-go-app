import 'package:flutter/material.dart';
import 'package:portu_go_driver/splashScreen/splash_screen.dart';

/// CHANGELOG:
///
/// (23/01/2024)
/// The initial 'main.dart' file created by the Flutter app itself was modified before the start of development.
/// The reason for those changes is due to my constant need to restart the function, since we'll be implementing
/// the live location for both the passengers as well as the drivers. Therefore, I modified the initial 'main.dart'
/// to basically make the app work better, playing an important role.
///
/// The utilization of 'WidgetsFlutterBinding.ensureInitialized()' for instance, makes asynchronous operations
/// before running the app (like initializing Firebase or other services) way more viable.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(
      child: MaterialApp(
        title: 'PortuGO Driver',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MySplashScreen(),
        debugShowCheckedModeBanner: false,
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
