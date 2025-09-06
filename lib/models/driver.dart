class Driver {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String address;
  final String emergencyContact;
  final String emergencyPhone;
  final DateTime dateOfBirth;
  final String gender;
  final String bloodGroup;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImage;
  final List<String> assignedRoutes;
  final double rating;
  final int totalTrips;
  final int yearsOfExperience;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.address,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.profileImage,
    this.assignedRoutes = const [],
    this.rating = 0.0,
    this.totalTrips = 0,
    this.yearsOfExperience = 0,
  });

  Driver copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImage,
    List<String>? assignedRoutes,
    double? rating,
    int? totalTrips,
    int? yearsOfExperience,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImage: profileImage ?? this.profileImage,
      assignedRoutes: assignedRoutes ?? this.assignedRoutes,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry.toIso8601String(),
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profileImage': profileImage,
      'assignedRoutes': assignedRoutes,
      'rating': rating,
      'totalTrips': totalTrips,
      'yearsOfExperience': yearsOfExperience,
    };
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      licenseExpiry: DateTime.parse(json['licenseExpiry']),
      address: json['address'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      emergencyPhone: json['emergencyPhone'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profileImage: json['profileImage'],
      assignedRoutes: List<String>.from(json['assignedRoutes'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalTrips: json['totalTrips'] ?? 0,
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
    );
  }

  bool get isLicenseExpired {
    return DateTime.now().isAfter(licenseExpiry);
  }

  bool get isLicenseExpiringSoon {
    final daysUntilExpiry = licenseExpiry.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  String get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age.toString();
  }
}
