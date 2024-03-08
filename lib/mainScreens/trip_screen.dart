import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portu_go_driver/components/button.dart';
import 'package:portu_go_driver/models/passenger_ride_request_info.dart';

import '../assistants/assistant_google_map_theme.dart';
import '../assistants/assistant_methods.dart';
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
  double tripInfoContainerHeight = 260; // Trip info panel's height.
  double mapControlsContainerHeight = 300; // Map controls' height.
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
  dynamic responseFromSearchScreen;
  DirectionRouteDetails? directionRouteDetails;
  List<LatLng> polylineCoordinatesList = [];
  Set<Polyline> polylineSet = {};
  LatLngBounds? latLngBounds;
  Set<Marker> markersSet = {};
  DatabaseReference? driversStatusRef;
  Position? findDriverPositionWhenOnline;
  String? buttonTitle = 'Passageiro buscado';

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
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: tripInfoContainerHeight),
            child: GoogleMap(
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
                          color: AppColors.indigo7,
                        ),

                        const SizedBox(width: AppSpaceValues.space2),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 325,
                              child: Text(
                                'Passageiro ${widget.passengerRideRequestInfo!.passengerName}',
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
                      text: 'Passageiro recolhido',
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
}
