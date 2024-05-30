// Global variables available for the entire project:

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:portu_go_driver/models/driver_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
StreamSubscription<Position>? streamSubscriptionPositionHomeScreen;
StreamSubscription<Position>? streamSubscriptionPositionTripScreen;
bool ifDriverIsActive = false; // Check if driver is on offline mode.
bool ifDarkThemeIsActive = false; // Check the app's color theme.
Position? driverCurrentPosition;
DriverModel driverData = DriverModel();
String? driverVehicleType = '';
int maxNumberOfRatingStarts = 5;
const portuGoWebsiteUrl = 'https://portugo-c7f05.web.app/';
String driverRatingDescription = '';
double driverRatingsNumber = 0;
int numberOfTripsToBeDisplayedInHistory = 0;
