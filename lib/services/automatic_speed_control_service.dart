import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/speed_control_data.dart';
import '../models/weather_data.dart';
import '../models/location_data.dart';
import '../models/sensor_data.dart';
import 'location_service.dart';
import 'sensor_service.dart';

class AutomaticSpeedControlService extends ChangeNotifier {
  Timer? _controlTimer;
  final List<SpeedControlData> _speedControlHistory = [];
  SpeedControlData? _currentSpeedControl;
  bool _isActive = false;
  String? _error;
  
  // Services
  final LocationService _locationService;
  final SensorService _sensorService;
  
  // Configuration
  final Map<String, double> _speedLimits = {
    'school_zone': 30.0,
    'residential': 40.0,
    'urban': 50.0,
    'highway': 80.0,
    'construction': 30.0,
  };
  
  final Map<String, double> _weatherMultipliers = {
    'clear': 1.0,
    'rain': 0.8,
    'snow': 0.6,
    'fog': 0.7,
    'storm': 0.5,
  };

  AutomaticSpeedControlService({
    required LocationService locationService,
    required SensorService sensorService,
  }) : _locationService = locationService,
       _sensorService = sensorService;

  List<SpeedControlData> get speedControlHistory => List.unmodifiable(_speedControlHistory);
  SpeedControlData? get currentSpeedControl => _currentSpeedControl;
  bool get isActive => _isActive;
  String? get error => _error;

