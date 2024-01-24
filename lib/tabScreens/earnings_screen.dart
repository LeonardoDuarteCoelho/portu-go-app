import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
          AppStrings.earningsScreenTitle
      ),
    );
  }
}


