import 'dart:async';

import 'package:flutter/material.dart';
import 'package:portu_go_driver/authenticationScreens/login_screen.dart';
import 'package:portu_go_driver/authenticationScreens/signup_screen.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/global/global.dart';
import 'package:portu_go_driver/mainScreens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Duration of the splash screen:
  static const int splashScreenTimer = 3;

  navigateToLogInScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => const LogInScreen()));
  }

  navigateToMainScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
  }

  startTimer() {
    Timer(const Duration(seconds: splashScreenTimer), () async {
      // TODO: Check if this "await" prefix is necessary for the app.
      if(await fAuth.currentUser != null) {
        currentFirebaseUser = fAuth.currentUser;
        navigateToMainScreen();
      } else {
        navigateToLogInScreen();
      }
    });
  }

  // 'initState()' will be called whenever we go to any page of the app.
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: AppColors.white,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
      
              SizedBox(height: 10),
              Text(
                "Splash Screen",
                style: TextStyle(
                  fontFamily: AppFontFamilies.primaryFont,
                  fontSize: AppFontSizes.xl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray9,
                ),
              ),
      
            ],
          ),
        ),
      ),
    );
  }
}
