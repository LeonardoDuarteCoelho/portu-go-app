import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/mainScreens/trips_history_screen.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray3,
      child: Column(
        children: [
          Container(
            color: AppColors.indigo7,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpaceValues.space7),
              child: Column(
                children: [
                  const Text(
                    AppStrings.totalEarnings,
                    style: TextStyle(
                      fontWeight: AppFontWeights.semiBold,
                      color: AppColors.white,
                      fontSize: AppFontSizes.l,
                    ),
                  ),
                  Text(
                    '${Provider.of<AppInfo>(context, listen: false).driverTotalEarnings} ${AppStrings.euroSymbol}',
                    style: const TextStyle(
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.white,
                      fontSize: AppFontSizes.xxxxl,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const TripsHistoryScreen()));
            },
            child: Card(
              margin: const EdgeInsets.all(AppSpaceValues.space2),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpaceValues.space2, horizontal: AppSpaceValues.space4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      color: AppColors.success5,
                      size: AppSpaceValues.space10,
                    ),

                    const SizedBox(width: AppSpaceValues.space5),

                    Column(
                      children: [
                        const Text(
                          AppStrings.totalTrips,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: AppFontWeights.bold,
                            color: AppColors.gray9,
                            fontSize: AppFontSizes.ml,
                          ),
                        ),
                        Text(
                          Provider.of<AppInfo>(context, listen: false).tripHistoryInfoList.length.toString(),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontWeight: AppFontWeights.light,
                            color: AppColors.gray9,
                            fontSize: AppFontSizes.xl,
                          ),
                        ),
                        const Text(
                          AppStrings.pressToKnowMore,
                          style: TextStyle(
                            fontWeight: AppFontWeights.semiBold,
                            color: AppColors.indigo7,
                            fontSize: AppFontSizes.m,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


