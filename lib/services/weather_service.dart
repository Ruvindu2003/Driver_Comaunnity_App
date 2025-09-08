import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService extends ChangeNotifier {
  Timer? _weatherTimer;
  final List<WeatherData> _weatherHistory = [];
  WeatherData? _currentWeather;
  bool _isMonitoring = false;
  String? _error;
  
  // API configuration (you'll need to get a free API key from OpenWeatherMap)
  static const String _apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  List<WeatherData> get weatherHistory => List.unmodifiable(_weatherHistory);
  WeatherData? get currentWeather => _currentWeather;
  bool get isMonitoring => _isMonitoring;
  String? get error => _error;

  // Start weather monitoring
  void startWeatherMonitoring(double latitude, double longitude) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _error = null;
    notifyListeners();

    // Update weather every 10 minutes
    _weatherTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _updateWeather(latitude, longitude);
    });

    // Initial update
    _updateWeather(latitude, longitude);
  }

  // Stop weather monitoring
  void stopWeatherMonitoring() {
    _weatherTimer?.cancel();
    _weatherTimer = null;
    _isMonitoring = false;
    notifyListeners();
  }

  // Update weather data
  Future<void> _updateWeather(double latitude, double longitude) async {
    try {
      // Try to get real weather data first
      final weatherData = await _fetchWeatherData(latitude, longitude);
      if (weatherData != null) {
        _currentWeather = weatherData;
        _weatherHistory.add(weatherData);
        
        // Keep only last 100 readings
        if (_weatherHistory.length > 100) {
          _weatherHistory.removeAt(0);
        }
        
        _error = null;
        notifyListeners();
        return;
      }
    } catch (e) {
      // If real weather data fails, use simulated data
      _error = 'Weather API error: $e. Using simulated data.';
    }

    // Fallback to simulated weather data
    final simulatedWeather = _generateSimulatedWeather(latitude, longitude);
    _currentWeather = simulatedWeather;
    _weatherHistory.add(simulatedWeather);
    
    // Keep only last 100 readings
    if (_weatherHistory.length > 100) {
      _weatherHistory.removeAt(0);
    }
    
    notifyListeners();
  }

  // Fetch real weather data from OpenWeatherMap API
  Future<WeatherData?> _fetchWeatherData(double latitude, double longitude) async {
    if (_apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
      throw Exception('Please set your OpenWeatherMap API key');
    }

    final url = '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherData(data, latitude, longitude);
      } else {
        throw Exception('Weather API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }

  // Parse weather data from API response
  WeatherData _parseWeatherData(Map<String, dynamic> data, double latitude, double longitude) {
    final weather = data['weather'][0];
    final main = data['main'];
    final wind = data['wind'];
    final visibility = data['visibility'] ?? 10000; // Default visibility in meters
    
    return WeatherData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: latitude,
      longitude: longitude,
      condition: _mapWeatherCondition(weather['main']),
      temperature: main['temp'].toDouble(),
      humidity: main['humidity'].toDouble(),
      windSpeed: wind['speed'].toDouble() * 3.6, // Convert m/s to km/h
      windDirection: wind['deg']?.toDouble() ?? 0.0,
      visibility: visibility.toDouble(),
      precipitation: _getPrecipitation(data),
      pressure: main['pressure'].toDouble(),
      uvIndex: _getUVIndex(data),
      timestamp: DateTime.now(),
    );
  }

  // Map weather condition from API to our format
  String _mapWeatherCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'clear';
      case 'clouds':
        return 'clear';
      case 'rain':
      case 'drizzle':
        return 'rain';
      case 'snow':
        return 'snow';
      case 'mist':
      case 'fog':
      case 'haze':
        return 'fog';
      case 'thunderstorm':
        return 'storm';
      default:
        return 'clear';
    }
  }

  // Get precipitation data
  double _getPrecipitation(Map<String, dynamic> data) {
    final rain = data['rain'];
    if (rain != null && rain['1h'] != null) {
      return rain['1h'].toDouble();
    }
    return 0.0;
  }

  // Get UV index (simulated for now)
  double _getUVIndex(Map<String, dynamic> data) {
    // OpenWeatherMap doesn't provide UV index in the free tier
    // This would require a separate API call or subscription
    final random = Random();
    return random.nextDouble() * 11;
  }

  // Generate simulated weather data
  WeatherData _generateSimulatedWeather(double latitude, double longitude) {
    final random = Random();
    final conditions = ['clear', 'rain', 'snow', 'fog', 'storm'];
    final condition = conditions[random.nextInt(conditions.length)];
    
    // Simulate realistic weather based on condition
    double temperature, humidity, windSpeed, visibility, precipitation;
    
    switch (condition) {
      case 'clear':
        temperature = 20 + random.nextDouble() * 15; // 20-35°C
        humidity = 30 + random.nextDouble() * 30; // 30-60%
        windSpeed = random.nextDouble() * 30; // 0-30 km/h
        visibility = 800 + random.nextDouble() * 200; // 800-1000m
        precipitation = 0.0;
        break;
      case 'rain':
        temperature = 15 + random.nextDouble() * 10; // 15-25°C
        humidity = 70 + random.nextDouble() * 20; // 70-90%
        windSpeed = 10 + random.nextDouble() * 40; // 10-50 km/h
        visibility = 200 + random.nextDouble() * 300; // 200-500m
        precipitation = 1 + random.nextDouble() * 10; // 1-11 mm/h
        break;
      case 'snow':
        temperature = -5 + random.nextDouble() * 10; // -5 to 5°C
        humidity = 80 + random.nextDouble() * 15; // 80-95%
        windSpeed = 5 + random.nextDouble() * 25; // 5-30 km/h
        visibility = 100 + random.nextDouble() * 200; // 100-300m
        precipitation = 0.5 + random.nextDouble() * 5; // 0.5-5.5 mm/h
        break;
      case 'fog':
        temperature = 10 + random.nextDouble() * 15; // 10-25°C
        humidity = 90 + random.nextDouble() * 8; // 90-98%
        windSpeed = random.nextDouble() * 15; // 0-15 km/h
        visibility = 50 + random.nextDouble() * 100; // 50-150m
        precipitation = random.nextDouble() * 2; // 0-2 mm/h
        break;
      case 'storm':
        temperature = 15 + random.nextDouble() * 10; // 15-25°C
        humidity = 85 + random.nextDouble() * 10; // 85-95%
        windSpeed = 40 + random.nextDouble() * 60; // 40-100 km/h
        visibility = 100 + random.nextDouble() * 200; // 100-300m
        precipitation = 5 + random.nextDouble() * 20; // 5-25 mm/h
        break;
      default:
        temperature = 20.0;
        humidity = 50.0;
        windSpeed = 10.0;
        visibility = 1000.0;
        precipitation = 0.0;
    }
    
    return WeatherData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: latitude,
      longitude: longitude,
      condition: condition,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      windDirection: random.nextDouble() * 360,
      visibility: visibility,
      precipitation: precipitation,
      pressure: 980 + random.nextDouble() * 40, // 980-1020 hPa
      uvIndex: random.nextDouble() * 11, // 0-11
      timestamp: DateTime.now(),
    );
  }

  // Get weather data for a specific location
  Future<WeatherData?> getWeatherForLocation(double latitude, double longitude) async {
    try {
      return await _fetchWeatherData(latitude, longitude);
    } catch (e) {
      return _generateSimulatedWeather(latitude, longitude);
    }
  }

  // Get weather data within time range
  List<WeatherData> getWeatherInTimeRange(DateTime start, DateTime end) {
    return _weatherHistory.where((weather) {
      return weather.timestamp.isAfter(start) && weather.timestamp.isBefore(end);
    }).toList();
  }

  // Get average weather conditions for a time period
  Map<String, double> getAverageWeather(DateTime start, DateTime end) {
    final weatherData = getWeatherInTimeRange(start, end);
    if (weatherData.isEmpty) return {};

    double totalTemp = 0;
    double totalHumidity = 0;
    double totalWindSpeed = 0;
    double totalVisibility = 0;
    double totalPrecipitation = 0;

    for (var weather in weatherData) {
      totalTemp += weather.temperature;
      totalHumidity += weather.humidity;
      totalWindSpeed += weather.windSpeed;
      totalVisibility += weather.visibility;
      totalPrecipitation += weather.precipitation;
    }

    return {
      'temperature': totalTemp / weatherData.length,
      'humidity': totalHumidity / weatherData.length,
      'windSpeed': totalWindSpeed / weatherData.length,
      'visibility': totalVisibility / weatherData.length,
      'precipitation': totalPrecipitation / weatherData.length,
    };
  }

  @override
  void dispose() {
    stopWeatherMonitoring();
    super.dispose();
  }
}
