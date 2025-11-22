class Route {
  final String id;
  final String routeName;
  final String routeNumber;
  final String startLocation;
  final String endLocation;
  final List<RouteStop> stops;
  final double totalDistance;
  final int estimatedDuration; // in minutes
  final double fare;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? image;
  final List<String> assignedBusIds;
  final Map<String, dynamic> schedule; // day-wise schedule
  final String routeType; // 'local', 'express', 'intercity'
  final int frequency; // trips per day
  final String operatingHours; // e.g., "06:00-22:00"
  final Map<String, dynamic> routeData; // for map coordinates

  Route({
    required this.id,
    required this.routeName,
    required this.routeNumber,
    required this.startLocation,
    required this.endLocation,
    required this.stops,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.fare,
    required this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.image,
    this.assignedBusIds = const [],
    this.schedule = const {},
    this.routeType = 'local',
    this.frequency = 1,
    this.operatingHours = '06:00-22:00',
    this.routeData = const {},
  });

  Route copyWith({
    String? id,
    String? routeName,
    String? routeNumber,
    String? startLocation,
    String? endLocation,
    List<RouteStop>? stops,
    double? totalDistance,
    int? estimatedDuration,
    double? fare,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? image,
    List<String>? assignedBusIds,
    Map<String, dynamic>? schedule,
    String? routeType,
    int? frequency,
    String? operatingHours,
    Map<String, dynamic>? routeData,
  }) {
    return Route(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      routeNumber: routeNumber ?? this.routeNumber,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      stops: stops ?? this.stops,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      fare: fare ?? this.fare,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      image: image ?? this.image,
      assignedBusIds: assignedBusIds ?? this.assignedBusIds,
      schedule: schedule ?? this.schedule,
      routeType: routeType ?? this.routeType,
      frequency: frequency ?? this.frequency,
      operatingHours: operatingHours ?? this.operatingHours,
      routeData: routeData ?? this.routeData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeName': routeName,
      'routeNumber': routeNumber,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'totalDistance': totalDistance,
      'estimatedDuration': estimatedDuration,
      'fare': fare,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'image': image,
      'assignedBusIds': assignedBusIds,
      'schedule': schedule,
      'routeType': routeType,
      'frequency': frequency,
      'operatingHours': operatingHours,
      'routeData': routeData,
    };
  }

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'] ?? '',
      routeName: json['routeName'] ?? '',
      routeNumber: json['routeNumber'] ?? '',
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      stops: (json['stops'] as List<dynamic>?)
          ?.map((stop) => RouteStop.fromJson(stop))
          .toList() ?? [],
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      fare: (json['fare'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      image: json['image'],
      assignedBusIds: List<String>.from(json['assignedBusIds'] ?? []),
      schedule: Map<String, dynamic>.from(json['schedule'] ?? {}),
      routeType: json['routeType'] ?? 'local',
      frequency: json['frequency'] ?? 1,
      operatingHours: json['operatingHours'] ?? '06:00-22:00',
      routeData: Map<String, dynamic>.from(json['routeData'] ?? {}),
    );
  }

  String get routeDisplayName {
    return '$routeNumber - $routeName';
  }

  String get fullRoute {
    return '$startLocation → $endLocation';
  }

  int get totalStops {
    return stops.length;
  }

  String get durationText {
    final hours = estimatedDuration ~/ 60;
    final minutes = estimatedDuration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get distanceText {
    if (totalDistance < 1) {
      return '${(totalDistance * 1000).round()}m';
    }
    return '${totalDistance.toStringAsFixed(1)}km';
  }
}

class RouteStop {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int sequence;
  final int estimatedArrivalTime; // minutes from start
  final bool isActive;
  final String? description;
  final Map<String, dynamic> facilities; // e.g., {'shelter': true, 'bench': true}

  RouteStop({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    required this.estimatedArrivalTime,
    this.isActive = true,
    this.description,
    this.facilities = const {},
  });

  RouteStop copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? sequence,
    int? estimatedArrivalTime,
    bool? isActive,
    String? description,
    Map<String, dynamic>? facilities,
  }) {
    return RouteStop(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sequence: sequence ?? this.sequence,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
      'estimatedArrivalTime': estimatedArrivalTime,
      'isActive': isActive,
      'description': description,
      'facilities': facilities,
    };
  }

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      sequence: json['sequence'] ?? 0,
      estimatedArrivalTime: json['estimatedArrivalTime'] ?? 0,
      isActive: json['isActive'] ?? true,
      description: json['description'],
      facilities: Map<String, dynamic>.from(json['facilities'] ?? {}),
    );
  }

  String get arrivalTimeText {
    final hours = estimatedArrivalTime ~/ 60;
    final minutes = estimatedArrivalTime % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
