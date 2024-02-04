import 'package:flutter/material.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/global/global.dart';

import '../splashScreen/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomButton(
          text: AppStrings.signOut,
          onPressed: () {
            fAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
          }
      ),
    );
  }
}
