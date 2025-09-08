import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/automatic_speed_control_service.dart';
import '../services/weather_service.dart';
import '../models/speed_control_data.dart';
import 'speed_control_settings_screen.dart';

class SpeedControlMonitorScreen extends StatefulWidget {
  final AutomaticSpeedControlService speedControlService;
  final WeatherService weatherService;

  const SpeedControlMonitorScreen({
    Key? key,
    required this.speedControlService,
    required this.weatherService,
  }) : super(key: key);

  @override
  State<SpeedControlMonitorScreen> createState() => _SpeedControlMonitorScreenState();
}

class _SpeedControlMonitorScreenState extends State<SpeedControlMonitorScreen> {
  @override
  void initState() {
    super.initState();
    widget.speedControlService.addListener(_onSpeedControlChanged);
    widget.weatherService.addListener(_onWeatherChanged);
  }

  @override
  void dispose() {
    widget.speedControlService.removeListener(_onSpeedControlChanged);
    widget.weatherService.removeListener(_onWeatherChanged);
    super.dispose();
  }

  void _onSpeedControlChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onWeatherChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final speedControlData = widget.speedControlService.currentSpeedControl;
    final weatherData = widget.weatherService.currentWeather;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Control Monitor'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpeedControlSettingsScreen(
                    speedControlService: widget.speedControlService,
                    weatherService: widget.weatherService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: speedControlData == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.speed,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Speed Control Data',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start the speed control system to begin monitoring',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Overview
                  _buildStatusOverview(speedControlData),
                  
                  const SizedBox(height: 20),
                  
                  // Speed Information
                  _buildSpeedInfo(speedControlData),
                  
                  const SizedBox(height: 20),
                  
                  // Weather Information
                  if (weatherData != null) ...[
                    _buildWeatherInfo(weatherData),
                    const SizedBox(height: 20),
                  ],
                  
                  // Safety Information
                  _buildSafetyInfo(speedControlData),
                  
                  const SizedBox(height: 20),
                  
                  // Warnings and Alerts
                  _buildWarningsInfo(speedControlData),
                  
                  const SizedBox(height: 20),
                  
                  // Control Actions
                  _buildControlActions(speedControlData),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusOverview(SpeedControlData data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: data.safetyScore > 0.7 ? Colors.green : 
                         data.safetyScore > 0.4 ? Colors.orange : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Safety Score',
                    '${(data.safetyScore * 100).toStringAsFixed(1)}%',
                    data.safetyScore > 0.7 ? Colors.green : 
                    data.safetyScore > 0.4 ? Colors.orange : Colors.red,
                    Icons.security,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    'Speed Control',
                    data.isSpeedControlActive ? 'Active' : 'Inactive',
                    data.isSpeedControlActive ? Colors.green : Colors.grey,
                    Icons.speed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Auto Braking',
                    data.isAutoBrakingActive ? 'Active' : 'Inactive',
                    data.isAutoBrakingActive ? Colors.red : Colors.grey,
                    Icons.stop,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    'Passengers',
                    '${data.passengerCount}',
                    Colors.blue,
                    Icons.people,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color, IconData icon) {
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
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedInfo(SpeedControlData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed),
                const SizedBox(width: 8),
                Text(
                  'Speed Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSpeedGauge(data),
            const SizedBox(height: 16),
            _buildSpeedRow('Current Speed', '${data.currentSpeed.toStringAsFixed(1)} km/h'),
            _buildSpeedRow('Recommended Speed', '${data.recommendedSpeed.toStringAsFixed(1)} km/h'),
            _buildSpeedRow('Max Allowed Speed', '${data.maxAllowedSpeed.toStringAsFixed(1)} km/h'),
            _buildSpeedRow('Braking Force', '${(data.brakingForce * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedGauge(SpeedControlData data) {
    final speedRatio = data.currentSpeed / data.maxAllowedSpeed;
    final isOverLimit = data.currentSpeed > data.maxAllowedSpeed;
    
    return Container(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Speed gauge background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isOverLimit ? Colors.red : Colors.blue,
                width: 8,
              ),
            ),
          ),
          // Speed gauge fill
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.red,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
                startAngle: 0,
                endAngle: 2 * 3.14159,
              ),
            ),
            child: CustomPaint(
              painter: SpeedGaugePainter(speedRatio),
            ),
          ),
          // Speed text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${data.currentSpeed.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'km/h',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(weatherData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_cloudy),
                const SizedBox(width: 8),
                Text(
                  'Weather Conditions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWeatherCard(
                    'Condition',
                    weatherData.condition,
                    _getWeatherIcon(weatherData.condition),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWeatherCard(
                    'Temperature',
                    '${weatherData.temperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWeatherCard(
                    'Visibility',
                    '${weatherData.visibility.toStringAsFixed(0)}m',
                    Icons.visibility,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWeatherCard(
                    'Wind Speed',
                    '${weatherData.windSpeed.toStringAsFixed(1)} km/h',
                    Icons.air,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'clear':
        return Icons.wb_sunny;
      case 'rain':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      case 'fog':
        return Icons.cloud;
      case 'storm':
        return Icons.thunderstorm;
      default:
        return Icons.wb_cloudy;
    }
  }

  Widget _buildSafetyInfo(SpeedControlData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security),
                const SizedBox(width: 8),
                Text(
                  'Safety Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSafetyRow('Road Condition', data.roadCondition),
            _buildSafetyRow('Road Friction', '${(data.roadFriction * 100).toStringAsFixed(1)}%'),
            _buildSafetyRow('Traffic Density', '${(data.trafficDensity * 100).toStringAsFixed(1)}%'),
            _buildSafetyRow('School Zone', data.isInSchoolZone ? 'Yes' : 'No'),
            _buildSafetyRow('Residential Area', data.isInResidentialArea ? 'Yes' : 'No'),
            _buildSafetyRow('Highway', data.isInHighway ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsInfo(SpeedControlData data) {
    if (data.activeWarnings.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'No Active Warnings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Active Warnings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...data.activeWarnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlActions(SpeedControlData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.control_camera),
                const SizedBox(width: 8),
                Text(
                  'Control Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // This would trigger manual speed control
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Manual speed control activated'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.speed),
                    label: const Text('Manual Control'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // This would trigger emergency braking
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Emergency braking activated'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Emergency Brake'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
}

class SpeedGaugePainter extends CustomPainter {
  final double speedRatio;

  SpeedGaugePainter(this.speedRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw speed indicator
    final angle = speedRatio * 2 * 3.14159;
    final indicatorX = center.dx + radius * 0.8 * cos(angle - 3.14159 / 2);
    final indicatorY = center.dy + radius * 0.8 * sin(angle - 3.14159 / 2);

    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      8,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

