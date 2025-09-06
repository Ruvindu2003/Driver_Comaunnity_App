class BusRoute {
  final String id;
  final String routeNumber;
  final String routeName;
  final String startLocation;
  final String endLocation;
  final List<RouteStop> stops;
  final double totalDistance;
  final int estimatedDuration; // in minutes
  final String status; // 'active', 'inactive', 'maintenance'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> schedule; // Daily schedule
  final double baseFare;
  final String description;

  BusRoute({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.startLocation,
    required this.endLocation,
    required this.stops,
    required this.totalDistance,
    required this.estimatedDuration,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.schedule = const {},
    this.baseFare = 0.0,
    this.description = '',
  });

  BusRoute copyWith({
    String? id,
    String? routeNumber,
    String? routeName,
    String? startLocation,
    String? endLocation,
    List<RouteStop>? stops,
    double? totalDistance,
    int? estimatedDuration,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? schedule,
    double? baseFare,
    String? description,
  }) {
    return BusRoute(
      id: id ?? this.id,
      routeNumber: routeNumber ?? this.routeNumber,
      routeName: routeName ?? this.routeName,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      stops: stops ?? this.stops,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schedule: schedule ?? this.schedule,
      baseFare: baseFare ?? this.baseFare,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeNumber': routeNumber,
      'routeName': routeName,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'totalDistance': totalDistance,
      'estimatedDuration': estimatedDuration,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'schedule': schedule,
      'baseFare': baseFare,
      'description': description,
    };
  }

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['id'] ?? '',
      routeNumber: json['routeNumber'] ?? '',
      routeName: json['routeName'] ?? '',
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      stops: (json['stops'] as List<dynamic>?)
          ?.map((stop) => RouteStop.fromJson(stop))
          .toList() ?? [],
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      schedule: Map<String, dynamic>.from(json['schedule'] ?? {}),
      baseFare: (json['baseFare'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isInMaintenance => status == 'maintenance';
}

class RouteStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int sequence;
  final double fareFromStart;
  final int estimatedArrivalTime; // minutes from start
  final String description;
  final bool isTerminal;

  RouteStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    required this.fareFromStart,
    required this.estimatedArrivalTime,
    this.description = '',
    this.isTerminal = false,
  });

  RouteStop copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    int? sequence,
    double? fareFromStart,
    int? estimatedArrivalTime,
    String? description,
    bool? isTerminal,
  }) {
    return RouteStop(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sequence: sequence ?? this.sequence,
      fareFromStart: fareFromStart ?? this.fareFromStart,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      description: description ?? this.description,
      isTerminal: isTerminal ?? this.isTerminal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
      'fareFromStart': fareFromStart,
      'estimatedArrivalTime': estimatedArrivalTime,
      'description': description,
      'isTerminal': isTerminal,
    };
  }

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      sequence: json['sequence'] ?? 0,
      fareFromStart: (json['fareFromStart'] ?? 0.0).toDouble(),
      estimatedArrivalTime: json['estimatedArrivalTime'] ?? 0,
      description: json['description'] ?? '',
      isTerminal: json['isTerminal'] ?? false,
    );
  }
}
