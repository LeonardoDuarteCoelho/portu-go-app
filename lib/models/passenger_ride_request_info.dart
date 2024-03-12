import 'package:google_maps_flutter/google_maps_flutter.dart';

class PassengerRideRequestInfo {
  String? rideRequestId;
  LatLng? originLatitudeAndLongitude;
  String? originAddress;
  LatLng? destinationLatitudeAndLongitude;
  String? destinationAddress;
  String? originToDestinationDistance;
  String? originToDestinationDuration;
  String? passengerId;
  String? passengerName;
  String? passengerPhone;

  PassengerRideRequestInfo({
    this.rideRequestId,
    this.originLatitudeAndLongitude,
    this.originAddress,
    this.destinationLatitudeAndLongitude,
    this.destinationAddress,
    this.originToDestinationDistance,
    this.originToDestinationDuration,
    this.passengerId,
    this.passengerName,
    this.passengerPhone
  });
}