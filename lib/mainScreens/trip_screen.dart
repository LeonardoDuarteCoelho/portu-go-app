import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/global/global.dart';
import 'package:portu_go_driver/models/passenger_ride_request_info.dart';

import '../assistants/assistant_google_map_theme.dart';
import '../assistants/assistant_methods.dart';
import '../components/progress_dialog.dart';
import '../constants.dart';
import '../models/direction_route_details.dart';

class TripScreen extends StatefulWidget {
  PassengerRideRequestInfo? passengerRideRequestInfo;

  TripScreen({super.key, this.passengerRideRequestInfo});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  @override
  bool get wantKeepAlive => true;
  String driverName = '';
  String driverEmail = '';
  String driverPhone = '';
  double tripInfoContainerHeight = 260; // Trip info panel's height.
  double mapControlsContainerHeight = 300; // Map controls' height.
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
  String? btnTitle = 'Passageiro recolhido';
  Color? btnColor = AppColors.indigo7;
  Set<Marker> markersSet = Set<Marker>();
  Set<Polyline> polylineSet = Set<Polyline>();
  List<LatLng> polylineCoordinatesList = [];
  PolylinePoints polylinePoints = PolylinePoints();
  LatLngBounds? latLngBounds;
  DatabaseReference? rideRequestRef;
  Map? driverLocationDataMap;
  Map? driverCarInfoMap;
  DatabaseReference? driverTripsHistoryRef;

  @override
  void initState() {
    super.initState();
    saveAssignedDriverDataToRideRequest();
  }

