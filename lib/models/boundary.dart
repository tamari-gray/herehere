import 'package:geolocator/geolocator.dart';

class Boundary {
  final String name = 'to be decided';
  final Position center =
      Position.fromMap({'latitude': -39.622476, 'longitude': 176.830278});
  final double radiusSize = 50; // radius in metres
}
