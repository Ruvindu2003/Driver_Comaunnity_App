import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_data.dart';

class LocationService extends ChangeNotifier {
  StreamSubscription<Position>? _positionStream;
  final List<LocationData> _locationHistory = [];
  LocationData? _currentLocation;
  bool _isTracking = false;
  String? _error;

  List<LocationData> get locationHistory => List.unmodifiable(_locationHistory);
  LocationData? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;
  String? get error => _error;

  // Request location permission
  Future<bool> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permission denied';
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permission permanently denied';
        notifyListeners();
        return false;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error requesting permission: $e';
      notifyListeners();
      return false;
    }
  }

  // Start real-time location tracking
  Future<void> startTracking(String busId) async {
    if (_isTracking) return;

    bool hasPermission = await requestPermission();
    if (!hasPermission) return;

    try {
      _isTracking = true;
      _error = null;
      notifyListeners();

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          await _updateLocation(busId, position);
        },
        onError: (error) {
          _error = 'Location tracking error: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Error starting location tracking: $e';
      _isTracking = false;
      notifyListeners();
    }
  }

  // Stop location tracking
  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    notifyListeners();
  }

  // Update location data
  Future<void> _updateLocation(String busId, Position position) async {
    try {
      // Get address from coordinates
      String? address;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = '${place.street}, ${place.locality}, ${place.administrativeArea}';
        }
      } catch (e) {
        // Address lookup failed, continue without it
      }

      final locationData = LocationData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        busId: busId,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed * 3.6, // Convert m/s to km/h
        heading: position.heading,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
        address: address,
      );

      _currentLocation = locationData;
      _locationHistory.add(locationData);

      // Keep only last 1000 locations to prevent memory issues
      if (_locationHistory.length > 1000) {
        _locationHistory.removeAt(0);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error updating location: $e';
      notifyListeners();
    }
  }

  // Get current position once
  Future<LocationData?> getCurrentPosition(String busId) async {
    try {
      bool hasPermission = await requestPermission();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String? address;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = '${place.street}, ${place.locality}, ${place.administrativeArea}';
        }
      } catch (e) {
        // Address lookup failed, continue without it
      }

      final locationData = LocationData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        busId: busId,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed * 3.6,
        heading: position.heading,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
        address: address,
      );

      _currentLocation = locationData;
      notifyListeners();
      return locationData;
    } catch (e) {
      _error = 'Error getting current position: $e';
      notifyListeners();
      return null;
    }
  }

  // Set mock location for demo purposes
  void setMockLocation(LocationData location) {
    _currentLocation = location;
    _locationHistory.add(location);
    _error = null;
    notifyListeners();
  }

  // Calculate distance between two points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Get locations within time range
  List<LocationData> getLocationsInTimeRange(DateTime start, DateTime end) {
    return _locationHistory.where((location) {
      return location.timestamp.isAfter(start) && location.timestamp.isBefore(end);
    }).toList();
  }

  // Get average speed for a time period
  double getAverageSpeed(DateTime start, DateTime end) {
    final locations = getLocationsInTimeRange(start, end);
    if (locations.isEmpty) return 0.0;

    double totalSpeed = 0.0;
    for (var location in locations) {
      totalSpeed += location.speed;
    }
    return totalSpeed / locations.length;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
