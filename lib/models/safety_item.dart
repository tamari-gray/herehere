import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class SafetyItem {
  String id = '';
  // Position position = Position.fromMap({0, 1});
  double latitude = 0;
  double longitude = 0;
  bool pickedUp = false;
  // double size = 5; // diameter in metres

  SafetyItem(
    this.id,
    this.latitude,
    this.longitude,
    this.pickedUp,
  );

  // SafetyItem.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
  //   final data = doc.data();
  //   id = doc.id;
  //   position = Position.fromMap({
  //     data!["point"]["geopoint"].latitude as double,
  //     data["point"]["geopoint"].longitude as double
  //   });
  //   pickedUp = doc["item_picked_up"];
  // }
}
