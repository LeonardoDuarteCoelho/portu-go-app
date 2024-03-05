import 'package:google_maps_flutter/google_maps_flutter.dart';

class PassengerRideRequestInfo {
  LatLng? originLatitudeAndLongitude;
  String? originAddress;
  LatLng? destinationLatitudeAndLongitude;
  String? destinationAddress;
  String? passengerId;
  String? passengerName;
  String? passengerPhone;

  PassengerRideRequestInfo({
    this.originLatitudeAndLongitude,
    this.originAddress,
    this.destinationLatitudeAndLongitude,
    this.destinationAddress,
    this.passengerId,
    this.passengerName,
    this.passengerPhone
  });
}