class Schedule {
  final String id;
  final String routeId;
  final String busId;
  final String driverId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String status; // 'scheduled', 'in_progress', 'completed', 'cancelled', 'delayed'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final Map<String, dynamic> actualTimings; // actual departure/arrival times
  final int passengerCount;
  final double fuelConsumed;
  final double distanceCovered;
  final Map<String, dynamic> weatherConditions;
  final List<String> incidents; // incident reports
  final bool isRecurring;
  final String recurringPattern; // 'daily', 'weekly', 'monthly'
  final List<String> recurringDays; // ['monday', 'tuesday', ...]
  final DateTime? recurringEndDate;

  Schedule({
    required this.id,
    required this.routeId,
    required this.busId,
    required this.driverId,
    required this.departureTime,
    required this.arrivalTime,
    this.status = 'scheduled',
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.actualTimings = const {},
    this.passengerCount = 0,
    this.fuelConsumed = 0.0,
    this.distanceCovered = 0.0,
    this.weatherConditions = const {},
    this.incidents = const [],
    this.isRecurring = false,
    this.recurringPattern = 'daily',
    this.recurringDays = const [],
    this.recurringEndDate,
  });

  Schedule copyWith({
    String? id,
    String? routeId,
    String? busId,
    String? driverId,
    DateTime? departureTime,
    DateTime? arrivalTime,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    Map<String, dynamic>? actualTimings,
    int? passengerCount,
    double? fuelConsumed,
    double? distanceCovered,
    Map<String, dynamic>? weatherConditions,
    List<String>? incidents,
    bool? isRecurring,
    String? recurringPattern,
    List<String>? recurringDays,
    DateTime? recurringEndDate,
  }) {
    return Schedule(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      busId: busId ?? this.busId,
      driverId: driverId ?? this.driverId,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      actualTimings: actualTimings ?? this.actualTimings,
      passengerCount: passengerCount ?? this.passengerCount,
      fuelConsumed: fuelConsumed ?? this.fuelConsumed,
      distanceCovered: distanceCovered ?? this.distanceCovered,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      incidents: incidents ?? this.incidents,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      recurringDays: recurringDays ?? this.recurringDays,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'busId': busId,
      'driverId': driverId,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'actualTimings': actualTimings,
      'passengerCount': passengerCount,
      'fuelConsumed': fuelConsumed,
      'distanceCovered': distanceCovered,
      'weatherConditions': weatherConditions,
      'incidents': incidents,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'recurringDays': recurringDays,
      'recurringEndDate': recurringEndDate?.toIso8601String(),
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? '',
      routeId: json['routeId'] ?? '',
      busId: json['busId'] ?? '',
      driverId: json['driverId'] ?? '',
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      status: json['status'] ?? 'scheduled',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      notes: json['notes'],
      actualTimings: Map<String, dynamic>.from(json['actualTimings'] ?? {}),
      passengerCount: json['passengerCount'] ?? 0,
      fuelConsumed: (json['fuelConsumed'] ?? 0.0).toDouble(),
      distanceCovered: (json['distanceCovered'] ?? 0.0).toDouble(),
      weatherConditions: Map<String, dynamic>.from(json['weatherConditions'] ?? {}),
      incidents: List<String>.from(json['incidents'] ?? []),
      isRecurring: json['isRecurring'] ?? false,
      recurringPattern: json['recurringPattern'] ?? 'daily',
      recurringDays: List<String>.from(json['recurringDays'] ?? []),
      recurringEndDate: json['recurringEndDate'] != null 
          ? DateTime.parse(json['recurringEndDate']) 
          : null,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return departureTime.year == now.year &&
           departureTime.month == now.month &&
           departureTime.day == now.day;
  }

  bool get isUpcoming {
    return departureTime.isAfter(DateTime.now()) && status == 'scheduled';
  }

  bool get isInProgress {
    return status == 'in_progress';
  }

  bool get isCompleted {
    return status == 'completed';
  }

  bool get isCancelled {
    return status == 'cancelled';
  }

  bool get isDelayed {
    return status == 'delayed';
  }

  Duration get duration {
    return arrivalTime.difference(departureTime);
  }

  String get durationText {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get departureTimeText {
    return '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}';
  }

  String get arrivalTimeText {
    return '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }

  String get dateText {
    return '${departureTime.day}/${departureTime.month}/${departureTime.year}';
  }

  String get dayOfWeek {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[departureTime.weekday - 1];
  }

  bool get hasActualTimings {
    return actualTimings.isNotEmpty;
  }

  DateTime? get actualDepartureTime {
    final departure = actualTimings['departure'];
    return departure != null ? DateTime.parse(departure) : null;
  }

  DateTime? get actualArrivalTime {
    final arrival = actualTimings['arrival'];
    return arrival != null ? DateTime.parse(arrival) : null;
  }

  Duration? get actualDuration {
    final actualDeparture = actualDepartureTime;
    final actualArrival = actualArrivalTime;
    if (actualDeparture != null && actualArrival != null) {
      return actualArrival.difference(actualDeparture);
    }
    return null;
  }

  double get efficiency {
    if (actualDuration != null) {
      final plannedDuration = duration.inMinutes;
      final actualDurationMinutes = actualDuration!.inMinutes;
      return (plannedDuration / actualDurationMinutes * 100).clamp(0, 200);
    }
    return 100.0;
  }
}
