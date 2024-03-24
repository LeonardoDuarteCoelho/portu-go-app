import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:portu_go_driver/components/profile_info_design_ui.dart';
import 'package:portu_go_driver/global/global.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/button.dart';
import '../constants.dart';
import '../infoHandler/app_info.dart';
import '../splashScreen/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double btnWidth = 300;

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
          driverRatingDescription = '${AppStrings.driverRatingOneStar} ${AppStrings.rating}';
        });
        break;
      case <= 2:
        setState(() {
          driverRatingDescription = '${AppStrings.driverRatingTwoStar} ${AppStrings.rating}';
        });
        break;
      case <= 3:
        setState(() {
          driverRatingDescription = '${AppStrings.driverRatingThreeStar} ${AppStrings.rating}';
        });
        break;
      case <= 4:
        setState(() {
          driverRatingDescription = '${AppStrings.driverRatingFourStar} ${AppStrings.rating}';
        });
        break;
      case <= 5:
        setState(() {
          driverRatingDescription = '${AppStrings.driverRatingFiveStar} ${AppStrings.rating}';
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray3,
      body: Padding(
        padding: const EdgeInsets.all(AppSpaceValues.space3),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                driverData.name!,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSizes.l,
                  color: AppColors.gray9,
                  fontWeight: AppFontWeights.medium,
                  height: AppLineHeights.ml
                ),
              ),

              const SizedBox(height: AppSpaceValues.space3, child: Divider(color: AppColors.gray7)),
              const SizedBox(height: AppSpaceValues.space3),

              InfoDesignUI(
                textInfo: driverRatingDescription,
                icon: Icons.star,
              ),
              InfoDesignUI(
                textInfo: driverData.phone!,
                icon: Icons.phone,
              ),
              InfoDesignUI(
                textInfo: driverData.email!,
                icon: Icons.email,
              ),
              InfoDesignUI(
                textInfo: '${driverData.carModel!}, Placa ${driverData.carNumber!}, Cor ${driverData.carColor!}, Tipo ${driverData.carType!}',
                icon: Icons.car_crash,
              ),

              const SizedBox(height: AppSpaceValues.space3),
              const SizedBox(height: AppSpaceValues.space3, child: Divider(color: AppColors.gray7)),
              const SizedBox(height: AppSpaceValues.space3),

              CustomButton(
                width: btnWidth,
                text: ifDarkThemeIsActive ? AppStrings.lightMode : AppStrings.darkMode,
                icon: ifDarkThemeIsActive ? Icons.light_mode_outlined : Icons.nightlight_outlined,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
                  setState(() {
                    ifDarkThemeIsActive ? ifDarkThemeIsActive = false : ifDarkThemeIsActive = true;
                  });
                  ifDarkThemeIsActive ? Fluttertoast.showToast(msg: AppStrings.darkModeNowOn) : Fluttertoast.showToast(msg: AppStrings.lightModeNowOn);
                }
              ),

              const SizedBox(height: AppSpaceValues.space3),

              CustomButton(
                width: btnWidth,
                text: AppStrings.aboutUs,
                icon: Icons.info_outline,
                onPressed: () {
                launchUrl(
                    Uri.parse(portuGoWebsiteUrl),
                    mode: LaunchMode.inAppBrowserView
                );
                }
              ),

              const SizedBox(height: AppSpaceValues.space5),

              CustomButton(
                width: btnWidth,
                text: AppStrings.signOut,
                icon: Icons.logout,
                backgroundColor: AppColors.error,
                onPressed: () {
                  fAuth.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
