import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../constants.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';
import '../splashScreen/splash_screen.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({ super.key });

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {

  @override
  void initState() {
    super.initState();
    getRatingsNumber();
  }

  getRatingsNumber() {
    setState(() {
      driverRatingsNumber = double.parse(Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });
    setRatingsTitle();
  }

  setRatingsTitle() {
    switch(driverRatingsNumber) {
      case 0:
        setState(() {
          driverRatingDescription = AppStrings.driverNoRatings;
        });
        break;
      case <= 1:
        setState(() {
          driverRatingDescription = AppStrings.driverRatingOneStar;
        });
        break;
      case <= 2:
        setState(() {
          driverRatingDescription = AppStrings.driverRatingTwoStar;
        });
        break;
      case <= 3:
        setState(() {
          driverRatingDescription = AppStrings.driverRatingThreeStar;
        });
        break;
      case <= 4:
        setState(() {
          driverRatingDescription = AppStrings.driverRatingFourStar;
        });
        break;
      case <= 5:
        setState(() {
          driverRatingDescription = AppStrings.driverRatingFiveStar;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.indigo7,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpaceValues.space5),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter, // Gradient begins at the top
              end: Alignment.bottomCenter, // And ends at the bottom
              colors: [
                AppColors.gray2,
                AppColors.gray0,
                AppColors.gray0,
                AppColors.gray2
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpaceValues.space5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpaceValues.space4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppStrings.driverAverageRatings,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: AppFontWeights.semiBold,
                      color: AppColors.gray9,
                      fontSize: AppFontSizes.l,
                      height: AppLineHeights.ml
                  ),
                ),

                const SizedBox(height: AppSpaceValues.space4),
                const Divider(height: 1, thickness: 1, color: AppColors.gray5),
                const SizedBox(height: AppSpaceValues.space4),

                SmoothStarRating(
                  rating: driverRatingsNumber,
                  allowHalfRating: false,
                  starCount: maxNumberOfRatingStarts,
                  size: AppSpaceValues.space6,
                  color: AppColors.indigo9,
                ),

                const SizedBox(height: AppSpaceValues.space2),

                Text(
                  driverRatingDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: AppFontWeights.medium,
                    color: AppColors.gray9,
                    fontSize: AppFontSizes.xl,
                  ),
                ),

                const SizedBox(height: AppSpaceValues.space4),
                const Divider(height: 1, thickness: 1, color: AppColors.gray5),
                const SizedBox(height: AppSpaceValues.space4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
