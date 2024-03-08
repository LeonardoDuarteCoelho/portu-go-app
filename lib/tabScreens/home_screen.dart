import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/pushNotifications/push_notification_system.dart';

import '../assistants/assistant_google_map_theme.dart';
import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import '../models/direction_route_details.dart';
import '../splashScreen/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool ifUserGrantedLocationPermission = true; // Whether the app shows a warning telling the user to enable access to location or not.
  String driverCurrentStatus = AppStrings.nowOffline;
  String driverName = '';
  String driverEmail = '';
  String driverPhone = '';
  LocationPermission? _locationPermission;
  double mapControlsContainerHeight = 40;
  static const CameraPosition _dummyLocation = CameraPosition(
    target: LatLng(0, 0), // Placeholder location when app's still locating user.
    zoom: 17,
  );
  Position? geolocatorPosition;
  LatLng? latitudeAndLongitudePosition;
  CameraPosition? cameraPosition;
  var geolocator = Geolocator();
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;
  DatabaseReference? driversStatusRef;
  Position? findDriverPositionWhenOnline;

  @override
  void initState() {
    super.initState();
    checkLocationPermissionStatus();
    readCurrentDriverInfo();
  }

  navigateToSplashScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
  }

  checkLocationPermissionStatus() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.always || _locationPermission == LocationPermission.whileInUse) {
      setState(() {
        ifUserGrantedLocationPermission = true;
      });
    } else {
      setState(() {
        ifUserGrantedLocationPermission = false;
      });
    }
  }

  Future<String> getHumanReadableAddress() async {
    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(driverCurrentPosition!, context);
    return humanReadableAddress;
  }

  // Method that'll give the user's current position on the map:
  findDriverPosition() async {
    geolocatorPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = geolocatorPosition;
    latitudeAndLongitudePosition = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude
    );
    // Adjusting camera based on the user's current position:
    cameraPosition = CameraPosition(
        target: latitudeAndLongitudePosition!,
        bearing: driverCurrentPosition!.heading,
        zoom: 17
    );
    // Updating camera position:
    newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));
    getHumanReadableAddress();
  }

  readCurrentDriverInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    // Getting all the driver's information for the ride request:
    FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid).once().then((snap) {
      if(snap.snapshot.value != null) {
        driverData.id = (snap.snapshot.value as Map)['id'];
        driverData.name = (snap.snapshot.value as Map)['name'];
        driverData.phone = (snap.snapshot.value as Map)['phone'];
        driverData.email = (snap.snapshot.value as Map)['email'];
        driverData.token = (snap.snapshot.value as Map)['token'];
        driverData.carColor = (snap.snapshot.value as Map)['carInfo']['carColor'];
        driverData.carModel = (snap.snapshot.value as Map)['carInfo']['carModel'];
        driverData.carNumber = (snap.snapshot.value as Map)['carInfo']['carNumber'];
        driverData.carType = (snap.snapshot.value as Map)['carInfo']['carType'];
      } else { Fluttertoast.showToast(msg: AppStrings.getDriverDataError); }
    });
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateToken();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [

/********************************************** UI FOR THE MAP **********************************************/

        GoogleMap(
          initialCameraPosition: _dummyLocation,
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
            setGoogleMapThemeToBlack(newGoogleMapController!);
            findDriverPosition();
          },
        ),

        // Left-screen controls:
        Positioned(
          left: AppSpaceValues.space2,
          bottom: mapControlsContainerHeight,
          child: Column(
            children: [
              // Zoom-in button:
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_in',
                backgroundColor: AppColors.indigo7,
                onPressed: () {
                  newGoogleMapController?.animateCamera(CameraUpdate.zoomIn());
                },
                child: const Icon(
                  Icons.add,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: AppSpaceValues.space1),

              // Zoom-out button:
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_out',
                backgroundColor: AppColors.indigo7,
                onPressed: () {
                  newGoogleMapController?.animateCamera(CameraUpdate.zoomOut());
                },
                child: const Icon(
                  Icons.remove,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),

        // Right-screen controls:
        Positioned(
          right: AppSpaceValues.space2,
          bottom: mapControlsContainerHeight,
          child: Column(
            children: [
              // My location button:
              FloatingActionButton(
                mini: true,
                heroTag: 'my_location',
                backgroundColor: AppColors.indigo7,
                onPressed: () {
                  newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));
                },
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),

/********************************************** UI FOR DRIVER BEING OFFLINE **********************************************/

        // Transparent black background:
        (driverCurrentStatus != AppStrings.nowOnline)
        ? Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: AppColors.blackTransparent50,
        )
        : Container(),

        // Button to enable online mode:
        Positioned(
          top: (driverCurrentStatus != AppStrings.nowOnline) ? MediaQuery.of(context).size.height * 0.50 : AppSpaceValues.space5,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: (driverCurrentStatus != AppStrings.nowOnline) ? AppStrings.enterOnlineMode : AppStrings.enterOfflineMode,
                icon: Icons.phonelink_ring,
                btnContentSize: (driverCurrentStatus != AppStrings.nowOnline) ? AppFontSizes.ml : AppFontSizes.sm,
                backgroundColor: (driverCurrentStatus != AppStrings.nowOnline) ? AppColors.white : AppColors.blackTransparent50,
                textColor: (driverCurrentStatus != AppStrings.nowOnline) ? AppColors.gray9 : AppColors.white,
                onPressed: () {
                  // If driver is offline...
                  if(!ifDriverIsActive) {
                    setDriverStatusToOnline();
                    updateDriversLocationInRealtime();
                    setState(() {
                      driverCurrentStatus = AppStrings.nowOnline;
                      ifDriverIsActive = true;
                    });
                    Fluttertoast.showToast(msg: AppStrings.nowOnline);
                  } else {
                    setDriverStatusToOffline();
                    setState(() {
                      driverCurrentStatus = AppStrings.nowOffline;
                      ifDriverIsActive = false;
                    });
                    Fluttertoast.showToast(msg: AppStrings.nowOffline);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // This method will be called when the driver exits offline mode:
  setDriverStatusToOnline() async {
    findDriverPositionWhenOnline = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = findDriverPositionWhenOnline;
    // If driver's online, you'll put him as an active driver. If driver's offline, you won't do this:
    Geofire.initialize('activeDrivers');
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    driversStatusRef = FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid).child('newRideStatus');
    driversStatusRef?.set('available'); // Setting driver to be available for ride requests from passengers.
    driversStatusRef?.onValue.listen((event) {

    });
  }

  // This method will be called when the driver re-enters offline mode:
  setDriverStatusToOffline() {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    driversStatusRef = FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid).child('newRideStatus');
    driversStatusRef?.onDisconnect();
    driversStatusRef?.remove();
    driversStatusRef = null;
  }

  updateDriversLocationInRealtime() {
    LatLng latLng; // Auxiliary variable

    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      if(ifDriverIsActive) Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }
}
