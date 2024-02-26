import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/driver_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
DriverModel? driverModelCurrentInfo;
StreamSubscription<Position>? streamSubscriptionPosition;
bool ifDriverIsActive = false; // Check if driver is on offline mode.

