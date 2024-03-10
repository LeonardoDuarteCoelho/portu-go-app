import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:portu_go_driver/models/driver_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
StreamSubscription<Position>? streamSubscriptionPositionHomeScreen;
StreamSubscription<Position>? streamSubscriptionPositionTripScreen;
bool ifDriverIsActive = false; // Check if driver is on offline mode.
bool ifDarkThemeIsActive = true;
Position? driverCurrentPosition;
DriverModel driverData = DriverModel();

