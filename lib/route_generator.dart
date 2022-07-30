// import 'package:flutter/material.dart';
// import 'package:cysm/main.dart';

// class RouteGenerator {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     final args = settings.arguments;
//     switch (settings.name) {
//       case '/':
//         return MaterialPageRoute(builder: (_) => SplashPage());
//       case '/lobby':
//         if (settings.arguments is bool) {
//           return MaterialPageRoute(builder: (_) => Lobby(args as bool));
//         }
//         return _errorRoute();
//       case '/admin':
//         return MaterialPageRoute(builder: (_) => AdminSignIn());
//       default:
//         // return _errorRoute();
//     }
//   }

//   static Route<dynamic> _errorRoute() {
//     return MaterialPageRoute(builder: (_) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('error route, idk'),
//         ),
//       );
//     });
//   }
// }
