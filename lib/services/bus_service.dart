import 'package:flutter/foundation.dart';
import '../models/bus.dart';

class BusService extends ChangeNotifier {
  final List<Bus> _buses = [];
  bool _isLoading = false;
  String? _error;

  List<Bus> get buses => _buses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all buses
  Future<List<Bus>> getAllBuses() async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (_buses.isEmpty) {
        _buses.addAll(_getMockBuses());
      }
      
      _setError(null);
      return _buses;
    } catch (e) {
      _setError('Failed to load buses: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get bus by ID
  Bus? getBusById(String id) {
    try {
      return _buses.firstWhere((bus) => bus.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new bus
  Future<bool> addBus(Bus bus) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _buses.add(bus);
      notifyListeners();
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to add bus: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update bus
  Future<bool> updateBus(Bus bus) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _buses.indexWhere((b) => b.id == bus.id);
      if (index != -1) {
        _buses[index] = bus;
        notifyListeners();
        _setError(null);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update bus: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete bus
  Future<bool> deleteBus(String id) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _buses.removeWhere((bus) => bus.id == id);
      notifyListeners();
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to delete bus: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search buses
  List<Bus> searchBuses(String query) {
    if (query.isEmpty) return _buses;
    
    return _buses.where((bus) {
      return bus.busNumber.toLowerCase().contains(query.toLowerCase()) ||
             bus.registrationNumber.toLowerCase().contains(query.toLowerCase()) ||
             bus.model.toLowerCase().contains(query.toLowerCase()) ||
             bus.manufacturer.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get available buses
  List<Bus> getAvailableBuses() {
    return _buses.where((bus) => bus.isAvailable).toList();
  }

  // Get buses in use
  List<Bus> getBusesInUse() {
    return _buses.where((bus) => bus.isInUse).toList();
  }

  // Get buses in maintenance
  List<Bus> getBusesInMaintenance() {
    return _buses.where((bus) => bus.isInMaintenance).toList();
  }

  // Get buses needing service
  List<Bus> getBusesNeedingService() {
    return _buses.where((bus) => bus.needsService).toList();
  }

  // Get buses with service due soon
  List<Bus> getBusesWithServiceDueSoon() {
    return _buses.where((bus) => bus.isServiceDueSoon).toList();
  }

  // Get buses by route
  List<Bus> getBusesByRoute(String routeId) {
    return _buses.where((bus) => bus.assignedRouteId == routeId).toList();
  }

  // Get buses by driver
  List<Bus> getBusesByDriver(String driverId) {
    return _buses.where((bus) => bus.assignedDriverId == driverId).toList();
  }

  // Update bus location
  Future<bool> updateBusLocation(String busId, double latitude, double longitude) async {
    try {
      final bus = getBusById(busId);
      if (bus != null) {
        final updatedBus = bus.copyWith(
          currentLatitude: latitude,
          currentLongitude: longitude,
          updatedAt: DateTime.now(),
        );
        return await updateBus(updatedBus);
      }
      return false;
    } catch (e) {
      _setError('Failed to update bus location: $e');
      return false;
    }
  }

  // Update bus status
  Future<bool> updateBusStatus(String busId, String status) async {
    try {
      final bus = getBusById(busId);
      if (bus != null) {
        final updatedBus = bus.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        return await updateBus(updatedBus);
      }
      return false;
    } catch (e) {
      _setError('Failed to update bus status: $e');
      return false;
    }
  }

  // Assign driver to bus
  Future<bool> assignDriverToBus(String busId, String driverId) async {
    try {
      final bus = getBusById(busId);
      if (bus != null) {
        final updatedBus = bus.copyWith(
          assignedDriverId: driverId,
          updatedAt: DateTime.now(),
        );
        return await updateBus(updatedBus);
      }
      return false;
    } catch (e) {
      _setError('Failed to assign driver to bus: $e');
      return false;
    }
  }

  // Assign route to bus
  Future<bool> assignRouteToBus(String busId, String routeId) async {
    try {
      final bus = getBusById(busId);
      if (bus != null) {
        final updatedBus = bus.copyWith(
          assignedRouteId: routeId,
          updatedAt: DateTime.now(),
        );
        return await updateBus(updatedBus);
      }
      return false;
    } catch (e) {
      _setError('Failed to assign route to bus: $e');
      return false;
    }
  }

  // Get bus statistics
  Map<String, dynamic> getBusStatistics() {
    final totalBuses = _buses.length;
    final availableBuses = getAvailableBuses().length;
    final inUseBuses = getBusesInUse().length;
    final maintenanceBuses = getBusesInMaintenance().length;
    final serviceDueBuses = getBusesNeedingService().length;
    
    double averageMileage = 0;
    if (_buses.isNotEmpty) {
      averageMileage = _buses.map((b) => b.mileage).reduce((a, b) => a + b) / _buses.length;
    }
    
    int totalTrips = _buses.map((b) => b.totalTrips).reduce((a, b) => a + b);
    double totalDistance = _buses.map((b) => b.totalDistance).reduce((a, b) => a + b);
    
    return {
      'totalBuses': totalBuses,
      'availableBuses': availableBuses,
      'inUseBuses': inUseBuses,
      'maintenanceBuses': maintenanceBuses,
      'serviceDueBuses': serviceDueBuses,
      'averageMileage': averageMileage,
      'totalTrips': totalTrips,
      'totalDistance': totalDistance,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Mock data for demonstration
  List<Bus> _getMockBuses() {
    final now = DateTime.now();
    return [
      Bus(
        id: '1',
        busNumber: 'B001',
        registrationNumber: 'ABC123',
        model: 'Volvo B7R',
        manufacturer: 'Volvo',
        year: 2020,
        capacity: 50,
        color: 'Blue',
        fuelType: 'Diesel',
        mileage: 15000.5,
        lastServiceDate: now.subtract(const Duration(days: 30)),
        nextServiceDate: now.add(const Duration(days: 15)),
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
        assignedDriverId: '1',
        assignedRouteId: 'route1',
        currentLatitude: 40.7128,
        currentLongitude: -74.0060,
        status: 'in_use',
        totalTrips: 250,
        totalDistance: 15000.5,
      ),
      Bus(
        id: '2',
        busNumber: 'B002',
        registrationNumber: 'XYZ789',
        model: 'Scania K270',
        manufacturer: 'Scania',
        year: 2019,
        capacity: 45,
        color: 'Red',
        fuelType: 'Diesel',
        mileage: 12000.0,
        lastServiceDate: now.subtract(const Duration(days: 60)),
        nextServiceDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 400)),
        updatedAt: now,
        assignedDriverId: '2',
        assignedRouteId: 'route2',
        currentLatitude: 40.7589,
        currentLongitude: -73.9851,
        status: 'available',
        totalTrips: 180,
        totalDistance: 12000.0,
      ),
      Bus(
        id: '3',
        busNumber: 'B003',
        registrationNumber: 'DEF456',
        model: 'Mercedes Citaro',
        manufacturer: 'Mercedes-Benz',
        year: 2021,
        capacity: 55,
        color: 'Green',
        fuelType: 'Diesel',
        mileage: 8000.0,
        lastServiceDate: now.subtract(const Duration(days: 15)),
        nextServiceDate: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
        assignedDriverId: '3',
        assignedRouteId: 'route3',
        currentLatitude: 40.6892,
        currentLongitude: -74.0445,
        status: 'maintenance',
        totalTrips: 100,
        totalDistance: 8000.0,
      ),
    ];
  }
}
