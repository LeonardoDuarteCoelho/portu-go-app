import 'package:flutter/cupertino.dart';
import 'package:portu_go_driver/models/directions.dart';
import 'package:portu_go_driver/models/trips_history_model.dart';

class AppInfo extends ChangeNotifier {
  Directions? passengerPickUpLocation, passengerDropOffLocation;
  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel> tripHistoryInfoList = [];
  String driverTotalEarnings = '0';
  String driverAverageRatings = '0';

  void updatePickUpAddress(Directions passengerPickUpAddress) {
    passengerPickUpLocation = passengerPickUpAddress;
    notifyListeners();
  }

  void updateDropOffAddress(Directions passengerDropOffAddress) {
    passengerDropOffLocation = passengerDropOffAddress;
    notifyListeners();
  }

  void updateTripsKeys(List<String> tripsKeysList) {
    historyTripsKeysList = tripsKeysList;
    notifyListeners();
  }

  void updateTripsHistoryInfo(TripsHistoryModel eachTripHistory) {
    tripHistoryInfoList.add(eachTripHistory);
    notifyListeners();
  }

  void updateDriverTotalEarnings(String driverEarnings) {
    driverTotalEarnings = driverEarnings;
    notifyListeners();
  }

  void updateDriverAverageRatings(String driverRatings) {
    driverAverageRatings = driverRatings;
    notifyListeners();
  }
}