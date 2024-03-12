import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/components/fare_amount_collection_dialog.dart';
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
  double tripInfoContainerHeight = 240; // Trip info panel's height.
  static const CameraPosition _dummyLocation = CameraPosition(
    target: LatLng(0, 0), // Placeholder location when app's still locating user.
    zoom: 17,
  );
  Position? geolocatorPosition;
  LatLng? latitudeAndLongitudePosition;
  CameraPosition? cameraPosition;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;
  String? btnTitle = AppStrings.passengerPickedUp;
  Color? btnColor = AppColors.indigo7;
  IconData btnIcon = Icons.person;
  Set<Marker> markersSet = Set<Marker>();
  Set<Polyline> polylineSet = Set<Polyline>();
  List<LatLng> polylineCoordinatesList = [];
  PolylinePoints polylinePoints = PolylinePoints();
  LatLngBounds? latLngBounds;
  DatabaseReference? rideRequestRef;
  Map? driverLocationDataMap;
  Map? driverCarInfoMap;
  DatabaseReference? driverTripsHistoryRef;
  BitmapDescriptor? animatedIconMarker;
  var geolocator = Geolocator();
  LatLng? driverLatitudeAndLongitudeDuringTrip;
  LatLng oldDriverLatitudeAndLongitudeDuringTrip = const LatLng(0, 0);
  Position? driverCurrentPositionDuringTrip;
  CameraPosition? driverCameraPositionDuringTrip;
  Marker? liveMarkerDuringTrip;
  String rideRequestStatus = 'accepted';
  String tripDurationFromOriginToDestination = '';
  LatLng? originLatitudeAndLongitudeDuringTrip;
  LatLng? destinationLatitudeAndLongitudeDuringTrip;
  DirectionRouteDetails? directionDetailsDuringTrip;
  bool showDirectionRouteDetails = false;
  Map driverLatitudeAndLongitudeDuringTripDataMap = {};
  LatLng? driverLatitudeAndLongitudeWhenTripEnded;
  DirectionRouteDetails? tripDirectionDetails;
  double tripPrice = 0;
  double? driverEarningsBeforeTrip;
  double? driverEarningsAfterTrip;

  @override
  void initState() {
    super.initState();
    saveAssignedDriverDataToRideRequest();
  }

  setNavigatorPop() {
    Navigator.pop(context);
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
      'latitude': driverCurrentPosition!.latitude.toString(),
      'longitude': driverCurrentPosition!.longitude.toString(),
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

  createDriverMarker() {
    if(animatedIconMarker == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2)); // Size for the available driver icon.
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'images/car.png').then((value) {
        animatedIconMarker = value;
      });
    }
  }

  updateDriversLocationInRealtimeDuringTrip() {
    streamSubscriptionPositionTripScreen = Geolocator.getPositionStream().listen((Position position) {
      // Getting driver position to this global variable (used by 'home_screen.dart'),
      // allowing the home screen to also get updated about the driver's current position:
      driverCurrentPosition = position;
      // Getting driver position to this local variable:
      driverCurrentPositionDuringTrip = driverCurrentPosition;
      // Updating the latitude and longitude coordinates:
      driverLatitudeAndLongitudeDuringTrip = LatLng(driverCurrentPositionDuringTrip!.latitude, driverCurrentPositionDuringTrip!.longitude);
      // Setting a live marker to follow the driver's location during the trip:
      liveMarkerDuringTrip = Marker(
        markerId: const MarkerId('liveMarkerDuringTripId'),
        position: driverLatitudeAndLongitudeDuringTrip!,
        icon: animatedIconMarker!,
        infoWindow: const InfoWindow(title: 'Sua posição actual'),
      );

      // Animating camera to follow the driver's live location during the trip:
      setState(() {
        driverCameraPositionDuringTrip = CameraPosition(target: driverLatitudeAndLongitudeDuringTrip!, zoom: 17);
        newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(driverCameraPositionDuringTrip!));
        // Self-updating marker:
        markersSet.removeWhere((marker) => marker.markerId.value == 'liveMarkerDuringTripId'); // Removes old marker.
        markersSet.add(liveMarkerDuringTrip!); // Adds new marker with updated driver location.
      });

      // Assigning old driver latitude and longitude coordinates. This helps with the calculation of the trip duration in realtime,
      // which is done inside the 'updateDurationInRealtimeDuringTrip' method:
      oldDriverLatitudeAndLongitudeDuringTrip = driverLatitudeAndLongitudeDuringTrip!;
      updateDurationInRealtimeDuringTrip();

      // Updating driver location in realtime on Firebase:
      driverLatitudeAndLongitudeDuringTripDataMap = {
        'latitude': driverCurrentPositionDuringTrip!.latitude.toString(),
        'longitude': driverCurrentPositionDuringTrip!.longitude.toString(),
      };
      FirebaseDatabase.instance.ref().child('rideRequests').child(widget.passengerRideRequestInfo!.rideRequestId!)
      .child('driverLocation').set(driverLatitudeAndLongitudeDuringTripDataMap);
    });
  }

  /// Gives the duration time of the trip in realtime. It considers both the driver-to-passenger (when driver is going to pick up the passenger)
  /// and origin-to-destination (when the driver is taking the passenger to the drop off location).
  updateDurationInRealtimeDuringTrip() async {
    // This condition and this boolean serve as a way to restrict the calling of the 'updateDurationInRealtimeDuringTrip' method.
    // Since this method is being called inside the stream data of 'updateDriversLocationInRealtimeDuringTrip', it can easily
    // consume a lot of memory by updating the trip duration constantly and in times were it's not necessary:
    if(!showDirectionRouteDetails) {
      showDirectionRouteDetails = true;

      if(driverCurrentPositionDuringTrip == null) return;

      // Driver current location:
      originLatitudeAndLongitudeDuringTrip = LatLng(driverCurrentPositionDuringTrip!.latitude, driverCurrentPositionDuringTrip!.longitude);

      if(rideRequestStatus == 'accepted') {
        // Passenger's pick up location:
        destinationLatitudeAndLongitudeDuringTrip = widget.passengerRideRequestInfo!.originLatitudeAndLongitude;
      } else {
        // Passenger's drop off location:
        destinationLatitudeAndLongitudeDuringTrip = widget.passengerRideRequestInfo!.destinationLatitudeAndLongitude;
      }

      directionDetailsDuringTrip = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          originLatitudeAndLongitudeDuringTrip!, destinationLatitudeAndLongitudeDuringTrip!
      );

      if(directionDetailsDuringTrip != null) {
        setState(() {
          tripDurationFromOriginToDestination = directionDetailsDuringTrip!.durationText!;
        });
      }

      showDirectionRouteDetails = false; // Setting boolean as "false" again so we can have the duration being updated in realtime.
    }
  }

  Widget displayDriverPickUpOrDropOffUi() {
    if(rideRequestStatus == 'accepted') {

      // Origin UI:
      return Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_circle_outlined,
                size: AppSpaceValues.space6,
                color: AppColors.success5,
              ),

              const SizedBox(width: AppSpaceValues.space2),

              SizedBox(
                width: 310,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.passengerRideRequestInfo!.originAddress!,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                        color: AppColors.gray9,
                        fontSize: AppFontSizes.ml,
                        fontWeight: AppFontWeights.light,
                        height: AppLineHeights.ml,
                      ),
                    ),

                    const SizedBox(height: AppSpaceValues.space1),

                    Row(
                      children: [
                        const Icon(
                          Icons.timelapse,
                          size: AppSpaceValues.space3,
                          color: AppColors.gray9,
                        ),

                        const SizedBox(width: AppSpaceValues.space1),

                        Text(
                          tripDurationFromOriginToDestination,
                          style: const TextStyle(
                            color: AppColors.gray9,
                            fontSize: AppFontSizes.m,
                            fontWeight: AppFontWeights.regular,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      // Handling the pick up location name:
                      '${AppStrings.passengerLocation} ${widget.passengerRideRequestInfo!.passengerName}',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.gray9,
                        fontSize: AppFontSizes.m,
                        fontWeight: AppFontWeights.regular,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpaceValues.space2),
          const Divider(height: 1, thickness: 1, color: AppColors.gray5),
          const SizedBox(height: AppSpaceValues.space4),
        ],
      );

    } else {

      // Destination UI:
      return Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: AppSpaceValues.space6,
                color: AppColors.error,
              ),

              const SizedBox(width: AppSpaceValues.space2),

              SizedBox(
                width: 310,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.passengerRideRequestInfo!.destinationAddress!,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                        color: AppColors.gray9,
                        fontSize: AppFontSizes.ml,
                        fontWeight: AppFontWeights.light,
                        height: AppLineHeights.ml
                      ),
                    ),

                    const SizedBox(height: AppSpaceValues.space1),

                    Row(
                      children: [
                        const Icon(
                          Icons.timelapse,
                          size: AppSpaceValues.space3,
                          color: AppColors.gray9,
                        ),

                        const SizedBox(width: AppSpaceValues.space1),

                        Text(
                          widget.passengerRideRequestInfo!.originToDestinationDuration!,
                          style: const TextStyle(
                            color: AppColors.gray9,
                            fontSize: AppFontSizes.m,
                            fontWeight: AppFontWeights.regular,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      // Handling the pick up location name:
                      '${AppStrings.destinationOf} ${widget.passengerRideRequestInfo!.passengerName}',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.gray9,
                        fontSize: AppFontSizes.m,
                        fontWeight: AppFontWeights.regular,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpaceValues.space2),
          const Divider(height: 1, thickness: 1, color: AppColors.gray5),
          const SizedBox(height: AppSpaceValues.space4),
        ],
      );

    }
  }

  endTrip() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(message: AppStrings.loading3),
    );
    // Getting the latitude and longitude when trip ends:
    driverLatitudeAndLongitudeWhenTripEnded = LatLng(
      driverCurrentPositionDuringTrip!.latitude, driverCurrentPositionDuringTrip!.longitude
    );
    // Getting the trip direction details:
    tripDirectionDetails = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverLatitudeAndLongitudeWhenTripEnded!, widget.passengerRideRequestInfo!.originLatitudeAndLongitude!
    );
    // Getting the fare amount to tax the passenger:
    tripPrice = AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails!);

    FirebaseDatabase.instance.ref().child('rideRequests')
    .child(widget.passengerRideRequestInfo!.rideRequestId!).child('tripPrice').set(tripPrice.toString());

    FirebaseDatabase.instance.ref().child('rideRequests')
    .child(widget.passengerRideRequestInfo!.rideRequestId!).child('status').set('finished');

    streamSubscriptionPositionTripScreen!.cancel();
    setNavigatorPop();

    // Display fare amount in a dialog box:
    showDialog(
      context: context,
      builder: (BuildContext c) => FareAmountCollectionDialog(
        tripPrice: tripPrice,
      ), // NB: Ignore Flutter's suggestion.
    ); //

    // Save the earned fare amount to the driver's total earnings:
    saveFareAmountToDriverEarnings(tripPrice);
  }

  saveFareAmountToDriverEarnings(double fareAmountEarned) {
    FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid)
    .child('earnings').once().then((snap) {
      // If earnings sub-child already exists...
      if(snap.snapshot.value != null) {
        // Getting the previous amount before the trip:
        driverEarningsBeforeTrip = double.parse(snap.snapshot.value.toString());
        // Adding up the previous amount with the fare amount earned in this trip:
        driverEarningsAfterTrip = fareAmountEarned + driverEarningsBeforeTrip!;
        // Saving this to the database:
        FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid)
        .child('earnings').set(driverEarningsAfterTrip.toString());

      } else { // If it doesn't exist, create a new sub-child...
        FirebaseDatabase.instance.ref().child('drivers').child(currentFirebaseUser!.uid)
        .child('earnings').set(fareAmountEarned.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    createDriverMarker();

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
                updateDriversLocationInRealtimeDuringTrip();
              },
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

                    displayDriverPickUpOrDropOffUi(),

                    CustomButton(
                      text: btnTitle!,
                      backgroundColor: btnColor,
                      btnContentSize: AppFontSizes.m,
                      icon: btnIcon,
                      onPressed: () async {
                        // When driver has arrived the passenger's location:
                        if(rideRequestStatus == 'accepted') {
                          rideRequestStatus = 'arrived';

                          FirebaseDatabase.instance.ref().child('rideRequests')
                          .child(widget.passengerRideRequestInfo!.rideRequestId!).child('status').set(rideRequestStatus);

                          setState(() {
                            btnTitle = AppStrings.startTrip;
                            btnColor = AppColors.success5;
                            btnIcon = Icons.directions_car;
                          });
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext c) => ProgressDialog(message: AppStrings.loading3),
                          );
                          await drawPolylineFromOriginToDestination(
                            widget.passengerRideRequestInfo!.originLatitudeAndLongitude!,
                            widget.passengerRideRequestInfo!.destinationLatitudeAndLongitude!,
                          );
                          setNavigatorPop();
                        }
                        // When driver already has the passenger in his car:
                        else if(rideRequestStatus == 'arrived') {
                          rideRequestStatus = 'onTrip';

                          FirebaseDatabase.instance.ref().child('rideRequests')
                          .child(widget.passengerRideRequestInfo!.rideRequestId!).child('status').set(rideRequestStatus);

                          setState(() {
                            btnTitle = AppStrings.endTrip;
                            btnColor = AppColors.indigo7;
                            btnIcon = Icons.location_on;
                          });
                        }
                        // When driver already took the passenger to his destination:
                        else if(rideRequestStatus == 'onTrip') {
                          endTrip();
                        }
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
}
