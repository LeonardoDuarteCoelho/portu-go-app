import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
          AppStrings.profileScreenTitle
      ),
    );
  }
}
