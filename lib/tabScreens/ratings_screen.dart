import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        AppStrings.ratingsScreenTitle
      ),
    );
  }
}
