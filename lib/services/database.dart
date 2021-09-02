import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> joinGame(String username) async {
    try {
      await _firestore.collection("game").add({
        'dateCreated': Timestamp.now(),
        'username': username,
        'isAdmin': username == 'kawaiifreak97' ? true : false,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