  // Start automatic speed control
  void startSpeedControl(String busId) {
    if (_isActive) return;

    _isActive = true;
    _error = null;
    notifyListeners();

    // Update speed control every 2 seconds
    _controlTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateSpeedControl(busId);
    });
  }

  // Stop automatic speed control
  void stopSpeedControl() {
    _controlTimer?.cancel();
    _controlTimer = null;
    _isActive = false;
    notifyListeners();
  }

  // Update speed control based on current conditions
  Future<void> _updateSpeedControl(String busId) async {
    try {
      final location = _locationService.currentLocation;
      final sensorData = _sensorService.currentSensorData;
      
      if (location == null || sensorData == null) {
        _error = 'Location or sensor data not available';
        notifyListeners();
        return;
      }

      // Get weather data (simulated for now)
      final weatherData = await _getWeatherData(location.latitude, location.longitude);
      
      // Determine road type and conditions
      final roadType = _determineRoadType(location);
      final isInSchoolZone = _isInSchoolZone(location);
      final isInResidentialArea = _isInResidentialArea(location);
      final isInHighway = roadType == 'highway';
      
      // Calculate recommended speed
      final recommendedSpeed = _calculateRecommendedSpeed(
        weatherData,
        roadType,
        isInSchoolZone,
        isInResidentialArea,
        sensorData,
      );
      
      // Calculate max allowed speed
      final maxAllowedSpeed = _calculateMaxAllowedSpeed(
        weatherData,
        roadType,
        isInSchoolZone,
        sensorData,
      );
      
      // Calculate braking force
      final brakingForce = _calculateBrakingForce(
        location.speed,
        recommendedSpeed,
        weatherData,
        sensorData,
      );
      
      // Determine if auto braking is needed
      final isAutoBrakingActive = _shouldActivateAutoBraking(
        location.speed,
        maxAllowedSpeed,
        weatherData,
        sensorData,
      );
      
      // Generate warnings
      final activeWarnings = _generateWarnings(
        location.speed,
        recommendedSpeed,
        maxAllowedSpeed,
        weatherData,
        isInSchoolZone,
        sensorData,
      );
      
      // Create speed control data
      final speedControlData = SpeedControlData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        busId: busId,
        currentSpeed: location.speed,
        recommendedSpeed: recommendedSpeed,
        maxAllowedSpeed: maxAllowedSpeed,
        brakingForce: brakingForce,
        isAutoBrakingActive: isAutoBrakingActive,
        isSpeedControlActive: _isActive,
        weatherCondition: weatherData.condition,
        roadCondition: weatherData.roadCondition,
        passengerCount: _getPassengerCount(busId), // This would come from passenger counting system
        isInSchoolZone: isInSchoolZone,
        isInResidentialArea: isInResidentialArea,
        isInHighway: isInHighway,
        visibility: weatherData.visibility,
        roadFriction: _calculateRoadFriction(weatherData),
        trafficDensity: _calculateTrafficDensity(location),
        activeWarnings: activeWarnings,
        timestamp: DateTime.now(),
      );

      _currentSpeedControl = speedControlData;
      _speedControlHistory.add(speedControlData);

      // Keep only last 1000 readings
      if (_speedControlHistory.length > 1000) {
        _speedControlHistory.removeAt(0);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error updating speed control: $e';
      notifyListeners();
    }
  }

  // Get weather data (simulated for now)
  Future<WeatherData> _getWeatherData(double latitude, double longitude) async {
    // In a real implementation, this would call a weather API
    final random = Random();
    final conditions = ['clear', 'rain', 'snow', 'fog', 'storm'];
    final condition = conditions[random.nextInt(conditions.length)];
    
    return WeatherData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: latitude,
      longitude: longitude,
      condition: condition,
      temperature: 15 + random.nextDouble() * 20, // 15-35°C
      humidity: 30 + random.nextDouble() * 40, // 30-70%
      windSpeed: random.nextDouble() * 100, // 0-100 km/h
      windDirection: random.nextDouble() * 360, // 0-360°
      visibility: 50 + random.nextDouble() * 950, // 50-1000m
      precipitation: random.nextDouble() * 30, // 0-30 mm/h
      pressure: 980 + random.nextDouble() * 40, // 980-1020 hPa
      uvIndex: random.nextDouble() * 11, // 0-11
      timestamp: DateTime.now(),
    );
  }

  // Determine road type based on location
  String _determineRoadType(LocationData location) {
    // This would use map data or GPS coordinates to determine road type
    // For now, we'll simulate based on speed
    if (location.speed > 60) {
      return 'highway';
    } else if (location.speed > 40) {
      return 'urban';
    } else {
      return 'residential';
    }
  }

  // Check if in school zone
  bool _isInSchoolZone(LocationData location) {
    // This would check against a database of school zones
    // For now, we'll simulate based on time and location
    final hour = DateTime.now().hour;
    return hour >= 7 && hour <= 9 || hour >= 14 && hour <= 16;
  }

  // Check if in residential area
  bool _isInResidentialArea(LocationData location) {
    // This would check against map data
    // For now, we'll simulate based on speed
    return location.speed < 50;
  }

  // Calculate recommended speed
  double _calculateRecommendedSpeed(
    WeatherData weather,
    String roadType,
    bool isInSchoolZone,
    bool isInResidentialArea,
    SensorData sensorData,
  ) {
    double baseSpeed = _speedLimits[roadType] ?? 50.0;
    
    // Apply weather multiplier
    baseSpeed *= _weatherMultipliers[weather.condition] ?? 1.0;
    
    // School zone override
    if (isInSchoolZone) {
      baseSpeed = _speedLimits['school_zone']!;
    }
    
    // Sensor data adjustments
    if (sensorData.brakePadWear > 60) {
      baseSpeed *= 0.9; // Reduce speed if brakes are worn
    }
    
    if (sensorData.tirePressure < 30) {
      baseSpeed *= 0.8; // Reduce speed if tires are underinflated
    }
    
    return baseSpeed;
  }

  // Calculate max allowed speed
  double _calculateMaxAllowedSpeed(
    WeatherData weather,
    String roadType,
    bool isInSchoolZone,
    SensorData sensorData,
  ) {
    double maxSpeed = _calculateRecommendedSpeed(weather, roadType, isInSchoolZone, false, sensorData);
    
    // Add some tolerance but cap it
    maxSpeed *= 1.1;
    
    // Absolute maximums based on conditions
    if (weather.condition == 'storm') {
      maxSpeed = min(maxSpeed, 50.0);
    } else if (weather.condition == 'snow') {
      maxSpeed = min(maxSpeed, 40.0);
    } else if (weather.condition == 'fog' && weather.visibility < 100) {
      maxSpeed = min(maxSpeed, 30.0);
    }
    
    return maxSpeed;
  }

  // Calculate braking force
  double _calculateBrakingForce(
    double currentSpeed,
    double recommendedSpeed,
    WeatherData weather,
    SensorData sensorData,
  ) {
    if (currentSpeed <= recommendedSpeed) {
      return 0.0;
    }
    
    double speedDifference = currentSpeed - recommendedSpeed;
    double brakingForce = speedDifference / recommendedSpeed;
    
    // Adjust for weather conditions
    if (weather.condition == 'rain') {
      brakingForce *= 1.2;
    } else if (weather.condition == 'snow') {
      brakingForce *= 1.5;
    } else if (weather.condition == 'storm') {
      brakingForce *= 1.3;
    }
    
    // Adjust for road conditions
    if (weather.roadCondition == 'wet') {
      brakingForce *= 1.1;
    } else if (weather.roadCondition == 'icy') {
      brakingForce *= 1.4;
    }
    
    // Adjust for brake condition
    if (sensorData.brakePadWear > 60) {
      brakingForce *= 1.2;
    }
    
    return brakingForce.clamp(0.0, 1.0);
  }

  // Determine if auto braking should be activated
  bool _shouldActivateAutoBraking(
    double currentSpeed,
    double maxAllowedSpeed,
    WeatherData weather,
    SensorData sensorData,
  ) {
    // Emergency conditions
    if (currentSpeed > maxAllowedSpeed * 1.5) {
      return true;
    }
    
    if (weather.condition == 'storm' && currentSpeed > 50) {
      return true;
    }
    
    if (weather.roadCondition == 'icy' && currentSpeed > 40) {
      return true;
    }
    
    if (weather.visibility < 30 && currentSpeed > 40) {
      return true;
    }
    
    // Sensor-based conditions
    if (sensorData.emergencyBrake) {
      return true;
    }
    
    if (sensorData.brakePadWear > 80) {
      return true;
    }
    
    return false;
  }

  // Generate warnings
  List<String> _generateWarnings(
    double currentSpeed,
    double recommendedSpeed,
    double maxAllowedSpeed,
    WeatherData weather,
    bool isInSchoolZone,
    SensorData sensorData,
  ) {
    List<String> warnings = [];
    
    if (currentSpeed > maxAllowedSpeed) {
      warnings.add('Speed Limit Exceeded');
    }
    
    if (currentSpeed > recommendedSpeed * 1.1) {
      warnings.add('Speed Above Recommended');
    }
    
    if (weather.condition == 'storm' && currentSpeed > 40) {
      warnings.add('High Speed in Storm');
    }
    
    if (weather.roadCondition == 'icy' && currentSpeed > 30) {
      warnings.add('High Speed on Icy Road');
    }
    
    if (weather.visibility < 50 && currentSpeed > 30) {
      warnings.add('Low Visibility - Reduce Speed');
    }
    
    if (isInSchoolZone && currentSpeed > 30) {
      warnings.add('School Zone Speed Limit');
    }
    
    if (sensorData.brakePadWear > 60) {
      warnings.add('Brake Pads Need Attention');
    }
    
    if (sensorData.tirePressure < 30) {
      warnings.add('Low Tire Pressure');
    }
    
    return warnings;
  }

  // Get passenger count (simulated)
  int _getPassengerCount(String busId) {
    // This would come from a passenger counting system
    final random = Random();
    return random.nextInt(60); // 0-60 passengers
  }

  // Calculate road friction
  double _calculateRoadFriction(WeatherData weather) {
    double friction = 1.0;
    
    switch (weather.roadCondition) {
      case 'dry':
        friction = 1.0;
        break;
      case 'wet':
        friction = 0.8;
        break;
      case 'icy':
        friction = 0.3;
        break;
      case 'slippery':
        friction = 0.6;
        break;
      case 'construction':
        friction = 0.7;
        break;
    }
    
    return friction;
  }

  // Calculate traffic density
  double _calculateTrafficDensity(LocationData location) {
    // This would use real-time traffic data
    // For now, we'll simulate based on time of day
    final hour = DateTime.now().hour;
    if (hour >= 7 && hour <= 9 || hour >= 17 && hour <= 19) {
      return 0.8; // Rush hour
    } else if (hour >= 10 && hour <= 16) {
      return 0.4; // Daytime
    } else {
      return 0.2; // Night time
    }
  }

  // Get speed control data for a specific bus
  List<SpeedControlData> getSpeedControlDataForBus(String busId) {
    return _speedControlHistory.where((data) => data.busId == busId).toList();
  }

  // Get latest speed control data for a bus
  SpeedControlData? getLatestSpeedControlDataForBus(String busId) {
    final busData = getSpeedControlDataForBus(busId);
    if (busData.isEmpty) return null;
    
    busData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return busData.first;
  }

  // Get critical alerts for all buses
  List<Map<String, dynamic>> getCriticalAlerts() {
    List<Map<String, dynamic>> alerts = [];
    
    // Group by bus ID
    Map<String, List<SpeedControlData>> busData = {};
    for (var data in _speedControlHistory) {
      busData.putIfAbsent(data.busId, () => []).add(data);
    }

    // Check each bus for critical alerts
    for (var entry in busData.entries) {
      final latestData = getLatestSpeedControlDataForBus(entry.key);
      if (latestData != null) {
        final criticalWarnings = latestData.criticalWarnings;
        if (criticalWarnings.isNotEmpty) {
          alerts.add({
            'busId': entry.key,
            'warnings': criticalWarnings,
            'timestamp': latestData.timestamp,
            'safetyScore': latestData.safetyScore,
            'needsEmergencyBraking': latestData.needsEmergencyBraking,
          });
        }
      }
    }

    return alerts;
  }

  @override
  void dispose() {
    stopSpeedControl();
    super.dispose();
  }
}
