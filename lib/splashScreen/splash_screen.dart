import 'dart:async';

import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/mainScreens/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 13), () async {
      // Sending the user to the main screen:
      Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
    });
  }

  // 'initState()' will be called whenever we go to any page of the app.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: AppColors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
      
              Image.asset('images/pexels-peter-fazekas-1386649.jpg'),
              const SizedBox(height: 10),
              const Text(
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
