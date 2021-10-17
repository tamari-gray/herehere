import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  String id = "";
  String username = "";
  bool isAdmin = false;
  bool isHider = false;
  bool isTagger = false;
  bool hasBeenTagged = false;
  bool hasImmunity = false;

  Player(
    this.id,
    this.username,
    this.isAdmin,
    this.isHider,
    this.isTagger,
    this.hasBeenTagged,
    this.hasImmunity,
  );

  Player.fromDefault() {
    id = "";
    username = "";
    isAdmin = false;
    isHider = false;
    isTagger = false;
    hasBeenTagged = false;
    hasImmunity = false;
  }

  Player.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    id = doc.id;
    username = doc["username"] ?? "";
    isAdmin = doc["is_admin"] ?? false;
    isHider = doc["is_hider"] ?? false;
    isTagger = doc["is_tagger"] ?? false;
    hasBeenTagged = doc["has_been_tagged"] ?? false;
    hasImmunity = doc["has_immunity"] ?? false;
  }

  Player.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    username = doc["username"] ?? "";
    isAdmin = doc["is_admin"] ?? false;
    isHider = doc["is_hider"] ?? false;
    isTagger = doc["is_tagger"] ?? false;
    hasBeenTagged = doc["has_been_tagged"] ?? false;
    hasImmunity = doc["has_immunity"] ?? false;
  }
}