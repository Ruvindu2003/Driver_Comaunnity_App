import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';
import '../services/theme_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize services
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationService = context.read<LocationService>();
      final sensorService = context.read<SensorService>();
      
      // Request permissions and start services
      await locationService.requestPermission();
      if (await locationService.hasPermission) {
        locationService.startTracking('default');
      }
      sensorService.startMonitoring('default');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor & Location Dashboard'),
        centerTitle: true,
        actions: [
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return IconButton(
                icon: Icon(
                  themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeService.toggleTheme();
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Status
            _buildSystemStatus(),
            const SizedBox(height: 16),
            
            // Real-time Data Cards
            _buildRealTimeData(),
            const SizedBox(height: 16),
            
            // Location Information
            _buildLocationInfo(),
            const SizedBox(height: 16),
            
            // Sensor Information
            _buildSensorInfo(),
            const SizedBox(height: 16),
            
            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'System Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer2<LocationService, SensorService>(
              builder: (context, locationService, sensorService, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatusItem(
                        'Location',
                        locationService.isTracking ? 'Active' : 'Inactive',
                        locationService.isTracking ? Colors.green : Colors.red,
                        Icons.location_on,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatusItem(
                        'Sensors',
                        sensorService.isMonitoring ? 'Active' : 'Inactive',
                        sensorService.isMonitoring ? Colors.green : Colors.red,
                        Icons.sensors,
                      ),
                    ),
                  ],
                );
              },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatusItem(String title, String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            status,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeData() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                Icon(Icons.speed, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                  Text(
                  'Real-time Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            Consumer2<LocationService, SensorService>(
              builder: (context, locationService, sensorService, child) {
                final location = locationService.currentLocation;
                final sensorData = sensorService.currentSensorData;
                
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDataCard(
                            'Current Speed',
                            '${sensorService.currentSpeed.toStringAsFixed(1)} km/h',
                            Icons.speed,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDataCard(
                            'Device Moving',
                            sensorService.isMoving ? 'Yes' : 'No',
                            Icons.directions_car,
                            sensorService.isMoving ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
                    const SizedBox(height: 16),
                    Row(
      children: [
                        Expanded(
                          child: _buildDataCard(
                            'Latitude',
                            location?.latitude.toStringAsFixed(6) ?? 'N/A',
                            Icons.my_location,
                            Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDataCard(
                            'Longitude',
                            location?.longitude.toStringAsFixed(6) ?? 'N/A',
                            Icons.my_location,
                            Colors.purple,
                          ),
            ),
          ],
        ),
      ],
    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
              ),
            ],
          ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Location Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
            ),
            const SizedBox(height: 16),
            Consumer<LocationService>(
              builder: (context, locationService, child) {
                final location = locationService.currentLocation;
                if (location == null) {
                  return const Center(
                    child: Text('No location data available'),
                  );
                }
                
                return Column(
                  children: [
                    _buildInfoRow('Latitude', location.latitude.toStringAsFixed(6)),
                    _buildInfoRow('Longitude', location.longitude.toStringAsFixed(6)),
                    _buildInfoRow('Speed', '${location.speed.toStringAsFixed(1)} km/h'),
                    _buildInfoRow('Accuracy', '${location.accuracy.toStringAsFixed(1)} m'),
                    _buildInfoRow('Last Update', _formatTime(location.timestamp)),
                  ],
                );
              },
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildSensorInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Row(
              children: [
                Icon(Icons.sensors, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Sensor Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
                  ),
              ),
            ],
          ),
            const SizedBox(height: 16),
            Consumer<SensorService>(
              builder: (context, sensorService, child) {
                final sensorData = sensorService.currentSensorData;
                if (sensorData == null) {
                  return const Center(
                    child: Text('No sensor data available'),
                  );
                }
                
                return Column(
            children: [
                    _buildInfoRow('Acceleration X', '${(sensorData.accelerationX ?? 0).toStringAsFixed(3)} m/s²'),
                    _buildInfoRow('Acceleration Y', '${(sensorData.accelerationY ?? 0).toStringAsFixed(3)} m/s²'),
                    _buildInfoRow('Acceleration Z', '${(sensorData.accelerationZ ?? 0).toStringAsFixed(3)} m/s²'),
                    _buildInfoRow('Gyroscope X', '${(sensorData.gyroscopeX ?? 0).toStringAsFixed(3)} rad/s'),
                    _buildInfoRow('Gyroscope Y', '${(sensorData.gyroscopeY ?? 0).toStringAsFixed(3)} rad/s'),
                    _buildInfoRow('Gyroscope Z', '${(sensorData.gyroscopeZ ?? 0).toStringAsFixed(3)} rad/s'),
                    _buildInfoRow('Device Orientation', sensorService.deviceOrientation),
                    _buildInfoRow('Last Update', _formatTime(sensorData.timestamp)),
                  ],
                );
              },
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
                  Text(
            value,
                    style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                Icon(Icons.flash_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to sensor test screen
                      Navigator.pushNamed(context, '/sensor-test');
                    },
                    icon: const Icon(Icons.sensors),
                    label: const Text('Test Sensors'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
          Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to tracking screen
                      Navigator.pushNamed(context, '/tracking');
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('View Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
                ),
              ],
            ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
