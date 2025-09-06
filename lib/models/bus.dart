class Bus {
  final String id;
  final String busNumber;
  final String registrationNumber;
  final String model;
  final String manufacturer;
  final int year;
  final int capacity;
  final String color;
  final String fuelType;
  final double mileage;
  final DateTime lastServiceDate;
  final DateTime nextServiceDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? image;
  final String assignedDriverId;
  final String assignedRouteId;
  final double currentLatitude;
  final double currentLongitude;
  final String status; // 'available', 'in_use', 'maintenance', 'out_of_service'
  final int totalTrips;
  final double totalDistance;
  final Map<String, dynamic> maintenanceHistory;

  Bus({
    required this.id,
    required this.busNumber,
    required this.registrationNumber,
    required this.model,
    required this.manufacturer,
    required this.year,
    required this.capacity,
    required this.color,
    required this.fuelType,
    required this.mileage,
    required this.lastServiceDate,
    required this.nextServiceDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.image,
    this.assignedDriverId = '',
    this.assignedRouteId = '',
    this.currentLatitude = 0.0,
    this.currentLongitude = 0.0,
    this.status = 'available',
    this.totalTrips = 0,
    this.totalDistance = 0.0,
    this.maintenanceHistory = const {},
  });

  Bus copyWith({
    String? id,
    String? busNumber,
    String? registrationNumber,
    String? model,
    String? manufacturer,
    int? year,
    int? capacity,
    String? color,
    String? fuelType,
    double? mileage,
    DateTime? lastServiceDate,
    DateTime? nextServiceDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? image,
    String? assignedDriverId,
    String? assignedRouteId,
    double? currentLatitude,
    double? currentLongitude,
    String? status,
    int? totalTrips,
    double? totalDistance,
    Map<String, dynamic>? maintenanceHistory,
  }) {
    return Bus(
      id: id ?? this.id,
      busNumber: busNumber ?? this.busNumber,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      year: year ?? this.year,
      capacity: capacity ?? this.capacity,
      color: color ?? this.color,
      fuelType: fuelType ?? this.fuelType,
      mileage: mileage ?? this.mileage,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      image: image ?? this.image,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      assignedRouteId: assignedRouteId ?? this.assignedRouteId,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      status: status ?? this.status,
      totalTrips: totalTrips ?? this.totalTrips,
      totalDistance: totalDistance ?? this.totalDistance,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busNumber': busNumber,
      'registrationNumber': registrationNumber,
      'model': model,
      'manufacturer': manufacturer,
      'year': year,
      'capacity': capacity,
      'color': color,
      'fuelType': fuelType,
      'mileage': mileage,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'nextServiceDate': nextServiceDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'image': image,
      'assignedDriverId': assignedDriverId,
      'assignedRouteId': assignedRouteId,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'status': status,
      'totalTrips': totalTrips,
      'totalDistance': totalDistance,
      'maintenanceHistory': maintenanceHistory,
    };
  }

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'] ?? '',
      busNumber: json['busNumber'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      model: json['model'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      year: json['year'] ?? 0,
      capacity: json['capacity'] ?? 0,
      color: json['color'] ?? '',
      fuelType: json['fuelType'] ?? '',
      mileage: (json['mileage'] ?? 0.0).toDouble(),
      lastServiceDate: DateTime.parse(json['lastServiceDate']),
      nextServiceDate: DateTime.parse(json['nextServiceDate']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      image: json['image'],
      assignedDriverId: json['assignedDriverId'] ?? '',
      assignedRouteId: json['assignedRouteId'] ?? '',
      currentLatitude: (json['currentLatitude'] ?? 0.0).toDouble(),
      currentLongitude: (json['currentLongitude'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'available',
      totalTrips: json['totalTrips'] ?? 0,
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      maintenanceHistory: Map<String, dynamic>.from(json['maintenanceHistory'] ?? {}),
    );
  }

  bool get needsService {
    return DateTime.now().isAfter(nextServiceDate);
  }

  bool get isServiceDueSoon {
    final daysUntilService = nextServiceDate.difference(DateTime.now()).inDays;
    return daysUntilService <= 7 && daysUntilService > 0;
  }

  String get age {
    return (DateTime.now().year - year).toString();
  }

  bool get isAvailable {
    return status == 'available' && isActive;
  }

  bool get isInUse {
    return status == 'in_use';
  }

  bool get isInMaintenance {
    return status == 'maintenance';
  }
}
