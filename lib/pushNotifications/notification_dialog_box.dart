import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/global/global.dart';
import 'package:portu_go_driver/mainScreens/trip_screen.dart';
import 'package:portu_go_driver/models/passenger_ride_request_info.dart';

class NotificationDialogBox extends StatefulWidget {
  PassengerRideRequestInfo? passengerRideRequestInfo;
  NotificationDialogBox({super.key, this.passengerRideRequestInfo});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  String rideRequestId = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpaceValues.space3)
      ),
      backgroundColor: AppColors.white,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(AppSpaceValues.space2),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpaceValues.space2),
          color: AppColors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpaceValues.space3),
          child: Column(
            children: [
              Image.asset('images/ic-car-flat.png', width: 125),

              const SizedBox(height: AppSpaceValues.space2),

              const Text(
                AppStrings.newRequest,
                style: TextStyle(
                  fontWeight: AppFontWeights.bold,
                  fontSize: AppFontSizes.xl,
                  color: AppColors.indigo7,
                ),
              ),

              const SizedBox(height: AppSpaceValues.space3),
              const Divider(height: 1, thickness: 1, color: AppColors.gray5),
              const SizedBox(height: AppSpaceValues.space2),

              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.location_history_sharp,
                            size: AppSpaceValues.space4,
                            color: AppColors.success5,
                          ),

                          SizedBox(width: AppSpaceValues.space1),

                          Text(
                            '${AppStrings.origin}:',
                            style: TextStyle(
                              fontWeight: AppFontWeights.semiBold,
                              fontSize: AppFontSizes.ml,
                              color: AppColors.gray9,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpaceValues.space1),

                      Text(
                        widget.passengerRideRequestInfo!.originAddress!,
                        style: const TextStyle(
                          fontWeight: AppFontWeights.regular,
                          fontSize: AppFontSizes.ml,
                          color: AppColors.gray9,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpaceValues.space3),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_sharp,
                            size: AppSpaceValues.space4,
                            color: AppColors.error,
                          ),

                          SizedBox(width: AppSpaceValues.space1),

                          Text(
                            '${AppStrings.destination}:',
                            style: TextStyle(
                              fontWeight: AppFontWeights.semiBold,
                              fontSize: AppFontSizes.ml,
                              color: AppColors.gray9,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpaceValues.space1),

                      Text(
                        widget.passengerRideRequestInfo!.destinationAddress!,
                        style: const TextStyle(
                          fontWeight: AppFontWeights.regular,
                          fontSize: AppFontSizes.ml,
                          color: AppColors.gray9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpaceValues.space2),
              const Divider(height: 1, thickness: 1, color: AppColors.gray5),
              const SizedBox(height: AppSpaceValues.space5),

              Column(
                children: [
                  CustomButton(
                    text: AppStrings.acceptRequest,
                    backgroundColor: AppColors.success5,
                    textColor: AppColors.white,
                    icon: Icons.check,
                    btnContentSize: AppFontSizes.ml,
                    onPressed: () {
                      acceptRideRequest(context);
                    }
                  ),

                  const SizedBox(height: AppSpaceValues.space4),

                  CustomButton(
                      text: AppStrings.denyRequest,
                      backgroundColor: AppColors.error,
                      textColor: AppColors.white,
                      icon: Icons.close,
                      btnContentSize: AppFontSizes.ml,
                      onPressed: () {
                        Navigator.pop(context);
                      }
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context) {
    FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid)
    .child('newRideStatus').once().then((snap) {
      if(snap.snapshot.value != null) {
        rideRequestId = snap.snapshot.value.toString();
      } else {
        Fluttertoast.showToast(msg: AppStrings.rideRequestDoesNotExistError);
      }
      if(rideRequestId == widget.passengerRideRequestInfo!.rideRequestId) {
        FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid)
        .child('newRideStatus').set('busy');
        // Going to the trip screen with the ride request info:
        Navigator.push(context, MaterialPageRoute(
          builder: (c) => TripScreen(passengerRideRequestInfo : widget.passengerRideRequestInfo)
        ));
      } else {
        Fluttertoast.showToast(msg: AppStrings.rideRequestDeletedByPassenger);
      }
    });
  }
}
