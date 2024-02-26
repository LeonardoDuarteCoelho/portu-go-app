import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/constants.dart';

import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import '../models/direction_route_details.dart';
import '../splashScreen/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  bool ifUserGrantedLocationPermission = true; // Whether the app shows a warning telling the user to enable access to location or not.
  bool showRouteConfirmationOptions = false; // Show the user options to confirm or deny the pick-up-to-drop-off route.
  bool ifRouteIsConfirmed = false; // Check if user confirmed the route for selected destination.
  String driverCurrentStatus = AppStrings.nowOffline;
  String? pickUpLocationText;
  String? dropOffLocationText;
  String driverName = '';
  String driverEmail = '';
  String driverPhone = '';
  LocationPermission? _locationPermission;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double mapControlsContainerHeight = 40;

  // Geolocator variables:
  static const CameraPosition _dummyLocation = CameraPosition(
    target: LatLng(0, 0), // Placeholder location when app's still locating user.
    zoom: 17,
  );
  Position? geolocatorPosition;
  LatLng? latitudeAndLongitudePosition;
  Position? driverCurrentPosition;
  CameraPosition? cameraPosition;
  var geolocator = Geolocator();
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  // Map route variables:
  dynamic responseFromSearchScreen;
  DirectionRouteDetails? directionRouteDetails;
  List<LatLng> polylineCoordinatesList = [];
  Set<Polyline> polylineSet = {};
  LatLngBounds? latLngBounds;
  Set<Marker> markersSet = {};

  // Geofire variables:
  DatabaseReference? driversStatusRef;
  Position? findDriverPositionWhenOnline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Adding an observer that checks when the user leaves the app.
    checkLocationPermissionStatus();
  }

  // This 'dispose()' method will be automatically called when the user leaves the app:
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // If app is in the background or closed...
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      setDriverStatusToOffline();
      setState(() {
        driverCurrentStatus = AppStrings.nowOffline;
        ifDriverIsActive = false;
      });
    }
  }

  navigateToSplashScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
  }

  setGoogleMapThemeToBlack (bool changeToBlackTheme) {
    if(changeToBlackTheme) {
      newGoogleMapController?.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
    }
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
            setGoogleMapThemeToBlack(false);
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
