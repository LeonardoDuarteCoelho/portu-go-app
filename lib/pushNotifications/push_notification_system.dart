import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portu_go_driver/global/global.dart';
import 'package:portu_go_driver/models/passenger_ride_request_info.dart';

import '../constants.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  double? originLatitude;
  double? originLongitude;
  String? originAddress;
  double? destinationLatitude;
  double? destinationLongitude;
  String? destinationAddress;
  String? passengerId;
  String? passengerName;
  String? passengerPhone;

  Future initializeCloudMessaging() async {
    //  +------------------------------------------------------------------------------------+
    //  |                                   TYPES OF STATE                                   |
    //  +------------+-----------------------------------------------------------------------+
    //  | Foreground | When the application is open, in view & in use.                       |
    //  +------------+-----------------------------------------------------------------------+
    //  | Background | When the application is open, however in the background (minimised).  |
    //  |            | This typically occurs when the user has pressed the "home" button on  |
    //  |            | the device, has switched to another app via the app switcher or has   |
    //  |            | the application open on a different tab (web).                        |
    //  +------------+-----------------------------------------------------------------------+
    //  | Terminated | When the device is locked or the application is not running. The      |
    //  |            | user can terminate an app by "swiping it away" via the app switcher   |
    //  |            | UI on the device or closing a tab (web).                              |
    //  +------------+-----------------------------------------------------------------------+
    //  -->  MORE INFO IN THE DOCUMENTATION: https://firebase.flutter.dev/docs/messaging/usage

    // 1. Terminated state:
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if(remoteMessage != null) {
        // TODO: Display passenger's ride request information.
        readPassengerRideRequestInfo(remoteMessage.data['rideRequestId']);
      }
    });

    // 2. Foreground state:
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      // TODO: Display passenger's ride request information.
      readPassengerRideRequestInfo(remoteMessage?.data['rideRequestId']);
    });

    // 3. Background state:
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      // TODO: Display passenger's ride request information.
      readPassengerRideRequestInfo(remoteMessage?.data['rideRequestId']);
    });
  }

  readPassengerRideRequestInfo(String passengerRideRequestId) {
    FirebaseDatabase.instance.ref().child('rideRequests').child('passengerRideRequestId').once().then((snapData) {
      if(snapData.snapshot.value != null) {
        // Getting the ride request information from the database:
        originLatitude = double.parse((snapData.snapshot.value! as Map)['origin']['latitude']);
        originLongitude = double.parse((snapData.snapshot.value! as Map)['origin']['longitude']);
        originAddress = (snapData.snapshot.value! as Map)['originAddress'];
        destinationLatitude = double.parse((snapData.snapshot.value! as Map)['destination']['latitude']);
        destinationLongitude = double.parse((snapData.snapshot.value! as Map)['destination']['longitude']);
        destinationAddress = (snapData.snapshot.value! as Map)['destinationAddress'];
        passengerId = (snapData.snapshot.value! as Map)['passengerId'];
        passengerName = (snapData.snapshot.value! as Map)['passengerName'];
        passengerPhone = (snapData.snapshot.value! as Map)['passengerPhone'];

        // Creating an object to store the ride request information:
        PassengerRideRequestInfo passengerRideRequestInfo = PassengerRideRequestInfo();
        passengerRideRequestInfo.originLatitudeAndLongitude = LatLng(originLatitude!, originLongitude!);
        passengerRideRequestInfo.originAddress = originAddress;
        passengerRideRequestInfo.destinationLatitudeAndLongitude = LatLng(destinationLatitude!, destinationLongitude!);
        passengerRideRequestInfo.destinationAddress = destinationAddress;
        passengerRideRequestInfo.passengerId = passengerId;
        passengerRideRequestInfo.passengerName = passengerName;
        passengerRideRequestInfo.passengerPhone = passengerPhone;
      } else {
        Fluttertoast.showToast(msg: AppStrings.rideRequestError);
      }
    });
  }

  /// The registration token will be generated when...
  /// 1. The app is restored on a new device.
  /// 2. The user uninstalls/reinstall the app.
  /// 3. The user clears app data.
  ///
  /// More info in the documentations:
  /// - https://firebase.google.com/docs/cloud-messaging/android/client
  /// - https://firebase.flutter.dev/docs/messaging/usage/
  Future generateToken() async {
    String? registrationToken = await messaging.getToken(); // Get token.
    // Saving token to the database:
    FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid).child('token').set(registrationToken);

    // Below are some "topics".
    //
    // Topics are a mechanism which allow a device to subscribe and unsubscribe from named PubSub channels,
    // all managed via FCM (Firebase Cloud Messaging). Rather than sending a message to a specific device by FCM token,
    // you can instead send a message to a topic and any devices subscribed to that topic will receive the message.
    // Topics allow you to simplify FCM server integration as you do not need to keep a store of device tokens.
    //
    // More in the documentation: https://firebase.flutter.dev/docs/messaging/usage/
    messaging.subscribeToTopic('allDrivers');
    messaging.subscribeToTopic('allPassengers');
  }
}