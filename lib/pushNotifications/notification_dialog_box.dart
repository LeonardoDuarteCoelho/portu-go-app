import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:portu_go_driver/assistants/assistant_methods.dart';
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('images/ic-car-flat.png', width: 100),

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

                      SizedBox(
                        width: 300,
                        child: Text(
                          widget.passengerRideRequestInfo!.originAddress!,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: AppFontWeights.regular,
                            fontSize: AppFontSizes.ml,
                            color: AppColors.gray9,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpaceValues.space3),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_sharp,
                            size: AppSpaceValues.space4,
                            color: AppColors.error,
                          ),

                          const SizedBox(width: AppSpaceValues.space1),

                          Text(
                            '${AppStrings.destination} (${widget.passengerRideRequestInfo!.originToDestinationDistance}):',
                            style: const TextStyle(
                              fontWeight: AppFontWeights.semiBold,
                              fontSize: AppFontSizes.ml,
                              color: AppColors.gray9,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpaceValues.space1),

                      SizedBox(
                        width: 300,
                        child: Text(
                          widget.passengerRideRequestInfo!.destinationAddress!,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: AppFontWeights.regular,
                            fontSize: AppFontSizes.ml,
                            color: AppColors.gray9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpaceValues.space2),
              const Divider(height: 1, thickness: 1, color: AppColors.gray5),
              const SizedBox(height: AppSpaceValues.space4),

              Column(
                children: [
                  CustomButton(
                    text: AppStrings.acceptRequest,
                    backgroundColor: AppColors.success5,
                    textColor: AppColors.white,
                    icon: Icons.check,
                    btnContentSize: AppFontSizes.m,
                    onPressed: () {
                      FirebaseDatabase.instance.ref().child('rideRequests').child(widget.passengerRideRequestInfo!.rideRequestId!).once().then((snap) {
                        if (snap.snapshot.value != null) {
                          acceptRideRequest(context);
                        } else {
                          Fluttertoast.showToast(msg: AppStrings.passengerHasCanceledRequest);
                          Navigator.pop(context);
                        }
                      });
                    },
                  ),

                  const SizedBox(height: AppSpaceValues.space3),

                  CustomButton(
                      text: AppStrings.denyRequest,
                      backgroundColor: AppColors.error,
                      textColor: AppColors.white,
                      icon: Icons.close,
                      btnContentSize: AppFontSizes.m,
                      onPressed: () {
                        FirebaseDatabase.instance.ref().child('rideRequests').child(widget.passengerRideRequestInfo!.rideRequestId!).remove().then((value) {
                          FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid).child('newRideStatus').set('available');
                        }).then((value) {
                          FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid).child('tripsHistory')
                          .child(widget.passengerRideRequestInfo!.rideRequestId!);
                        }).then((value) {
                          Fluttertoast.showToast(msg: AppStrings.rideRequestCanceledByDriver);
                        });
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
        FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid).child('newRideStatus').set('busy');
        // Stop live location tracking of the driver's position:
        AssistantMethods.pauseLiveLocationUpdates();
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
