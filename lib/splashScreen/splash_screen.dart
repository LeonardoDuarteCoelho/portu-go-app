import 'dart:async';

import 'package:flutter/material.dart';
import 'package:portu_go_driver/authenticationScreens/login_screen.dart';
import 'package:portu_go_driver/authenticationScreens/signup_screen.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/mainScreens/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  // Duration of the splash screen:
  static const int splashScreenTimer = 3;

  startTimer() {
    Timer(const Duration(seconds: splashScreenTimer), () async {
      // Sending the user to the main screen:
      Navigator.push(context, MaterialPageRoute(builder: (c) => const LogInScreen()));
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
                AppStrings.welcomeMessage,
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
