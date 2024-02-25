import 'package:firebase_database/firebase_database.dart';

class DriverModel {
  String? email;
  String? id;
  String? name;
  String? phone;

  DriverModel({ this.email, this.id, this.name, this.phone });

  DriverModel.fromSnapshot(DataSnapshot snap) {
    email = (snap.value as dynamic)['email'];
    id = snap.key;
    name = (snap.value as dynamic)['name'];
    phone = (snap.value as dynamic)['phone'];
  }
}