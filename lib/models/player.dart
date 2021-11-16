import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  String id = "";
  String username = "";
  bool isAdmin = false;
  bool isTagger = false;
  bool hasBeenTagged = false;

  Player(
    this.id,
    this.username,
    this.isAdmin,
    this.isTagger,
    this.hasBeenTagged,
  );

  Player.fromDefault() {
    id = "";
    username = "";
    isAdmin = false;
    isTagger = false;
    hasBeenTagged = false;
  }

  Player.fromQueryDocumentSnapshot(QueryDocumentSnapshot doc) {
    id = doc.id;
    username = doc["username"] ?? "";
    isAdmin = doc["is_admin"] ?? false;
    isTagger = doc["is_tagger"] ?? false;
    hasBeenTagged = doc["has_been_tagged"] ?? false;
  }

  Player.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    username = doc["username"] ?? "";
    isAdmin = doc["is_admin"] ?? false;
    isTagger = doc["is_tagger"] ?? false;
    hasBeenTagged = doc["has_been_tagged"] ?? false;
  }
}
