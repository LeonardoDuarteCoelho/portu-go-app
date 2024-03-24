import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:portu_go_driver/models/driver_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
StreamSubscription<Position>? streamSubscriptionPositionHomeScreen;
StreamSubscription<Position>? streamSubscriptionPositionTripScreen;
bool ifDriverIsActive = false; // Check if driver is on offline mode.
bool ifDarkThemeIsActive = false;
Position? driverCurrentPosition;
DriverModel driverData = DriverModel();
String? driverVehicleType = '';
int maxNumberOfRatingStarts = 5;
// TODO: Replace this placeholder URL, which is the one for the Figma project, with the real URL for the website:
const portuGoWebsiteUrl = 'https://portugo-c7f05.web.app/';
String driverRatingDescription = '';
double driverRatingsNumber = 0;
int numberOfTripsToBeDisplayedInHistory = 0;
