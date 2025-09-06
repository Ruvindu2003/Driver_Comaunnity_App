import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:driver_management/screens/tracking_screen.dart';
import 'package:driver_management/services/location_service.dart';
import 'package:driver_management/services/sensor_service.dart';
import 'package:driver_management/services/bus_service.dart';

void main() {
  group('TrackingScreen Tests', () {
    testWidgets('TrackingScreen displays correctly', (WidgetTester tester) async {
      // Create mock services
      final locationService = LocationService();
      final sensorService = SensorService();
      final busService = BusService();

      // Build the widget with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => locationService),
            ChangeNotifierProvider(create: (_) => sensorService),
            ChangeNotifierProvider(create: (_) => busService),
          ],
          child: MaterialApp(
            home: const TrackingScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the app bar is displayed
      expect(find.text('Real-Time Tracking'), findsOneWidget);

      // Verify the tab bar is displayed
      expect(find.text('Map View'), findsOneWidget);
      expect(find.text('Sensors'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);

      // Verify the floating action button is displayed
      expect(find.byIcon(Icons.bus_alert), findsOneWidget);

      // Verify the tracking toggle button is displayed
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('TrackingScreen switches tabs correctly', (WidgetTester tester) async {
      // Create mock services
      final locationService = LocationService();
      final sensorService = SensorService();
      final busService = BusService();

      // Build the widget with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => locationService),
            ChangeNotifierProvider(create: (_) => sensorService),
            ChangeNotifierProvider(create: (_) => busService),
          ],
          child: MaterialApp(
            home: const TrackingScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Tap on the Sensors tab
      await tester.tap(find.text('Sensors'));
      await tester.pumpAndSettle();

      // Verify we're on the sensors tab
      expect(find.text('No sensor data available'), findsOneWidget);

      // Tap on the Analytics tab
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      // Verify we're on the analytics tab
      expect(find.text('Performance Analytics'), findsOneWidget);
    });

    testWidgets('TrackingScreen shows bus selector dialog', (WidgetTester tester) async {
      // Create mock services
      final locationService = LocationService();
      final sensorService = SensorService();
      final busService = BusService();

      // Build the widget with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => locationService),
            ChangeNotifierProvider(create: (_) => sensorService),
            ChangeNotifierProvider(create: (_) => busService),
          ],
          child: MaterialApp(
            home: const TrackingScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Tap the floating action button
      await tester.tap(find.byIcon(Icons.bus_alert));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Select Bus'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('TrackingScreen toggles tracking state', (WidgetTester tester) async {
      // Create mock services
      final locationService = LocationService();
      final sensorService = SensorService();
      final busService = BusService();

      // Build the widget with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => locationService),
            ChangeNotifierProvider(create: (_) => sensorService),
            ChangeNotifierProvider(create: (_) => busService),
          ],
          child: MaterialApp(
            home: const TrackingScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Initially should show play button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Tap the tracking toggle button
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Should now show stop button
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });
  });
}
