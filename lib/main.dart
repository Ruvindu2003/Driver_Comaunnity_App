import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/family_vehicle_service.dart';
import 'services/location_service.dart';
import 'services/sensor_service.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'services/automatic_speed_control_service.dart';
import 'services/weather_service.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize weather service
  final weatherService = WeatherService();
  
  runApp(MyApp(
    notificationService: notificationService,
    weatherService: weatherService,
  ));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  final WeatherService weatherService;
  
  const MyApp({
    super.key, 
    required this.notificationService,
    required this.weatherService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FamilyVehicleService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => SensorService()),
        ChangeNotifierProvider.value(value: notificationService),
        ChangeNotifierProvider.value(value: weatherService),
        ChangeNotifierProvider(
          create: (context) => AutomaticSpeedControlService(
            locationService: context.read<LocationService>(),
            sensorService: context.read<SensorService>(),
          ),
        ),
        Provider(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: 'Family Vehicle Manager',
        debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Go directly to HomePage without authentication
    return const HomePage();
  }
}

