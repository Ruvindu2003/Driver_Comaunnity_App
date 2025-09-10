import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_data.dart';

class SensorService extends ChangeNotifier {
  Timer? _sensorTimer;
  final List<SensorData> _sensorHistory = [];
  SensorData? _currentSensorData;
  bool _isMonitoring = false;
  String? _error;
  
  // Real sensor data streams
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  
  // Current sensor readings
  double _accelerationX = 0.0;
  double _accelerationY = 0.0;
  double _accelerationZ = 0.0;
  double _gyroscopeX = 0.0;
  double _gyroscopeY = 0.0;
  double _gyroscopeZ = 0.0;
  double _magnetometerX = 0.0;
  double _magnetometerY = 0.0;
  double _magnetometerZ = 0.0;
  
  // Speed calculation
  double _currentSpeed = 0.0;
  List<double> _speedHistory = [];
  DateTime? _lastSpeedUpdate;

  List<SensorData> get sensorHistory => List.unmodifiable(_sensorHistory);
  SensorData? get currentSensorData => _currentSensorData;
  bool get isMonitoring => _isMonitoring;
  String? get error => _error;
  double get currentSpeed => _currentSpeed;

  // Start sensor monitoring
  void startMonitoring(String busId) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _error = null;
    notifyListeners();

    try {
      // Start real sensor streams
      _startAccelerometerStream();
      _startGyroscopeStream();
      _startMagnetometerStream();
      
      // Generate sensor data every 2 seconds with real sensor readings
      _sensorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        _generateSensorDataWithRealSensors(busId);
      });
    } catch (e) {
      _error = 'Failed to start sensors: $e';
      _isMonitoring = false;
      notifyListeners();
    }
  }

  // Stop sensor monitoring
  void stopMonitoring() {
    _sensorTimer?.cancel();
    _sensorTimer = null;
    
    // Stop all sensor streams
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    
    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _magnetometerSubscription = null;
    
    _isMonitoring = false;
    notifyListeners();
  }

  // Start accelerometer stream
  void _startAccelerometerStream() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      _accelerationX = event.x;
      _accelerationY = event.y;
      _accelerationZ = event.z;
      _calculateSpeed();
    });
  }

  // Start gyroscope stream
  void _startGyroscopeStream() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      _gyroscopeX = event.x;
      _gyroscopeY = event.y;
      _gyroscopeZ = event.z;
    });
  }

  // Start magnetometer stream
  void _startMagnetometerStream() {
    _magnetometerSubscription = magnetometerEvents.listen((MagnetometerEvent event) {
      _magnetometerX = event.x;
      _magnetometerY = event.y;
      _magnetometerZ = event.z;
    });
  }

  // Calculate speed from accelerometer data
  void _calculateSpeed() {
    final now = DateTime.now();
    
    // Calculate acceleration magnitude (excluding gravity)
    final accelerationMagnitude = sqrt(
      pow(_accelerationX, 2) + 
      pow(_accelerationY, 2) + 
      pow(_accelerationZ - 9.81, 2) // Subtract gravity
    );
    
    // Simple speed calculation based on acceleration
    if (_lastSpeedUpdate != null) {
      final timeDelta = now.difference(_lastSpeedUpdate!).inMilliseconds / 1000.0;
      if (timeDelta > 0) {
        final speedChange = accelerationMagnitude * timeDelta;
        _currentSpeed = (_currentSpeed + speedChange).clamp(0.0, 200.0); // Max 200 km/h
        
        // Add some deceleration to simulate friction
        _currentSpeed *= 0.98;
      }
    }
    
    _lastSpeedUpdate = now;
    _speedHistory.add(_currentSpeed);
    
    // Keep only last 100 speed readings
    if (_speedHistory.length > 100) {
      _speedHistory.removeAt(0);
    }
  }

  // Generate sensor data with real sensor readings
  void _generateSensorDataWithRealSensors(String busId) {
    final random = Random();
    final now = DateTime.now();

    // Generate realistic sensor readings with some variation
    final sensorData = SensorData(
      id: now.millisecondsSinceEpoch.toString(),
      busId: busId,
      engineTemperature: 85 + random.nextDouble() * 15, // 85-100°C
      fuelLevel: 20 + random.nextDouble() * 60, // 20-80%
      batteryVoltage: 12.0 + random.nextDouble() * 2.0, // 12-14V
      tirePressure: 30 + random.nextDouble() * 10, // 30-40 PSI
      brakePadWear: 20 + random.nextDouble() * 40, // 20-60%
      engineOilLevel: 30 + random.nextDouble() * 50, // 30-80%
      coolantLevel: 40 + random.nextDouble() * 40, // 40-80%
      doorOpen: random.nextBool() && random.nextDouble() < 0.1, // 10% chance
      emergencyBrake: random.nextBool() && random.nextDouble() < 0.05, // 5% chance
      seatbeltWarning: random.nextBool() && random.nextDouble() < 0.15, // 15% chance
      airbagStatus: random.nextBool() && random.nextDouble() < 0.02, // 2% chance
      timestamp: now,
      // Real device sensor data
      speed: _currentSpeed,
      accelerationX: _accelerationX,
      accelerationY: _accelerationY,
      accelerationZ: _accelerationZ,
      gyroscopeX: _gyroscopeX,
      gyroscopeY: _gyroscopeY,
      gyroscopeZ: _gyroscopeZ,
      magnetometerX: _magnetometerX,
      magnetometerY: _magnetometerY,
      magnetometerZ: _magnetometerZ,
    );

    _currentSensorData = sensorData;
    _sensorHistory.add(sensorData);

    // Keep only last 1000 readings to prevent memory issues
    if (_sensorHistory.length > 1000) {
      _sensorHistory.removeAt(0);
    }

    notifyListeners();
  }

  // Generate realistic sensor data (legacy method for fallback)
  void _generateSensorData(String busId) {
    final random = Random();
    final now = DateTime.now();

    // Simulate realistic sensor readings with some variation
    final sensorData = SensorData(
      id: now.millisecondsSinceEpoch.toString(),
      busId: busId,
      engineTemperature: 85 + random.nextDouble() * 15, // 85-100°C
      fuelLevel: 20 + random.nextDouble() * 60, // 20-80%
      batteryVoltage: 12.0 + random.nextDouble() * 2.0, // 12-14V
      tirePressure: 30 + random.nextDouble() * 10, // 30-40 PSI
      brakePadWear: 20 + random.nextDouble() * 40, // 20-60%
      engineOilLevel: 30 + random.nextDouble() * 50, // 30-80%
      coolantLevel: 40 + random.nextDouble() * 40, // 40-80%
      doorOpen: random.nextBool() && random.nextDouble() < 0.1, // 10% chance
      emergencyBrake: random.nextBool() && random.nextDouble() < 0.05, // 5% chance
      seatbeltWarning: random.nextBool() && random.nextDouble() < 0.15, // 15% chance
      airbagStatus: random.nextBool() && random.nextDouble() < 0.02, // 2% chance
      timestamp: now,
    );

    _currentSensorData = sensorData;
    _sensorHistory.add(sensorData);

    // Keep only last 1000 readings to prevent memory issues
    if (_sensorHistory.length > 1000) {
      _sensorHistory.removeAt(0);
    }

    notifyListeners();
  }

  // Get sensor data for a specific bus
  List<SensorData> getSensorDataForBus(String busId) {
    return _sensorHistory.where((data) => data.busId == busId).toList();
  }

  // Get latest sensor data for a bus
  SensorData? getLatestSensorDataForBus(String busId) {
    final busData = getSensorDataForBus(busId);
    if (busData.isEmpty) return null;
    
    busData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return busData.first;
  }

  // Get critical alerts for all buses
  List<Map<String, dynamic>> getCriticalAlerts() {
    List<Map<String, dynamic>> alerts = [];
    
    // Group by bus ID
    Map<String, List<SensorData>> busData = {};
    for (var data in _sensorHistory) {
      busData.putIfAbsent(data.busId, () => []).add(data);
    }

    // Check each bus for critical alerts
    for (var entry in busData.entries) {
      final latestData = getLatestSensorDataForBus(entry.key);
      if (latestData != null) {
        final criticalAlerts = latestData.criticalAlerts;
        if (criticalAlerts.isNotEmpty) {
          alerts.add({
            'busId': entry.key,
            'alerts': criticalAlerts,
            'timestamp': latestData.timestamp,
            'healthStatus': latestData.healthStatus,
          });
        }
      }
    }

    return alerts;
  }

  // Get health status for all buses
  Map<String, String> getBusHealthStatus() {
    Map<String, String> healthStatus = {};
    
    // Group by bus ID
    Map<String, List<SensorData>> busData = {};
    for (var data in _sensorHistory) {
      busData.putIfAbsent(data.busId, () => []).add(data);
    }

    // Get health status for each bus
    for (var entry in busData.entries) {
      final latestData = getLatestSensorDataForBus(entry.key);
      if (latestData != null) {
        healthStatus[entry.key] = latestData.healthStatus;
      }
    }

    return healthStatus;
  }

  // Get sensor data within time range
  List<SensorData> getSensorDataInTimeRange(DateTime start, DateTime end) {
    return _sensorHistory.where((data) {
      return data.timestamp.isAfter(start) && data.timestamp.isBefore(end);
    }).toList();
  }

  // Get average sensor readings for a time period
  Map<String, double> getAverageReadings(DateTime start, DateTime end) {
    final data = getSensorDataInTimeRange(start, end);
    if (data.isEmpty) return {};

    double totalEngineTemp = 0;
    double totalFuelLevel = 0;
    double totalBatteryVoltage = 0;
    double totalTirePressure = 0;
    double totalBrakeWear = 0;

    for (var sensorData in data) {
      totalEngineTemp += sensorData.engineTemperature;
      totalFuelLevel += sensorData.fuelLevel;
      totalBatteryVoltage += sensorData.batteryVoltage;
      totalTirePressure += sensorData.tirePressure;
      totalBrakeWear += sensorData.brakePadWear;
    }

    return {
      'engineTemperature': totalEngineTemp / data.length,
      'fuelLevel': totalFuelLevel / data.length,
      'batteryVoltage': totalBatteryVoltage / data.length,
      'tirePressure': totalTirePressure / data.length,
      'brakePadWear': totalBrakeWear / data.length,
    };
  }

  // Simulate sensor malfunction
  void simulateMalfunction(String busId, String sensorType) {
    final now = DateTime.now();
    final random = Random();
    
    SensorData malfunctionData;
    
    switch (sensorType) {
      case 'engine':
        malfunctionData = SensorData(
          id: now.millisecondsSinceEpoch.toString(),
          busId: busId,
          engineTemperature: 120 + random.nextDouble() * 20, // Overheating
          fuelLevel: 50 + random.nextDouble() * 30,
          batteryVoltage: 12.0 + random.nextDouble() * 2.0,
          tirePressure: 30 + random.nextDouble() * 10,
          brakePadWear: 20 + random.nextDouble() * 40,
          engineOilLevel: 30 + random.nextDouble() * 50,
          coolantLevel: 40 + random.nextDouble() * 40,
          doorOpen: false,
          emergencyBrake: false,
          seatbeltWarning: false,
          airbagStatus: false,
          timestamp: now,
        );
        break;
      case 'fuel':
        malfunctionData = SensorData(
          id: now.millisecondsSinceEpoch.toString(),
          busId: busId,
          engineTemperature: 85 + random.nextDouble() * 15,
          fuelLevel: random.nextDouble() * 5, // Very low fuel
          batteryVoltage: 12.0 + random.nextDouble() * 2.0,
          tirePressure: 30 + random.nextDouble() * 10,
          brakePadWear: 20 + random.nextDouble() * 40,
          engineOilLevel: 30 + random.nextDouble() * 50,
          coolantLevel: 40 + random.nextDouble() * 40,
          doorOpen: false,
          emergencyBrake: false,
          seatbeltWarning: false,
          airbagStatus: false,
          timestamp: now,
        );
        break;
      default:
        return;
    }

    _currentSensorData = malfunctionData;
    _sensorHistory.add(malfunctionData);
    notifyListeners();
  }

  // Get real-time acceleration data
  Map<String, double> getAccelerationData() {
    return {
      'x': _accelerationX,
      'y': _accelerationY,
      'z': _accelerationZ,
    };
  }

  // Get real-time gyroscope data
  Map<String, double> getGyroscopeData() {
    return {
      'x': _gyroscopeX,
      'y': _gyroscopeY,
      'z': _gyroscopeZ,
    };
  }

  // Get real-time magnetometer data
  Map<String, double> getMagnetometerData() {
    return {
      'x': _magnetometerX,
      'y': _magnetometerY,
      'z': _magnetometerZ,
    };
  }

  // Get speed history
  List<double> getSpeedHistory() {
    return List.unmodifiable(_speedHistory);
  }

  // Get average speed over time period
  double getAverageSpeed(Duration timePeriod) {
    final cutoffTime = DateTime.now().subtract(timePeriod);
    final recentSpeeds = _speedHistory.where((speed) => 
      _lastSpeedUpdate != null && 
      _lastSpeedUpdate!.isAfter(cutoffTime)
    ).toList();
    
    if (recentSpeeds.isEmpty) return 0.0;
    return recentSpeeds.reduce((a, b) => a + b) / recentSpeeds.length;
  }

  // Check if device is moving (based on acceleration)
  bool get isMoving {
    final accelerationMagnitude = sqrt(
      pow(_accelerationX, 2) + 
      pow(_accelerationY, 2) + 
      pow(_accelerationZ - 9.81, 2)
    );
    return accelerationMagnitude > 0.5; // Threshold for movement detection
  }

  // Get device orientation (simplified)
  String get deviceOrientation {
    if (_accelerationZ > 8) return 'Portrait';
    if (_accelerationZ < -8) return 'Portrait Upside Down';
    if (_accelerationX > 8) return 'Landscape Left';
    if (_accelerationX < -8) return 'Landscape Right';
    return 'Unknown';
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
