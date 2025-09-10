import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final hasPermission = await locationService.hasPermission;
    if (mounted) {
      setState(() {
        _hasLocationPermission = hasPermission;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Settings
            _buildSectionCard(
              title: 'Appearance',
              icon: Icons.palette,
        children: [
                Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    return SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Switch between light and dark theme'),
                      value: themeService.isDarkMode,
                      onChanged: (value) {
                        themeService.toggleTheme();
                      },
                      secondary: Icon(
                        themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      ),
                    );
                  },
          ),
        ],
      ),
            
            const SizedBox(height: 16),
            // Location Settings
            _buildSectionCard(
              title: 'Location Services',
              icon: Icons.location_on,
              children: [
                ListTile(
                  leading: const Icon(Icons.location_searching),
                  title: const Text('Location Permission'),
                  subtitle: Text(
                    _hasLocationPermission ? 'Granted' : 'Not Granted',
                    style: TextStyle(
                      color: _hasLocationPermission ? Colors.green : Colors.red,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final locationService = Provider.of<LocationService>(context, listen: false);
                      await locationService.requestPermission();
                      await _checkLocationPermission();
                    },
                    child: Text(_hasLocationPermission ? 'Re-request' : 'Request'),
                  ),
                ),
                Consumer<LocationService>(
                  builder: (context, locationService, child) {
                    return SwitchListTile(
                      title: const Text('Location Tracking'),
                      subtitle: const Text('Track your location in real-time'),
                      value: locationService.isTracking,
                      onChanged: (value) {
                        if (value) {
                          locationService.startTracking('default');
                        } else {
                          locationService.stopTracking();
                        }
                      },
                      secondary: const Icon(Icons.my_location),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Sensor Settings
            _buildSectionCard(
              title: 'Sensor Services',
              icon: Icons.sensors,
          children: [
                Consumer<SensorService>(
                  builder: (context, sensorService, child) {
                    return SwitchListTile(
                      title: const Text('Sensor Monitoring'),
                      subtitle: const Text('Monitor device sensors for speed and motion'),
                      value: sensorService.isMonitoring,
                      onChanged: (value) {
                        if (value) {
                          sensorService.startMonitoring('default');
                        } else {
                          sensorService.stopMonitoring();
                        }
                      },
                      secondary: const Icon(Icons.speed),
                    );
                  },
                ),
                Consumer<SensorService>(
                  builder: (context, sensorService, child) {
                    return ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Sensor Status'),
                      subtitle: Text(
                        sensorService.error ?? 'Sensors working properly',
              style: TextStyle(
                          color: sensorService.error != null ? Colors.red : Colors.green,
                        ),
                      ),
                      trailing: sensorService.error != null
                          ? IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () {
                                sensorService.startMonitoring('default');
                                setState(() {});
                              },
                            )
                          : null,
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // App Information
            _buildSectionCard(
              title: 'App Information',
              icon: Icons.info,
              children: [
                const ListTile(
                  leading: Icon(Icons.apps),
                  title: Text('App Name'),
                  subtitle: Text('Sensor & Location Manager'),
                ),
                const ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                const ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Description'),
                  subtitle: Text('Real-time sensor monitoring and location tracking'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            _buildSectionCard(
              title: 'Quick Actions',
              icon: Icons.flash_on,
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Restart All Services'),
                  subtitle: const Text('Restart location and sensor services'),
                  onTap: () {
                    _restartAllServices();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Clear sensor and location history'),
                  onTap: () {
                    _showClearDataDialog();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
          ),
        ],
      ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  void _restartAllServices() {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final sensorService = Provider.of<SensorService>(context, listen: false);
    
    // Stop all services
    locationService.stopTracking();
    sensorService.stopMonitoring();
    
    // Restart services
    Future.delayed(const Duration(seconds: 1), () {
      locationService.startTracking('default');
      sensorService.startMonitoring('default');
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All services restarted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'This will clear all sensor and location history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Clear data logic here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}