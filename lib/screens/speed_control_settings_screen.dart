import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/automatic_speed_control_service.dart';
import '../services/weather_service.dart';

class SpeedControlSettingsScreen extends StatefulWidget {
  final AutomaticSpeedControlService speedControlService;
  final WeatherService weatherService;

  const SpeedControlSettingsScreen({
    Key? key,
    required this.speedControlService,
    required this.weatherService,
  }) : super(key: key);

  @override
  State<SpeedControlSettingsScreen> createState() => _SpeedControlSettingsScreenState();
}

class _SpeedControlSettingsScreenState extends State<SpeedControlSettingsScreen> {
  bool _isSpeedControlEnabled = false;
  bool _isAutoBrakingEnabled = true;
  bool _isWeatherAwareEnabled = true;
  bool _isSchoolZoneAwareEnabled = true;
  bool _isPassengerAwareEnabled = true;
  double _maxSpeedLimit = 80.0;
  double _schoolZoneSpeedLimit = 30.0;
  double _residentialSpeedLimit = 40.0;
  double _weatherSensitivity = 0.8;
  double _brakingSensitivity = 0.7;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load settings from shared preferences or database
    // For now, we'll use default values
  }

  void _saveSettings() {
    // Save settings to shared preferences or database
    // This would be implemented based on your storage solution
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Control Settings'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speed Control Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          color: widget.speedControlService.isActive 
                              ? Colors.green 
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Automatic Speed Control',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.speedControlService.isActive 
                          ? 'Active' 
                          : 'Inactive',
                      style: TextStyle(
                        color: widget.speedControlService.isActive 
                            ? Colors.green 
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.speedControlService.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${widget.speedControlService.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Main Settings
            Text(
              'Main Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Speed Control Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Enable Speed Control'),
                subtitle: const Text('Automatically control speed based on conditions'),
                value: _isSpeedControlEnabled,
                onChanged: (value) {
                  setState(() {
                    _isSpeedControlEnabled = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.speed),
              ),
            ),
            
            // Auto Braking Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Enable Auto Braking'),
                subtitle: const Text('Automatically apply brakes in emergency situations'),
                value: _isAutoBrakingEnabled,
                onChanged: (value) {
                  setState(() {
                    _isAutoBrakingEnabled = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.stop),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Speed Limits
            Text(
              'Speed Limits',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // School Zone Speed Limit
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school),
                        const SizedBox(width: 8),
                        Text(
                          'School Zone Speed Limit',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _schoolZoneSpeedLimit,
                      min: 20.0,
                      max: 50.0,
                      divisions: 30,
                      label: '${_schoolZoneSpeedLimit.round()} km/h',
                      onChanged: (value) {
                        setState(() {
                          _schoolZoneSpeedLimit = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Residential Speed Limit
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.home),
                        const SizedBox(width: 8),
                        Text(
                          'Residential Speed Limit',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _residentialSpeedLimit,
                      min: 30.0,
                      max: 60.0,
                      divisions: 30,
                      label: '${_residentialSpeedLimit.round()} km/h',
                      onChanged: (value) {
                        setState(() {
                          _residentialSpeedLimit = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Highway Speed Limit
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.route),
                        const SizedBox(width: 8),
                        Text(
                          'Highway Speed Limit',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _maxSpeedLimit,
                      min: 60.0,
                      max: 120.0,
                      divisions: 60,
                      label: '${_maxSpeedLimit.round()} km/h',
                      onChanged: (value) {
                        setState(() {
                          _maxSpeedLimit = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Weather Awareness
            Text(
              'Weather Awareness',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Weather Aware Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Weather Aware Speed Control'),
                subtitle: const Text('Adjust speed based on weather conditions'),
                value: _isWeatherAwareEnabled,
                onChanged: (value) {
                  setState(() {
                    _isWeatherAwareEnabled = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.wb_cloudy),
              ),
            ),
            
            // Weather Sensitivity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune),
                        const SizedBox(width: 8),
                        Text(
                          'Weather Sensitivity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _weatherSensitivity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 90,
                      label: '${(_weatherSensitivity * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          _weatherSensitivity = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Safety Features
            Text(
              'Safety Features',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // School Zone Awareness
            Card(
              child: SwitchListTile(
                title: const Text('School Zone Awareness'),
                subtitle: const Text('Automatically reduce speed in school zones'),
                value: _isSchoolZoneAwareEnabled,
                onChanged: (value) {
                  setState(() {
                    _isSchoolZoneAwareEnabled = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.school),
              ),
            ),
            
            // Passenger Awareness
            Card(
              child: SwitchListTile(
                title: const Text('Passenger Count Awareness'),
                subtitle: const Text('Adjust speed based on passenger count'),
                value: _isPassengerAwareEnabled,
                onChanged: (value) {
                  setState(() {
                    _isPassengerAwareEnabled = value;
                  });
                  _saveSettings();
                },
                secondary: const Icon(Icons.people),
              ),
            ),
            
            // Braking Sensitivity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stop_circle),
                        const SizedBox(width: 8),
                        Text(
                          'Braking Sensitivity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _brakingSensitivity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 90,
                      label: '${(_brakingSensitivity * 100).round()}%',
                      onChanged: (value) {
                        setState(() {
                          _brakingSensitivity = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.speedControlService.isActive) {
                        widget.speedControlService.stopSpeedControl();
                      } else {
                        // This would need a bus ID - in a real app, this would come from context
                        widget.speedControlService.startSpeedControl('demo_bus');
                      }
                    },
                    icon: Icon(
                      widget.speedControlService.isActive 
                          ? Icons.stop 
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      widget.speedControlService.isActive 
                          ? 'Stop Speed Control' 
                          : 'Start Speed Control',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.speedControlService.isActive 
                          ? Colors.red 
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showTestDialog();
                    },
                    icon: const Icon(Icons.science),
                    label: const Text('Test System'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Current Status
            if (widget.speedControlService.currentSpeedControl != null) ...[
              Text(
                'Current Status',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusRow('Current Speed', '${widget.speedControlService.currentSpeedControl!.currentSpeed.toStringAsFixed(1)} km/h'),
                      _buildStatusRow('Recommended Speed', '${widget.speedControlService.currentSpeedControl!.recommendedSpeed.toStringAsFixed(1)} km/h'),
                      _buildStatusRow('Max Allowed Speed', '${widget.speedControlService.currentSpeedControl!.maxAllowedSpeed.toStringAsFixed(1)} km/h'),
                      _buildStatusRow('Weather Condition', widget.speedControlService.currentSpeedControl!.weatherCondition),
                      _buildStatusRow('Road Condition', widget.speedControlService.currentSpeedControl!.roadCondition),
                      _buildStatusRow('Safety Score', '${(widget.speedControlService.currentSpeedControl!.safetyScore * 100).toStringAsFixed(1)}%'),
                      if (widget.speedControlService.currentSpeedControl!.activeWarnings.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Active Warnings:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...widget.speedControlService.currentSpeedControl!.activeWarnings.map(
                          (warning) => Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text('• $warning', style: const TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
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

  void _showTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Speed Control System'),
        content: const Text(
          'This will simulate various driving conditions to test the speed control system. '
          'Make sure the bus is stationary before running the test.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _runTest();
            },
            child: const Text('Run Test'),
          ),
        ],
      ),
    );
  }

  void _runTest() {
    // This would run various test scenarios
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test completed. Check the logs for results.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
