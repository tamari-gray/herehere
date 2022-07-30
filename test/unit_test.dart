import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cysm/controllers/user_controller.dart';

import 'mocks.dart';

void main() {
  setUpAll(() {
    final _mockDatabase = MockDatabase();
    Get.put(_mockDatabase);
  });

  test('''
Test the state of the reactive variable "name" across all of its lifecycles''',
      () {
    final _userController = UserController();
    expect(_userController.userId, '');

    Get.put(_userController); // onInit was called

    // join game
    _userController.joinGame('test_user', false, GeoPoint(0, 0));
    expect(_userController.userId, 'test_user');

    //leave game
    _userController.leaveGame();
    // verify(() => _mockDatabase.leaveGame(any()));
    expect(_userController.userId, '');
  });
}
