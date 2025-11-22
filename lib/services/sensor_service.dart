import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';

class SensorService extends ChangeNotifier {
  Timer? _sensorTimer;
  final List<SensorData> _sensorHistory = [];
  SensorData? _currentSensorData;
  bool _isMonitoring = false;
  String? _error;

  List<SensorData> get sensorHistory => List.unmodifiable(_sensorHistory);
  SensorData? get currentSensorData => _currentSensorData;
  bool get isMonitoring => _isMonitoring;
  String? get error => _error;

  // Start sensor monitoring
  void startMonitoring(String busId) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _error = null;
    notifyListeners();

    // Simulate sensor data every 5 seconds
    _sensorTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _generateSensorData(busId);
    });
  }

  // Stop sensor monitoring
  void stopMonitoring() {
    _sensorTimer?.cancel();
    _sensorTimer = null;
    _isMonitoring = false;
    notifyListeners();
  }

  // Generate realistic sensor data
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

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
