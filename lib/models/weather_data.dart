class WeatherData {
  final String id;
  final double latitude;
  final double longitude;
  final String condition; // 'clear', 'rain', 'snow', 'fog', 'storm'
  final double temperature; // Celsius
  final double humidity; // Percentage
  final double windSpeed; // km/h
  final double windDirection; // Degrees
  final double visibility; // meters
  final double precipitation; // mm/h
  final double pressure; // hPa
  final double uvIndex; // 0-11
  final DateTime timestamp;

  WeatherData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.precipitation,
    required this.pressure,
    required this.uvIndex,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'condition': condition,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'visibility': visibility,
      'precipitation': precipitation,
      'pressure': pressure,
      'uvIndex': uvIndex,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      id: json['id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      condition: json['condition'],
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      windSpeed: json['windSpeed'].toDouble(),
      windDirection: json['windDirection'].toDouble(),
      visibility: json['visibility'].toDouble(),
      precipitation: json['precipitation'].toDouble(),
      pressure: json['pressure'].toDouble(),
      uvIndex: json['uvIndex'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Get road condition based on weather
  String get roadCondition {
    if (precipitation > 10 && temperature < 0) {
      return 'icy';
    } else if (precipitation > 5) {
      return 'wet';
    } else if (windSpeed > 50 && precipitation > 2) {
      return 'slippery';
    } else if (condition == 'fog' && visibility < 100) {
      return 'slippery';
    } else {
      return 'dry';
    }
  }

  // Get safety level (0.0 to 1.0)
  double get safetyLevel {
    double level = 1.0;
    
    // Visibility factor
    if (visibility < 50) {
      level -= 0.3;
    } else if (visibility < 100) {
      level -= 0.2;
    } else if (visibility < 200) {
      level -= 0.1;
    }
    
    // Wind factor
    if (windSpeed > 80) {
      level -= 0.2;
    } else if (windSpeed > 60) {
      level -= 0.1;
    }
    
    // Precipitation factor
    if (precipitation > 20) {
      level -= 0.2;
    } else if (precipitation > 10) {
      level -= 0.1;
    }
    
    // Temperature factor (ice formation)
    if (temperature < -5) {
      level -= 0.1;
    }
    
    return level.clamp(0.0, 1.0);
  }

  // Get recommended speed limit based on weather
  double get recommendedSpeedLimit {
    double baseSpeed = 80.0; // Default highway speed
    
    switch (condition) {
      case 'clear':
        return baseSpeed;
      case 'rain':
        return baseSpeed * 0.8;
      case 'snow':
        return baseSpeed * 0.6;
      case 'fog':
        if (visibility < 50) {
          return 30.0;
        } else if (visibility < 100) {
          return 50.0;
        } else {
          return baseSpeed * 0.7;
        }
      case 'storm':
        return baseSpeed * 0.5;
      default:
        return baseSpeed;
    }
  }
}
