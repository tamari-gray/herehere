import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class Compass extends StatefulWidget {
  const Compass({
    Key? key,
  }) : super(key: key);

  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  CompassEvent? _lastRead;
  DateTime? _lastReadAt;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Column(
        children: <Widget>[
          // _buildManualReader(),
          _buildCompass(),
        ],
      );
    });
  }

  Widget _buildManualReader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          ElevatedButton(
            child: Text('Read Value'),
            onPressed: () async {
              final CompassEvent tmp = await FlutterCompass.events!.first;
              setState(() {
                _lastRead = tmp;
                _lastReadAt = DateTime.now();
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$_lastRead',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    '$_lastReadAt',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Container(
          width: 500,
          height: 300,
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.center,
            children: [
              Positioned(
                bottom: 210,
                child: Transform.rotate(
                  angle: (direction * (pi / 180) * -1),
                  origin: Offset(0, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '50m',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
                        child: Image.asset(
                          'assets/arrow_niira_sm.png',
                          width: 50,
                          height: 70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.rotate(
                angle: (direction * (pi / 180) * -1),
                child: Image.asset(
                  'assets/niira_compass_basic.png',
                  fit: BoxFit.scaleDown,
                  width: 100,
                  height: 100,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
