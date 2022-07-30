// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get/instance_manager.dart';
// import 'package:get/route_manager.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:cysm/controllers/game_controller.dart';
// import 'package:cysm/controllers/location_controller.dart';
// import 'package:cysm/controllers/user_controller.dart';
// import 'package:cysm/models/game.dart';
// import 'package:cysm/models/player.dart';

// import 'package:cysm/screens/game_screens/playing_game/playing_game_screen.dart';
// import 'package:cysm/services/database.dart';

// import 'mocks.dart';

// class TestableWidget extends StatelessWidget {
//   TestableWidget({
//     Key? key,
//     required Widget widget,
//   })  : _widget = widget,
//         super(key: key);

//   final Widget _widget;

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       home: _widget,
//     );
//   }
// }

// void main() {
//   final Database _database = Get.put(MockDatabase());
//   final UserController _userController = Get.put(MockUserController());
//   final LocationController _locationController =
//       Get.put(MockLocationController());
//   final GameController _gameController = Get.put(MockGameController());

//   _gameController.game.value.phase = gamePhase.playing;

//   when(() => _gameController.hidersRemaining()).thenReturn(4);
//   when(() => _gameController.getFoundSafetyItems())
//       .thenReturn(mockFoundSafetyItems);
//   when(() => _gameController.getFoundHiders()).thenReturn(mockfoundHiders);

//   testWidgets('Show location is not safe to hider',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(TestableWidget(widget: PlayingGameScreen()));
//     await tester.pump();

//     expect(find.text('Location not safe'), findsOneWidget);

//     _userController.locationHiddenTimer.value = 90;
//     await tester.pump();

//     expect(find.text('Location safe for 90s'), findsOneWidget);
//   });

//   testWidgets('set live location in firestore if hider and game.playing',
//       (WidgetTester tester) async {
//     await tester.pumpWidget(TestableWidget(widget: PlayingGameScreen()));
//     await tester.pump();
//     await tester.pump();

//     verify(() => _locationController.updateLocationInDb(any()))
//         .called(greaterThan(1));

//     _userController.locationHiddenTimer.value = 90;
//     await tester.pump();

//     expect(find.text('Location safe for 90s'), findsOneWidget);
//   });
//   testWidgets('Tag player shows tagging player text, then tagged player dialog',
//       (WidgetTester tester) async {
//     _userController.user.value.isTagger = true;
//     when(() => _database.tagHiders(any()))
//         .thenAnswer((_) async => [Player.fromDefault()]);

//     await tester.pumpWidget(TestableWidget(widget: PlayingGameScreen()));
//     await tester.pump();
//     await tester.pump();

//     await tester.tap(find.text('Tag player'));
//     await tester.pump();
//     await tester.pump();

//     expect(find.text('Tagged test_hider,test_hider!'), findsOneWidget);
//   });

//   testWidgets('Hider finds and picks up 2 items in same loaction',
//       (WidgetTester tester) async {
//     _userController.user.value.isTagger = false;
//     _gameController.taggingPlayer.value = false;

//     await tester.pumpWidget(TestableWidget(widget: PlayingGameScreen()));
//     await tester.pump();
//     await tester.pump();

//     await tester.tap(find.text('Pick up item'));
//     await tester.pump();
//     verify(() => _gameController.pickUpItems()).called(greaterThan(1));
//   });
// }
