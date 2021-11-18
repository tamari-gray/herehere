import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:mocktail/mocktail.dart';
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

  testWidgets('set live location in firestore if hider and game.playing',
      (WidgetTester tester) async {
    await tester.pumpWidget(TestableWidget(widget: PlayingGameScreen()));
    _gameController.game.value.phase = gamePhase.playing;
    await tester.pump();
    await tester.pump();

    verify(() => _locationController.updateLocationInDb(any()))
        .called(greaterThan(1));

    _userController.locationHiddenTimer.value = 90;
    await tester.pump();

    expect(find.text('Location safe for 90s'), findsOneWidget);
  });
  testWidgets('Tag player shows tagging player text, then tagged player dialog',
      (WidgetTester tester) async {
    _userController.user.value.isTagger = true;
    _gameController.game.value.phase = gamePhase.playing;
    when(() => _database.tagHider(any())).thenAnswer((_) async => 'id');

    await tester.pumpWidget(TestableWidget(widget: PlayingGameScreen()));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Tag player'));
    await tester.pump();
    await tester.pump();

    expect(find.text('test_hider FOUND'), findsOneWidget);
  });
}
