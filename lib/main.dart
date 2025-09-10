import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/family_vehicle_service.dart';
import 'services/location_service.dart';
import 'services/sensor_service.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'services/automatic_speed_control_service.dart';
import 'services/weather_service.dart';
import 'services/theme_service.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize weather service
  final weatherService = WeatherService();
  
  // Initialize theme service
  final themeService = ThemeService();
  
  runApp(MyApp(
    notificationService: notificationService,
    weatherService: weatherService,
    themeService: themeService,
  ));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  final WeatherService weatherService;
  final ThemeService themeService;
  
  const MyApp({
    super.key, 
    required this.notificationService,
    required this.weatherService,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => SensorService()),
        ChangeNotifierProvider.value(value: notificationService),
        ChangeNotifierProvider.value(value: weatherService),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider(
          create: (context) => AutomaticSpeedControlService(
            locationService: context.read<LocationService>(),
            sensorService: context.read<SensorService>(),
          ),
        ),
        Provider(create: (_) => DatabaseService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Sensor & Location Manager',
            debugShowCheckedModeBanner: false,
            theme: themeService.lightTheme,
            darkTheme: themeService.darkTheme,
            themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
          );
        },
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

