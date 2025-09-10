import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/sensor_test_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/speed_control_monitor_screen.dart';
import 'screens/speed_control_settings_screen.dart';
import 'services/automatic_speed_control_service.dart';
import 'services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TrackingScreen(),
    const SensorTestScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSpeedControlOptions(context);
        },
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.speed, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF667eea),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Sensors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showSpeedControlOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Speed Control System',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.monitor),
                title: const Text('Speed Control Monitor'),
                subtitle: const Text('Real-time speed control monitoring'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Consumer2<AutomaticSpeedControlService, WeatherService>(
                        builder: (context, speedControlService, weatherService, child) {
                          return SpeedControlMonitorScreen(
                            speedControlService: speedControlService as AutomaticSpeedControlService,
                            weatherService: weatherService as WeatherService,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Speed Control Settings'),
                subtitle: const Text('Configure speed control parameters'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Consumer2<AutomaticSpeedControlService, WeatherService>(
                        builder: (context, speedControlService, weatherService, child) {
                          return SpeedControlSettingsScreen(
                            speedControlService: speedControlService as AutomaticSpeedControlService,
                            weatherService: weatherService as WeatherService,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sensors),
                title: const Text('Sensor Test'),
                subtitle: const Text('Test real device sensors'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SensorTestScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}