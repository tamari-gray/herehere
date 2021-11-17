import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Player {
  String id = "";
  String username = "";
  bool isAdmin = false;
  bool isTagger = false;
  bool hasBeenTagged = false;
  bool locationHidden = false;
  Position location = Position.fromMap({'latitude': 1.0, 'longitude': 0.0});
  Player(
    this.id,
    this.username,
    this.isAdmin,
    this.isTagger,
    this.hasBeenTagged,
    this.locationHidden,
    this.location,
  );

  Player.fromDefault() {
    id = "";
    username = "";
    isAdmin = false;
    isTagger = false;
    hasBeenTagged = false;
    locationHidden = false;
    location = Position.fromMap({'latitude': 1.0, 'longitude': 0.0});
  }

  Player.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    id = doc.id;
    username = doc["username"] ?? "";
    isAdmin = doc["is_admin"] ?? false;
    isTagger = doc["is_tagger"] ?? false;
    hasBeenTagged = doc["has_been_tagged"] ?? false;
    locationHidden = doc["location_hidden"] ?? false;
    location = Position.fromMap({
      'latitude': doc["location"].latitude,
      'longitude': doc["location"].longitude,
    });
  }

  Player.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    username = doc["username"] ?? "";
    isAdmin = doc["is_admin"] ?? false;
    isTagger = doc["is_tagger"] ?? false;
    hasBeenTagged = doc["has_been_tagged"] ?? false;
    locationHidden = doc["location_hidden"] ?? false;
    location = Position.fromMap({
      'latitude': doc["location"].latitude,
      'longitude': doc["location"].longitude,
    });
  }
}
