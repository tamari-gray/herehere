import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Player {
  String id = "";
  String username = "";
  bool isAdmin = false;
  bool isTagger = false;
  bool hasBeenTagged = false;
  bool locationHidden = false;
  double locationAccuracy = 0;
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
    locationAccuracy = doc["location_accuracy"] as double;
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

class Hider extends Player {
  Hider(
    String id,
    String username,
    bool isAdmin,
    bool isTagger,
    bool hasBeenTagged,
    bool locationHidden,
    Position location,
    this.angleFromUser,
    this.distanceFromUser,
  ) : super(id, username, isAdmin, isTagger, hasBeenTagged, locationHidden,
            location);
  int distanceFromUser;
  double angleFromUser;

  // Hider.fromPlayer(int _dist, double _angle) {
  //   distanceFromUser = _dist;
  // }
}
