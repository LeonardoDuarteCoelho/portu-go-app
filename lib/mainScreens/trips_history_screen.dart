import 'package:flutter/material.dart';
import 'package:portu_go_driver/components/trip_history_design_ui.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';
import 'main_screen.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.indigo7,
        title: const Text(
          AppStrings.tripsHistory,
          style: TextStyle(
            fontSize: AppFontSizes.l,
            color: AppColors.white,
            fontWeight: AppFontWeights.medium
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          iconSize: AppSpaceValues.space4,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: AppColors.gray3,
            margin: const EdgeInsets.only(
              left: AppSpaceValues.space2,
              top: AppSpaceValues.space2,
              right: AppSpaceValues.space2,
            ),
            child: TripHistoryDesignUI(
              tripsHistoryModel: Provider.of<AppInfo>(context, listen: false).tripHistoryInfoList[index],
            ),
          );
        },
        itemCount: numberOfTripsToBeDisplayedInHistory,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
