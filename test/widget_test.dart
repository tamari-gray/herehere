import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:niira2/controllers/game_controller.dart';
import 'package:niira2/controllers/location_controller.dart';
import 'package:niira2/controllers/user_controller.dart';
import 'package:niira2/models/game.dart';
import 'package:niira2/models/player.dart';
import 'package:niira2/models/safety_item.dart';

import 'package:niira2/screens/game_screens/playing_game_screen.dart';
import 'package:niira2/services/database.dart';

import 'mocks.dart';

class TestableWidget extends StatelessWidget {
  TestableWidget({
    Key? key,
    required Widget widget,
  })  : _widget = widget,
        super(key: key);

  final Widget _widget;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: _widget,
    );
  }
}

void main() {
  final Database _database = Get.put(MockDatabase());
  final UserController _userController = Get.put(MockUserController());
  final LocationController _locationController =
      Get.put(MockLocationController());
  final GameController _gameController = Get.put(MockGameController());

  testWidgets('Show location is not safe to hider',
      (WidgetTester tester) async {
    await tester.pumpWidget(TestableWidget(widget: PlayingGameScreen()));
    await tester.pump();

    expect(find.text('Location not safe'), findsOneWidget);

    _userController.locationHiddenTimer.value = 90;
    await tester.pump();

    expect(find.text('Location safe for 90s'), findsOneWidget);
  });
}
