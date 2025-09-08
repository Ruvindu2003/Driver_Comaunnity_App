class FamilyVehicle {
  final String id;
  final String name;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String color;
  final String fuelType;
  final double fuelCapacity;
  final double currentFuelLevel;
  final int odometerReading;
  final DateTime lastServiceDate;
  final DateTime nextServiceDate;
  final String status; // 'active', 'maintenance', 'inactive'
  final String owner;
  final String insuranceProvider;
  final DateTime insuranceExpiry;
  final String registrationNumber;
  final DateTime registrationExpiry;
  final List<String> features;
  final Map<String, dynamic> maintenanceHistory;
  final double averageFuelConsumption;
  final int totalTrips;
  final double totalDistance;

  FamilyVehicle({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    required this.fuelType,
    required this.fuelCapacity,
    required this.currentFuelLevel,
    required this.odometerReading,
    required this.lastServiceDate,
    required this.nextServiceDate,
    required this.status,
    required this.owner,
    required this.insuranceProvider,
    required this.insuranceExpiry,
    required this.registrationNumber,
    required this.registrationExpiry,
    required this.features,
    required this.maintenanceHistory,
    required this.averageFuelConsumption,
    required this.totalTrips,
    required this.totalDistance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'color': color,
      'fuelType': fuelType,
      'fuelCapacity': fuelCapacity,
      'currentFuelLevel': currentFuelLevel,
      'odometerReading': odometerReading,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'nextServiceDate': nextServiceDate.toIso8601String(),
      'status': status,
      'owner': owner,
      'insuranceProvider': insuranceProvider,
      'insuranceExpiry': insuranceExpiry.toIso8601String(),
      'registrationNumber': registrationNumber,
      'registrationExpiry': registrationExpiry.toIso8601String(),
      'features': features,
      'maintenanceHistory': maintenanceHistory,
      'averageFuelConsumption': averageFuelConsumption,
      'totalTrips': totalTrips,
      'totalDistance': totalDistance,
    };
  }

  factory FamilyVehicle.fromJson(Map<String, dynamic> json) {
    return FamilyVehicle(
      id: json['id'],
      name: json['name'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['licensePlate'],
      color: json['color'],
      fuelType: json['fuelType'],
      fuelCapacity: json['fuelCapacity'].toDouble(),
      currentFuelLevel: json['currentFuelLevel'].toDouble(),
      odometerReading: json['odometerReading'],
      lastServiceDate: DateTime.parse(json['lastServiceDate']),
      nextServiceDate: DateTime.parse(json['nextServiceDate']),
      status: json['status'],
      owner: json['owner'],
      insuranceProvider: json['insuranceProvider'],
      insuranceExpiry: DateTime.parse(json['insuranceExpiry']),
      registrationNumber: json['registrationNumber'],
      registrationExpiry: DateTime.parse(json['registrationExpiry']),
      features: List<String>.from(json['features']),
      maintenanceHistory: Map<String, dynamic>.from(json['maintenanceHistory']),
      averageFuelConsumption: json['averageFuelConsumption'].toDouble(),
      totalTrips: json['totalTrips'],
      totalDistance: json['totalDistance'].toDouble(),
    );
  }

  FamilyVehicle copyWith({
    String? id,
    String? name,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? color,
    String? fuelType,
    double? fuelCapacity,
    double? currentFuelLevel,
    int? odometerReading,
    DateTime? lastServiceDate,
    DateTime? nextServiceDate,
    String? status,
    String? owner,
    String? insuranceProvider,
    DateTime? insuranceExpiry,
    String? registrationNumber,
    DateTime? registrationExpiry,
    List<String>? features,
    Map<String, dynamic>? maintenanceHistory,
    double? averageFuelConsumption,
    int? totalTrips,
    double? totalDistance,
  }) {
    return FamilyVehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      fuelType: fuelType ?? this.fuelType,
      fuelCapacity: fuelCapacity ?? this.fuelCapacity,
      currentFuelLevel: currentFuelLevel ?? this.currentFuelLevel,
      odometerReading: odometerReading ?? this.odometerReading,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationExpiry: registrationExpiry ?? this.registrationExpiry,
      features: features ?? this.features,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
      averageFuelConsumption: averageFuelConsumption ?? this.averageFuelConsumption,
      totalTrips: totalTrips ?? this.totalTrips,
      totalDistance: totalDistance ?? this.totalDistance,
    );
  }

  double get fuelPercentage => (currentFuelLevel / fuelCapacity) * 100;
  
  bool get needsService => DateTime.now().isAfter(nextServiceDate);
  
  bool get insuranceExpiringSoon => 
      DateTime.now().add(const Duration(days: 30)).isAfter(insuranceExpiry);
  
  bool get registrationExpiringSoon => 
      DateTime.now().add(const Duration(days: 30)).isAfter(registrationExpiry);
  
  String get fullName => '$year $make $model';
  
  String get statusDisplayName {
    switch (status) {
      case 'active':
        return 'Active';
      case 'maintenance':
        return 'In Maintenance';
      case 'inactive':
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }
}
