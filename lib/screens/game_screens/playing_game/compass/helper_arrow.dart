import 'dart:math';
import 'package:flutter/material.dart';

class HelperArrow extends StatelessWidget {
  const HelperArrow({
    Key? key,
    required this.angle,
    required this.distance,
  }) : super(key: key);

  final double? angle;
  final int? distance;

  @override
  Widget build(BuildContext context) {
    final angleInRadians = (angle! * pi) / 180;
    return Positioned(
      bottom: 310,
      child: Transform.rotate(
        angle: -angleInRadians,
        origin: Offset(0, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Distance(distance: distance),
            Arrow(),
          ],
        ),
      ),
    );
  }
}

class Distance extends StatelessWidget {
  const Distance({
    Key? key,
    required this.distance,
  }) : super(key: key);

  final int? distance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${distance!} m',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class Arrow extends StatelessWidget {
  const Arrow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
      child: Image.asset(
        'assets/arrow_niira_sm.png',
        width: 50,
        height: 70,
      ),
    );
  }
}
