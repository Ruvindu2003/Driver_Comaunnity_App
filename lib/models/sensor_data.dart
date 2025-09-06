class SensorData {
  final String id;
  final String busId;
  final double engineTemperature; // Celsius
  final double fuelLevel; // Percentage
  final double batteryVoltage; // Volts
  final double tirePressure; // PSI
  final double brakePadWear; // Percentage
  final double engineOilLevel; // Percentage
  final double coolantLevel; // Percentage
  final bool doorOpen;
  final bool emergencyBrake;
  final bool seatbeltWarning;
  final bool airbagStatus;
  final DateTime timestamp;

  SensorData({
    required this.id,
    required this.busId,
    required this.engineTemperature,
    required this.fuelLevel,
    required this.batteryVoltage,
    required this.tirePressure,
    required this.brakePadWear,
    required this.engineOilLevel,
    required this.coolantLevel,
    required this.doorOpen,
    required this.emergencyBrake,
    required this.seatbeltWarning,
    required this.airbagStatus,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busId': busId,
      'engineTemperature': engineTemperature,
      'fuelLevel': fuelLevel,
      'batteryVoltage': batteryVoltage,
      'tirePressure': tirePressure,
      'brakePadWear': brakePadWear,
      'engineOilLevel': engineOilLevel,
      'coolantLevel': coolantLevel,
      'doorOpen': doorOpen,
      'emergencyBrake': emergencyBrake,
      'seatbeltWarning': seatbeltWarning,
      'airbagStatus': airbagStatus,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'],
      busId: json['busId'],
      engineTemperature: json['engineTemperature'].toDouble(),
      fuelLevel: json['fuelLevel'].toDouble(),
      batteryVoltage: json['batteryVoltage'].toDouble(),
      tirePressure: json['tirePressure'].toDouble(),
      brakePadWear: json['brakePadWear'].toDouble(),
      engineOilLevel: json['engineOilLevel'].toDouble(),
      coolantLevel: json['coolantLevel'].toDouble(),
      doorOpen: json['doorOpen'],
      emergencyBrake: json['emergencyBrake'],
      seatbeltWarning: json['seatbeltWarning'],
      airbagStatus: json['airbagStatus'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Health status based on sensor readings
  String get healthStatus {
    if (engineTemperature > 100 || fuelLevel < 10 || batteryVoltage < 11 || 
        tirePressure < 25 || brakePadWear > 80) {
      return 'Critical';
    } else if (engineTemperature > 90 || fuelLevel < 20 || batteryVoltage < 12 || 
               tirePressure < 30 || brakePadWear > 60) {
      return 'Warning';
    } else {
      return 'Good';
    }
  }

  // Get critical alerts
  List<String> get criticalAlerts {
    List<String> alerts = [];
    
    if (engineTemperature > 100) alerts.add('Engine Overheating');
    if (fuelLevel < 10) alerts.add('Low Fuel');
    if (batteryVoltage < 11) alerts.add('Low Battery');
    if (tirePressure < 25) alerts.add('Low Tire Pressure');
    if (brakePadWear > 80) alerts.add('Brake Pads Need Replacement');
    if (doorOpen) alerts.add('Door Open');
    if (emergencyBrake) alerts.add('Emergency Brake Engaged');
    if (seatbeltWarning) alerts.add('Seatbelt Warning');
    
    return alerts;
  }
}
