import 'package:flutter/cupertino.dart';
import 'package:portu_go_driver/models/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? driverPickUpLocation, driverDropOffLocation;

  void updatePickUpAddress(Directions driverPickUpAddress) {
    driverPickUpLocation = driverPickUpAddress;
    notifyListeners();
  }

  void updateDropOffAddress(Directions driverDropOffAddress) {
    driverDropOffLocation = driverDropOffAddress;
    notifyListeners();
  }
}