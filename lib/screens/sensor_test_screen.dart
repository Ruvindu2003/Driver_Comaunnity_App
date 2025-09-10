import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sensor_service.dart';

class SensorTestScreen extends StatefulWidget {
  const SensorTestScreen({Key? key}) : super(key: key);

  @override
  State<SensorTestScreen> createState() => _SensorTestScreenState();
}

class _SensorTestScreenState extends State<SensorTestScreen> {
  @override
  void initState() {
    super.initState();
    // Start sensor monitoring for testing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorService = Provider.of<SensorService>(context, listen: false);
      sensorService.startMonitoring('test_bus');
    });
  }

  @override
  void dispose() {
    // Stop sensor monitoring
    final sensorService = Provider.of<SensorService>(context, listen: false);
    sensorService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Sensor Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SensorService>(
        builder: (context, sensorService, child) {
          if (sensorService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Sensor Error:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    sensorService.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final sensorData = sensorService.currentSensorData;
          if (sensorData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing sensors...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sensor Status',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              sensorService.isMonitoring ? Icons.sensors : Icons.sensors_off,
                              color: sensorService.isMonitoring ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              sensorService.isMonitoring ? 'Monitoring Active' : 'Monitoring Inactive',
                              style: TextStyle(
                                fontSize: 16,
                                color: sensorService.isMonitoring ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Speed Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Speed Information',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Current Speed', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                Text(
                                  '${sensorService.currentSpeed.toStringAsFixed(1)} km/h',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Device Moving', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                Icon(
                                  sensorService.isMoving ? Icons.directions_car : Icons.pause_circle,
                                  color: sensorService.isMoving ? Colors.green : Colors.orange,
                                  size: 32,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Accelerometer Data
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accelerometer Data',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        _buildSensorRow('X', sensorData.accelerationX ?? 0.0),
                        _buildSensorRow('Y', sensorData.accelerationY ?? 0.0),
                        _buildSensorRow('Z', sensorData.accelerationZ ?? 0.0),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Gyroscope Data
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gyroscope Data',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        _buildSensorRow('X', sensorData.gyroscopeX ?? 0.0),
                        _buildSensorRow('Y', sensorData.gyroscopeY ?? 0.0),
                        _buildSensorRow('Z', sensorData.gyroscopeZ ?? 0.0),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Magnetometer Data
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Magnetometer Data',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        _buildSensorRow('X', sensorData.magnetometerX ?? 0.0),
                        _buildSensorRow('Y', sensorData.magnetometerY ?? 0.0),
                        _buildSensorRow('Z', sensorData.magnetometerZ ?? 0.0),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Device Orientation
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device Information',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text('Orientation: ', style: TextStyle(fontSize: 16)),
                            Text(
                              sensorService.deviceOrientation,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Last Update: ${sensorData.timestamp.toString().substring(11, 19)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Control Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (sensorService.isMonitoring) {
                            sensorService.stopMonitoring();
                          } else {
                            sensorService.startMonitoring('test_bus');
                          }
                        },
                        icon: Icon(sensorService.isMonitoring ? Icons.stop : Icons.play_arrow),
                        label: Text(sensorService.isMonitoring ? 'Stop Sensors' : 'Start Sensors'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sensorService.isMonitoring ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSensorRow(String axis, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$axis:', style: TextStyle(fontSize: 16)),
          Text(
            value.toStringAsFixed(3),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getValueColor(value),
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(double value) {
    if (value.abs() > 5) return Colors.red;
    if (value.abs() > 2) return Colors.orange;
    return Colors.green;
  }
}
