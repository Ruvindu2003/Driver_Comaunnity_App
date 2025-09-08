class SpeedControlData {
  final String id;
  final String busId;
  final double currentSpeed; // km/h
  final double recommendedSpeed; // km/h
  final double maxAllowedSpeed; // km/h
  final double brakingForce; // 0.0 to 1.0
  final bool isAutoBrakingActive;
  final bool isSpeedControlActive;
  final String weatherCondition; // 'clear', 'rain', 'snow', 'fog', 'storm'
  final String roadCondition; // 'dry', 'wet', 'icy', 'slippery', 'construction'
  final int passengerCount;
  final bool isInSchoolZone;
  final bool isInResidentialArea;
  final bool isInHighway;
  final double visibility; // meters
  final double roadFriction; // 0.0 to 1.0
  final double trafficDensity; // 0.0 to 1.0
  final List<String> activeWarnings;
  final DateTime timestamp;

  SpeedControlData({
    required this.id,
    required this.busId,
    required this.currentSpeed,
    required this.recommendedSpeed,
    required this.maxAllowedSpeed,
    required this.brakingForce,
    required this.isAutoBrakingActive,
    required this.isSpeedControlActive,
    required this.weatherCondition,
    required this.roadCondition,
    required this.passengerCount,
    required this.isInSchoolZone,
    required this.isInResidentialArea,
    required this.isInHighway,
    required this.visibility,
    required this.roadFriction,
    required this.trafficDensity,
    required this.activeWarnings,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busId': busId,
      'currentSpeed': currentSpeed,
      'recommendedSpeed': recommendedSpeed,
      'maxAllowedSpeed': maxAllowedSpeed,
      'brakingForce': brakingForce,
      'isAutoBrakingActive': isAutoBrakingActive,
      'isSpeedControlActive': isSpeedControlActive,
      'weatherCondition': weatherCondition,
      'roadCondition': roadCondition,
      'passengerCount': passengerCount,
      'isInSchoolZone': isInSchoolZone,
      'isInResidentialArea': isInResidentialArea,
      'isInHighway': isInHighway,
      'visibility': visibility,
      'roadFriction': roadFriction,
      'trafficDensity': trafficDensity,
      'activeWarnings': activeWarnings,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SpeedControlData.fromJson(Map<String, dynamic> json) {
    return SpeedControlData(
      id: json['id'],
      busId: json['busId'],
      currentSpeed: json['currentSpeed'].toDouble(),
      recommendedSpeed: json['recommendedSpeed'].toDouble(),
      maxAllowedSpeed: json['maxAllowedSpeed'].toDouble(),
      brakingForce: json['brakingForce'].toDouble(),
      isAutoBrakingActive: json['isAutoBrakingActive'],
      isSpeedControlActive: json['isSpeedControlActive'],
      weatherCondition: json['weatherCondition'],
      roadCondition: json['roadCondition'],
      passengerCount: json['passengerCount'],
      isInSchoolZone: json['isInSchoolZone'],
      isInResidentialArea: json['isInResidentialArea'],
      isInHighway: json['isInHighway'],
      visibility: json['visibility'].toDouble(),
      roadFriction: json['roadFriction'].toDouble(),
      trafficDensity: json['trafficDensity'].toDouble(),
      activeWarnings: List<String>.from(json['activeWarnings']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Calculate safety score (0.0 to 1.0)
  double get safetyScore {
    double score = 1.0;
    
    // Speed factor
    if (currentSpeed > recommendedSpeed) {
      score -= (currentSpeed - recommendedSpeed) / recommendedSpeed * 0.3;
    }
    
    // Weather factor
    switch (weatherCondition) {
      case 'clear':
        break;
      case 'rain':
        score -= 0.1;
        break;
      case 'snow':
        score -= 0.2;
        break;
      case 'fog':
        score -= 0.15;
        break;
      case 'storm':
        score -= 0.25;
        break;
    }
    
    // Road condition factor
    switch (roadCondition) {
      case 'dry':
        break;
      case 'wet':
        score -= 0.1;
        break;
      case 'icy':
        score -= 0.3;
        break;
      case 'slippery':
        score -= 0.2;
        break;
      case 'construction':
        score -= 0.15;
        break;
    }
    
    // Visibility factor
    if (visibility < 50) {
      score -= 0.2;
    } else if (visibility < 100) {
      score -= 0.1;
    }
    
    // Traffic density factor
    score -= trafficDensity * 0.1;
    
    // School zone factor
    if (isInSchoolZone && currentSpeed > 30) {
      score -= 0.3;
    }
    
    return score.clamp(0.0, 1.0);
  }

  // Get critical warnings
  List<String> get criticalWarnings {
    List<String> warnings = [];
    
    if (currentSpeed > maxAllowedSpeed) {
      warnings.add('Speed Limit Exceeded');
    }
    
    if (weatherCondition == 'storm' && currentSpeed > 40) {
      warnings.add('High Speed in Storm');
    }
    
    if (roadCondition == 'icy' && currentSpeed > 30) {
      warnings.add('High Speed on Icy Road');
    }
    
    if (visibility < 50 && currentSpeed > 30) {
      warnings.add('Low Visibility - Reduce Speed');
    }
    
    if (isInSchoolZone && currentSpeed > 30) {
      warnings.add('School Zone Speed Limit');
    }
    
    if (passengerCount > 50 && currentSpeed > 60) {
      warnings.add('High Speed with Many Passengers');
    }
    
    return warnings;
  }

  // Check if emergency braking is needed
  bool get needsEmergencyBraking {
    return currentSpeed > maxAllowedSpeed * 1.5 ||
           (weatherCondition == 'storm' && currentSpeed > 50) ||
           (roadCondition == 'icy' && currentSpeed > 40) ||
           (visibility < 30 && currentSpeed > 40) ||
           (isInSchoolZone && currentSpeed > 40);
  }
}
