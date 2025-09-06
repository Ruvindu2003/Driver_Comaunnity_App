import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum TripPanalty { none, harshAcceleration, harshBraking, overspeed }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _counter = 0;

  String? _speedKmh = "0.0";
  String? _speedStatus = "Normal";

  final Location location = Location();

  LocationData? _location;
  StreamSubscription<LocationData>? _locationSubscription;
  String? _error;

  Duration sensorInterval = SensorInterval.normalInterval;

  UserAccelerometerEvent? _userAccelerometerEvent;
  DateTime? _userAccelerometerUpdateTime;
  static const Duration _ignoreDuration = Duration(milliseconds: 20);
  int? _userAccelerometerLastInterval;

  Future<void> _listenAccelerometer() async {
    userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
      (UserAccelerometerEvent event) {
        final now = event.timestamp;
        setState(() {
          _userAccelerometerEvent = event;
          if (_userAccelerometerUpdateTime != null) {
            final interval = now.difference(_userAccelerometerUpdateTime!);
            if (interval > _ignoreDuration) {
              _userAccelerometerEvent = event;

              // event.y measures forward/backward acceleration
              if (event.y < -2.0) {
                // A strong negative value indicates harsh braking
                // handleHarshBraking();
                _speedStatus = "Harsh Braking";
                _reducePenalty(TripPanalty.harshBraking);
              }
              if (event.y > 1.0) {
                // A strong positive value indicates harsh acceleration
                //handleHarshAcceleration();
                _speedStatus = "Harsh Acceleration";
                _reducePenalty(TripPanalty.harshAcceleration);
              }
            }
          }
        });
        _userAccelerometerUpdateTime = now;
      },
      onError: (e) {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Sensor Not Found"),
              content: Text(
                "It seems that your device doesn't support User Accelerometer Sensor",
              ),
            );
          },
        );
      },
      cancelOnError: true,
    );
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged
        .handleError((dynamic err) {
          if (err is PlatformException) {
            setState(() {
              _error = err.code;
            });
          }
          _locationSubscription?.cancel();
          setState(() {
            _locationSubscription = null;
          });
        })
        .listen((currentLocation) {
          setState(() {
            _error = null;

            _location = currentLocation;

            // currentLocation.speed is in meters per second (m/s)
            final speedMps = currentLocation.speed ?? 0.0;
            final speedKmh = speedMps * 3.6; // Convert to km/h

            _speedKmh = speedKmh.toStringAsFixed(2);

            // Now, check for overspeed events
            const speedLimit = 80; // Example limit in km/h
            if (speedKmh > speedLimit) {
              // Trigger overspeed event and apply a penalty
              // handleOverspeed();
              _reducePenalty(TripPanalty.overspeed);
            }
          });
        });
    setState(() {});
  }

  void _startTrip() {
    _listenLocation();
    _listenAccelerometer();
    setState(() {
      _counter = 100;
    });
  }

  void _endTrip() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
      _counter = 0;
    });
  }

  void _reducePenalty(TripPanalty penalty) {
    int reductionAmount = 0;
    switch (penalty) {
      case TripPanalty.harshAcceleration:
        reductionAmount = 2;
        // Reduce harsh acceleration penalty
        break;
      case TripPanalty.harshBraking:
        reductionAmount = 3;
        // Reduce harsh braking penalty
        break;
      case TripPanalty.overspeed:
        reductionAmount = 5;
        // Reduce overspeed penalty
        break;
      case TripPanalty.none:
        // No penalty to reduce
        break;
    }
    setState(() {
      _counter = (_counter ?? 0) - reductionAmount;
      // if (_counter! < 0) _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _listenLocation();
    // _listenAccelerometer();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${_speedKmh != null ? 'Speed: ${_speedKmh} km/h' : 'Error: $_error'}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '${_speedStatus != null ? 'Status: ${_speedStatus}' : 'Error: $_error'}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '${_userAccelerometerEvent != null ? 'Accelerometer Y: ${_userAccelerometerEvent!.y}' : 'Error: $_error'}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            FilledButton(onPressed: _startTrip, child: Text('Start Trip')),
            SizedBox(height: 16),
            Text(
              'Driver Score: ${_counter ?? 0}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            FilledButton(onPressed: _endTrip, child: Text('End Trip')),
          ],
        ),
      ),
    );
  }
}