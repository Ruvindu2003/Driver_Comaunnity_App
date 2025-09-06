class LocationData {
  final String id;
  final String busId;
  final double latitude;
  final double longitude;
  final double speed; // km/h
  final double heading; // degrees
  final double accuracy; // meters
  final DateTime timestamp;
  final String? address;

  LocationData({
    required this.id,
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.accuracy,
    required this.timestamp,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busId': busId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id'],
      busId: json['busId'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      speed: json['speed'].toDouble(),
      heading: json['heading'].toDouble(),
      accuracy: json['accuracy'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      address: json['address'],
    );
  }

  LocationData copyWith({
    String? id,
    String? busId,
    double? latitude,
    double? longitude,
    double? speed,
    double? heading,
    double? accuracy,
    DateTime? timestamp,
    String? address,
  }) {
    return LocationData(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
    );
  }
}
