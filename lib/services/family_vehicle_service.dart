import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_vehicle.dart';

class FamilyVehicleService extends ChangeNotifier {
  static const String _vehiclesKey = 'family_vehicles';
  List<FamilyVehicle> _vehicles = [];

  List<FamilyVehicle> get vehicles => List.unmodifiable(_vehicles);

  Future<void> loadVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getStringList(_vehiclesKey) ?? [];
      
      _vehicles = vehiclesJson
          .map((json) => FamilyVehicle.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading vehicles: $e');
      _vehicles = [];
    }
  }

  Future<void> saveVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = _vehicles
          .map((vehicle) => jsonEncode(vehicle.toJson()))
          .toList();
      
      await prefs.setStringList(_vehiclesKey, vehiclesJson);
    } catch (e) {
      print('Error saving vehicles: $e');
    }
  }

  Future<void> addVehicle(FamilyVehicle vehicle) async {
    _vehicles.add(vehicle);
    await saveVehicles();
    notifyListeners();
  }

  Future<void> updateVehicle(FamilyVehicle vehicle) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      await saveVehicles();
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
    await saveVehicles();
    notifyListeners();
  }

  FamilyVehicle? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (e) {
      return null;
    }
  }

  List<FamilyVehicle> getActiveVehicles() {
    return _vehicles.where((vehicle) => vehicle.status == 'active').toList();
  }

  List<FamilyVehicle> getVehiclesNeedingService() {
    return _vehicles.where((vehicle) => vehicle.needsService).toList();
  }

  List<FamilyVehicle> getVehiclesWithExpiringInsurance() {
    return _vehicles.where((vehicle) => vehicle.insuranceExpiringSoon).toList();
  }

  List<FamilyVehicle> getVehiclesWithExpiringRegistration() {
    return _vehicles.where((vehicle) => vehicle.registrationExpiringSoon).toList();
  }

  Map<String, dynamic> getVehicleStatistics() {
    final activeVehicles = getActiveVehicles();
    final vehiclesNeedingService = getVehiclesNeedingService();
    final vehiclesWithExpiringInsurance = getVehiclesWithExpiringInsurance();
    final vehiclesWithExpiringRegistration = getVehiclesWithExpiringRegistration();

    return {
      'totalVehicles': _vehicles.length,
      'activeVehicles': activeVehicles.length,
      'vehiclesNeedingService': vehiclesNeedingService.length,
      'vehiclesWithExpiringInsurance': vehiclesWithExpiringInsurance.length,
      'vehiclesWithExpiringRegistration': vehiclesWithExpiringRegistration.length,
      'totalDistance': _vehicles.fold(0.0, (sum, vehicle) => sum + vehicle.totalDistance),
      'totalTrips': _vehicles.fold(0, (sum, vehicle) => sum + vehicle.totalTrips),
      'averageFuelConsumption': _vehicles.isNotEmpty 
          ? _vehicles.fold(0.0, (sum, vehicle) => sum + vehicle.averageFuelConsumption) / _vehicles.length
          : 0.0,
    };
  }

  Future<void> updateFuelLevel(String vehicleId, double newFuelLevel) async {
    final vehicle = getVehicleById(vehicleId);
    if (vehicle != null) {
      final updatedVehicle = vehicle.copyWith(currentFuelLevel: newFuelLevel);
      await updateVehicle(updatedVehicle);
    }
  }

  Future<void> updateOdometerReading(String vehicleId, int newOdometerReading) async {
    final vehicle = getVehicleById(vehicleId);
    if (vehicle != null) {
      final updatedVehicle = vehicle.copyWith(odometerReading: newOdometerReading);
      await updateVehicle(updatedVehicle);
    }
  }

  Future<void> addMaintenanceRecord(String vehicleId, Map<String, dynamic> maintenanceRecord) async {
    final vehicle = getVehicleById(vehicleId);
    if (vehicle != null) {
      final updatedHistory = Map<String, dynamic>.from(vehicle.maintenanceHistory);
      updatedHistory[DateTime.now().toIso8601String()] = maintenanceRecord;
      
      final updatedVehicle = vehicle.copyWith(
        maintenanceHistory: updatedHistory,
        lastServiceDate: DateTime.now(),
        nextServiceDate: DateTime.now().add(const Duration(days: 90)),
      );
      
      await updateVehicle(updatedVehicle);
    }
  }

  Future<void> initializeSampleData() async {
    if (_vehicles.isEmpty) {
      final sampleVehicles = [
        FamilyVehicle(
          id: '1',
          name: 'Family Car',
          make: 'Toyota',
          model: 'Camry',
          year: 2020,
          licensePlate: 'ABC-123',
          color: 'Silver',
          fuelType: 'Gasoline',
          fuelCapacity: 60.0,
          currentFuelLevel: 45.0,
          odometerReading: 45000,
          lastServiceDate: DateTime.now().subtract(const Duration(days: 30)),
          nextServiceDate: DateTime.now().add(const Duration(days: 60)),
          status: 'active',
          owner: 'John Smith',
          insuranceProvider: 'State Farm',
          insuranceExpiry: DateTime.now().add(const Duration(days: 120)),
          registrationNumber: 'REG-2020-001',
          registrationExpiry: DateTime.now().add(const Duration(days: 90)),
          features: ['GPS', 'Bluetooth', 'Backup Camera', 'Cruise Control'],
          maintenanceHistory: {
            '2024-01-15': {
              'type': 'Oil Change',
              'cost': 45.00,
              'mileage': 44000,
              'notes': 'Regular oil change and filter replacement'
            },
            '2024-02-20': {
              'type': 'Tire Rotation',
              'cost': 25.00,
              'mileage': 44500,
              'notes': 'Tire rotation and alignment check'
            }
          },
          averageFuelConsumption: 8.5,
          totalTrips: 150,
          totalDistance: 12000.0,
        ),
        FamilyVehicle(
          id: '2',
          name: 'Mom\'s SUV',
          make: 'Honda',
          model: 'CR-V',
          year: 2019,
          licensePlate: 'XYZ-789',
          color: 'White',
          fuelType: 'Gasoline',
          fuelCapacity: 55.0,
          currentFuelLevel: 20.0,
          odometerReading: 62000,
          lastServiceDate: DateTime.now().subtract(const Duration(days: 10)),
          nextServiceDate: DateTime.now().add(const Duration(days: 80)),
          status: 'active',
          owner: 'Sarah Smith',
          insuranceProvider: 'Geico',
          insuranceExpiry: DateTime.now().add(const Duration(days: 15)),
          registrationNumber: 'REG-2019-002',
          registrationExpiry: DateTime.now().add(const Duration(days: 45)),
          features: ['AWD', 'Sunroof', 'Heated Seats', 'Navigation'],
          maintenanceHistory: {
            '2024-03-01': {
              'type': 'Brake Service',
              'cost': 180.00,
              'mileage': 61500,
              'notes': 'Brake pad replacement and rotor resurfacing'
            }
          },
          averageFuelConsumption: 9.2,
          totalTrips: 200,
          totalDistance: 18000.0,
        ),
        FamilyVehicle(
          id: '3',
          name: 'Teen\'s Car',
          make: 'Nissan',
          model: 'Altima',
          year: 2018,
          licensePlate: 'DEF-456',
          color: 'Blue',
          fuelType: 'Gasoline',
          fuelCapacity: 50.0,
          currentFuelLevel: 35.0,
          odometerReading: 78000,
          lastServiceDate: DateTime.now().subtract(const Duration(days: 5)),
          nextServiceDate: DateTime.now().add(const Duration(days: 85)),
          status: 'maintenance',
          owner: 'Mike Smith',
          insuranceProvider: 'Progressive',
          insuranceExpiry: DateTime.now().add(const Duration(days: 200)),
          registrationNumber: 'REG-2018-003',
          registrationExpiry: DateTime.now().add(const Duration(days: 180)),
          features: ['Bluetooth', 'USB Ports', 'Lane Departure Warning'],
          maintenanceHistory: {
            '2024-03-10': {
              'type': 'Transmission Service',
              'cost': 350.00,
              'mileage': 77500,
              'notes': 'Transmission fluid change and inspection'
            }
          },
          averageFuelConsumption: 7.8,
          totalTrips: 120,
          totalDistance: 9500.0,
        ),
      ];

      for (final vehicle in sampleVehicles) {
        await addVehicle(vehicle);
      }
    }
  }
}
