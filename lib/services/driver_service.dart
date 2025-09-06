import 'package:flutter/foundation.dart';
import '../models/driver.dart';

class DriverService extends ChangeNotifier {
  final List<Driver> _drivers = [];
  bool _isLoading = false;
  String? _error;

  List<Driver> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all drivers
  Future<List<Driver>> getAllDrivers() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for demonstration
      if (_drivers.isEmpty) {
        _drivers.addAll(_getMockDrivers());
      }
      
      _setError(null);
      return _drivers;
    } catch (e) {
      _setError('Failed to load drivers: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get driver by ID
  Driver? getDriverById(String id) {
    try {
      return _drivers.firstWhere((driver) => driver.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new driver
  Future<bool> addDriver(Driver driver) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _drivers.add(driver);
      notifyListeners();
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to add driver: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update driver
  Future<bool> updateDriver(Driver driver) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _drivers.indexWhere((d) => d.id == driver.id);
      if (index != -1) {
        _drivers[index] = driver;
        notifyListeners();
        _setError(null);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update driver: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete driver
  Future<bool> deleteDriver(String id) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _drivers.removeWhere((driver) => driver.id == id);
      notifyListeners();
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to delete driver: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search drivers
  List<Driver> searchDrivers(String query) {
    if (query.isEmpty) return _drivers;
    
    return _drivers.where((driver) {
      return driver.name.toLowerCase().contains(query.toLowerCase()) ||
             driver.email.toLowerCase().contains(query.toLowerCase()) ||
             driver.phone.contains(query) ||
             driver.licenseNumber.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get active drivers
  List<Driver> getActiveDrivers() {
    return _drivers.where((driver) => driver.isActive).toList();
  }

  // Get drivers with expiring licenses
  List<Driver> getDriversWithExpiringLicenses() {
    return _drivers.where((driver) => driver.isLicenseExpiringSoon).toList();
  }

  // Get drivers with expired licenses
  List<Driver> getDriversWithExpiredLicenses() {
    return _drivers.where((driver) => driver.isLicenseExpired).toList();
  }

  // Get drivers by route
  List<Driver> getDriversByRoute(String routeId) {
    return _drivers.where((driver) => driver.assignedRoutes.contains(routeId)).toList();
  }

  // Get top rated drivers
  List<Driver> getTopRatedDrivers({int limit = 5}) {
    final sortedDrivers = List<Driver>.from(_drivers);
    sortedDrivers.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedDrivers.take(limit).toList();
  }

  // Get driver statistics
  Map<String, dynamic> getDriverStatistics() {
    final activeDrivers = getActiveDrivers();
    final totalDrivers = _drivers.length;
    final expiringLicenses = getDriversWithExpiringLicenses().length;
    final expiredLicenses = getDriversWithExpiredLicenses().length;
    
    double averageRating = 0;
    if (activeDrivers.isNotEmpty) {
      averageRating = activeDrivers.map((d) => d.rating).reduce((a, b) => a + b) / activeDrivers.length;
    }
    
    int totalTrips = activeDrivers.map((d) => d.totalTrips).reduce((a, b) => a + b);
    
    return {
      'totalDrivers': totalDrivers,
      'activeDrivers': activeDrivers.length,
      'inactiveDrivers': totalDrivers - activeDrivers.length,
      'expiringLicenses': expiringLicenses,
      'expiredLicenses': expiredLicenses,
      'averageRating': averageRating,
      'totalTrips': totalTrips,
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
  List<Driver> _getMockDrivers() {
    final now = DateTime.now();
    return [
      Driver(
        id: '1',
        name: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1234567890',
        licenseNumber: 'DL123456789',
        licenseExpiry: now.add(const Duration(days: 90)),
        address: '123 Main St, City, State',
        emergencyContact: 'Jane Smith',
        emergencyPhone: '+1234567891',
        dateOfBirth: DateTime(1985, 5, 15),
        gender: 'Male',
        bloodGroup: 'O+',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        assignedRoutes: ['route1', 'route2'],
        rating: 4.5,
        totalTrips: 150,
        yearsOfExperience: 8,
      ),
      Driver(
        id: '2',
        name: 'Sarah Johnson',
        email: 'sarah.johnson@example.com',
        phone: '+1234567892',
        licenseNumber: 'DL987654321',
        licenseExpiry: now.add(const Duration(days: 15)),
        address: '456 Oak Ave, City, State',
        emergencyContact: 'Mike Johnson',
        emergencyPhone: '+1234567893',
        dateOfBirth: DateTime(1990, 8, 22),
        gender: 'Female',
        bloodGroup: 'A+',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
        assignedRoutes: ['route1'],
        rating: 4.8,
        totalTrips: 200,
        yearsOfExperience: 5,
      ),
      Driver(
        id: '3',
        name: 'Michael Brown',
        email: 'michael.brown@example.com',
        phone: '+1234567894',
        licenseNumber: 'DL456789123',
        licenseExpiry: now.subtract(const Duration(days: 5)),
        address: '789 Pine St, City, State',
        emergencyContact: 'Lisa Brown',
        emergencyPhone: '+1234567895',
        dateOfBirth: DateTime(1978, 12, 10),
        gender: 'Male',
        bloodGroup: 'B+',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
        assignedRoutes: ['route2', 'route3'],
        rating: 4.2,
        totalTrips: 300,
        yearsOfExperience: 12,
      ),
    ];
  }
}