  setNavigatorPop() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map:
          Padding(
            padding: EdgeInsets.only(bottom: tripInfoContainerHeight),
            child: GoogleMap(
              initialCameraPosition: _dummyLocation,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: markersSet,
              polylines: polylineSet,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setGoogleMapThemeToBlack(newGoogleMapController!);

                var driverCurrentLatitudeAndLongitude = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
                var passengerCurrentLatitudeAndLongitude = widget.passengerRideRequestInfo!.originLatitudeAndLongitude;

                drawPolylineFromOriginToDestination(driverCurrentLatitudeAndLongitude, passengerCurrentLatitudeAndLongitude!);
              },
            ),
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

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: tripInfoContainerHeight,
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.whiteTransparent30,
                    blurRadius: AppSpaceValues.space3,
                    spreadRadius: 0.5,
                    offset: Offset(0.6, 0.6)
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpaceValues.space3,
                  vertical: AppSpaceValues.space3,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_pin_circle_outlined,
                          size: AppSpaceValues.space4,
                          color: AppColors.success5,
                        ),

                        const SizedBox(width: AppSpaceValues.space2),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 325,
                              child: Text(
                                '${AppStrings.passenger} ${widget.passengerRideRequestInfo!.passengerName}',
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: AppColors.gray9,
                                  fontSize: AppFontSizes.m,
                                  fontWeight: AppFontWeights.light,
                                ),
                              ),
                            ),
                            Text(
                              // Handling the pick up location name:
                              widget.passengerRideRequestInfo!.originAddress!,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: AppColors.gray9,
                                fontSize: AppFontSizes.sm,
                                fontWeight: AppFontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpaceValues.space2),
                    const Divider(height: 1, thickness: 1, color: AppColors.gray5),
                    const SizedBox(height: AppSpaceValues.space2),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: AppSpaceValues.space4,
                          color: AppColors.error,
                        ),

                        const SizedBox(width: AppSpaceValues.space2),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Destino a 2 horas e 35 minutos',
                              style: TextStyle(
                                color: AppColors.gray9,
                                fontSize: AppFontSizes.m,
                                fontWeight: AppFontWeights.light,
                              ),
                            ),
                            SizedBox(
                              width: 325,
                              child: Text(
                                // Handling the pick up location name:
                                widget.passengerRideRequestInfo!.destinationAddress!,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: AppColors.gray9,
                                  fontSize: AppFontSizes.sm,
                                  fontWeight: AppFontWeights.regular,
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

                    CustomButton(
                      text: btnTitle!,
                      backgroundColor: btnColor,
                      btnContentSize: AppFontSizes.m,
                      icon: Icons.person,
                      onPressed: () {

                      }
                    ),

                    const SizedBox(height: AppSpaceValues.space2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ## Method responsible for tracing the polyline-based route when the passenger selects his destination.
  ///
  /// ### Step 1: When driver accepts the passenger's request.
  /// 1. 'LatLng originLatitudeAndLongitude': Driver's position when trip is initiated.
  /// 2. 'LatLng destinationLatitudeAndLongitude': Passenger's position when request is confirmed.
  ///
  /// ### Step 2: When driver picks the passenger up.
  /// 1. 'LatLng originLatitudeAndLongitude': Driver's position when passenger is picked up.
  /// 2. 'LatLng destinationLatitudeAndLongitude': Passenger's destination.
  Future<void> drawPolylineFromOriginToDestination(LatLng originLatitudeAndLongitude, LatLng destinationLatitudeAndLongitude) async {
    showDialog(context: context, builder: (BuildContext context) => ProgressDialog(message: AppStrings.loading3));

    var directionRouteDetails = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
      originLatitudeAndLongitude, destinationLatitudeAndLongitude
    );
    setNavigatorPop();

    PolylinePoints polylinePoints = PolylinePoints();
    // The below 'List' only accepts 'LatLang' values!
    List<PointLatLng> decodedPolylinePointsList = polylinePoints.decodePolyline(directionRouteDetails!.ePoints!);
    polylineCoordinatesList.clear(); // Clearing previous polyline.

    if(decodedPolylinePointsList.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsList) {
        polylineCoordinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polylineId'),
        color: AppColors.indigo5,
        jointType: JointType.round,
        points: polylineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });

    // Conditions to better calibrate the camera so the user, when selecting his destination, can easily see the route in its entirety.
    if(originLatitudeAndLongitude.latitude > destinationLatitudeAndLongitude.latitude
        && originLatitudeAndLongitude.longitude > destinationLatitudeAndLongitude.longitude) {
      latLngBounds = LatLngBounds(
          southwest: destinationLatitudeAndLongitude,
          northeast: originLatitudeAndLongitude
      );
    } else if(originLatitudeAndLongitude.longitude > destinationLatitudeAndLongitude.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(originLatitudeAndLongitude.latitude, destinationLatitudeAndLongitude.longitude),
        northeast: LatLng(destinationLatitudeAndLongitude.latitude, originLatitudeAndLongitude.longitude),
      );
    } else if(originLatitudeAndLongitude.latitude > destinationLatitudeAndLongitude.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(destinationLatitudeAndLongitude.latitude, originLatitudeAndLongitude.longitude),
        northeast: LatLng(originLatitudeAndLongitude.latitude, destinationLatitudeAndLongitude.longitude),
      );
    } else {
      latLngBounds = LatLngBounds(
          southwest: originLatitudeAndLongitude,
          northeast: destinationLatitudeAndLongitude
      );
    }
    // Adjusting camera for better displaying the polyline-based route:
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds!, AppSpaceValues.space11));

    Marker originMarker = Marker(
      markerId: const MarkerId('originMarkerId'),
      position: originLatitudeAndLongitude,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationMarkerId'),
      position: destinationLatitudeAndLongitude,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });
  }

  /// Saving assigned driver's data to the Realtime Database.
  saveAssignedDriverDataToRideRequest() {
    rideRequestRef = FirebaseDatabase.instance.ref().child('rideRequests').child(widget.passengerRideRequestInfo!.rideRequestId!);
    driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    driverCarInfoMap = {
      'carColor': driverData.carColor!,
      'carModel': driverData.carModel!,
      'carNumber': driverData.carNumber!,
      'carType': driverData.carType!,
    };

    rideRequestRef?.child('driverLocation').set(driverLocationDataMap);
    rideRequestRef?.child('status').set('accepted');
    rideRequestRef?.child('driverId').set(driverData.id);
    rideRequestRef?.child('driverName').set(driverData.name);
    rideRequestRef?.child('driverPhone').set(driverData.phone);
    rideRequestRef?.child('driverCarInfo').set(driverCarInfoMap);
    saveRideRequestDataToTheRecords();
  }

  /// Saving data of all trips the driver had.
  saveRideRequestDataToTheRecords() {
    DatabaseReference driverTripsHistoryRef = FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid).child('tripsHistory');
    driverTripsHistoryRef.child(widget.passengerRideRequestInfo!.rideRequestId!).set(true);
  }
}
