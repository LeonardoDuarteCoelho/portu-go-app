import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:portu_go_driver/global/global.dart';
import 'package:portu_go_driver/global/map_api_key.dart';
import 'package:portu_go_driver/infoHandler/app_info.dart';
import 'package:portu_go_driver/models/direction_route_details.dart';
import 'package:portu_go_driver/models/directions.dart';
import 'package:portu_go_driver/assistants/assistant_request.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/trips_history_model.dart';

class AssistantMethods {


  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async {
    String apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    String addressNumber = '';
    String streetName = '';
    String humanReadableAddress = '';
    var requestResponse = await AssistantRequest.receiveRequest(apiUrl);

    // If the request response doesn't return as any of the possible error messages...
    if(requestResponse != AppStrings.connectToApiError) {
      // Response that will contain the human-readable address. This syntax is used to navigate inside a JSON file.
      // (for more info check documentation: https://developers.google.com/maps/documentation/geocoding/start)
      streetName = requestResponse['results'][0]['address_components'][1]['long_name'];
      addressNumber = requestResponse['results'][0]['address_components'][0]['long_name'];
      humanReadableAddress = '$streetName $addressNumber';
      Directions driverPickUpAddress = Directions(); // Storing the driver's readable address data.
      driverPickUpAddress.locationLatitude = position.latitude;
      driverPickUpAddress.locationLongitude = position.longitude;
      driverPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpAddress(driverPickUpAddress);
    }
    return humanReadableAddress;
  }

  static Future<DirectionRouteDetails?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails = 'https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey';
    var responseDirectionsApi = await AssistantRequest.receiveRequest(urlOriginToDestinationDirectionDetails);

    if(responseDirectionsApi == AppStrings.connectToApiError) {
      return null;
    }
    DirectionRouteDetails directionRouteDetails = DirectionRouteDetails();
    // For navigating this JSON file, see documentation: https://developers.google.com/maps/documentation/directions/start
    directionRouteDetails.ePoints = responseDirectionsApi['routes'][0]['overview_polyline']['points'];
    directionRouteDetails.distanceText = responseDirectionsApi['routes'][0]['legs'][0]['distance']['text'];
    directionRouteDetails.distanceValue = responseDirectionsApi['routes'][0]['legs'][0]['distance']['value'];
    directionRouteDetails.durationText = responseDirectionsApi['routes'][0]['legs'][0]['duration']['text'];
    directionRouteDetails.durationValue = responseDirectionsApi['routes'][0]['legs'][0]['duration']['value'];

    return directionRouteDetails;
  }

  /// Pauses live location updates for the home screen.
  static pauseLiveLocationUpdates() {
    streamSubscriptionPositionHomeScreen!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  /// Starts/Resumes live location updates for the home screen.
  static startLiveLocationUpdates() {
    streamSubscriptionPositionHomeScreen!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
  }

  /// Method responsible for calculating and setting the appropriate fare considering the distance traveled
  /// during the ride and its duration. Monetary values regarding the ride costs and the variables designed
  /// to calculate the fare are all located inside this method.
  ///
  /// Note: If you wish to modify the change of price when the passenger chooses a Prime-type car, search for
  /// variable 'primeTypeCarFareAmountIncrease'.
  static double calculateFareAmountFromOriginToDestination(DirectionRouteDetails directionRouteDetails) {
    double timeTraveledFareAmountPerMinute = 0;
    double timeTraveledFareAmountPerKilometer = 0;
    double totalFareAmountInDollars = 0;
    double totalFareAmountInEuros = 0;

    double dollarsChargedPerMinute = 0.1; // The amount of dollars charged per minute.
    double dollarsChargedPerKilometer = 0.1; // The amount of dollars charged per kilometer.
    double dollarToEuroRatio = 1; // US$ 1.00  =  € 1.00
    double primeTypeCarFareAmountIncrease = 1.15; // This value will be multiplied by the standard billing fee, making Prime-type cars more expensive.
    // Billing fare formula for the ride's duration:
    timeTraveledFareAmountPerMinute = (directionRouteDetails.durationValue! / 60) * dollarsChargedPerMinute;
    // Billing fare formula for the ride's distance:
    timeTraveledFareAmountPerKilometer = (directionRouteDetails.distanceValue! / 1000) * dollarsChargedPerKilometer;
    // Total billing fare (US$ CURRENCY):
    totalFareAmountInDollars = timeTraveledFareAmountPerMinute + timeTraveledFareAmountPerKilometer;
    // Total billing fare (€ CURRENCY):
    totalFareAmountInEuros = totalFareAmountInDollars * dollarToEuroRatio;
    // If the driver's car is Prime...
    if(driverData.carType == AppStrings.primeCarType) {
      totalFareAmountInEuros = totalFareAmountInEuros * primeTypeCarFareAmountIncrease;
      return double.parse(totalFareAmountInEuros.toStringAsFixed(2));
    }
    if(driverData.carType == AppStrings.goCarType) {
      return double.parse(totalFareAmountInEuros.toStringAsFixed(2));
    }
    return double.parse(totalFareAmountInEuros.toStringAsFixed(2));
  }

  /// This method will retrieve all the trip keys for passenger:
  static void readTripIdKeys(context) {
    // Collecting each key:
    FirebaseDatabase.instance.ref().child('rideRequests').orderByChild('driverId').equalTo(fAuth.currentUser!.uid).once().then((snap) {
      if(snap.snapshot.value != null) {
        Map tripIdKeys = snap.snapshot.value as Map;
        int tripsCounter = tripIdKeys.length; // How many trips the passenger had.
        // Counting total number of trips and share it with provider:
        Provider.of<AppInfo>(context, listen: false).updateTripsCounter(tripsCounter);
        // Share trip keys with provider:
        List<String> tripKeysList = [];
        tripIdKeys.forEach((key, value) {
          tripKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateTripsKeys(tripKeysList);
        readTripsHistoryInfo(context);
      }
    });
  }

  static void readTripsHistoryInfo(context) {
    var allTripsKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in allTripsKeys) {
      FirebaseDatabase.instance.ref().child('rideRequests').child(eachKey).once().then((snap) {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);
        if((snap.snapshot.value as Map)['status'] == 'finished') {
          Provider.of<AppInfo>(context, listen: false).updateTripsHistoryInfo(eachTripHistory);
        }
      });
    }
  }

  /// Method that will read the driver earnings:
  static void readDriverEarnings(context) {
    String driverEarnings = '';

    FirebaseDatabase.instance.ref().child('drivers').child(fAuth.currentUser!.uid).child('earnings').once().then((snap) {
      if(snap.snapshot.value != null) {
        driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarnings(driverEarnings);
      }
    });
    readTripIdKeys(context);
  }

  static void readDriverRatings(context) {
    String driverRatings = '';

    FirebaseDatabase.instance.ref().child('drivers').child(fAuth.currentUser!.uid).child('ratings').once().then((snap) {
      if(snap.snapshot.value != null) {
        driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverAverageRatings(driverRatings);
      }
    });
  }
}