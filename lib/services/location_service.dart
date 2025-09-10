import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_data.dart';

class LocationService extends ChangeNotifier {
  StreamSubscription<Position>? _positionStream;
  final List<LocationData> _locationHistory = [];
  LocationData? _currentLocation;
  bool _isTracking = false;
  String? _error;
  bool _mounted = true;
  Timer? _permissionCheckTimer;

  List<LocationData> get locationHistory => List.unmodifiable(_locationHistory);
  LocationData? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;
  String? get error => _error;
  bool get mounted => _mounted;
  
  // Check if location permission is granted
  Future<bool> get hasPermission async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      bool hasPermission = permission == LocationPermission.whileInUse || 
                          permission == LocationPermission.always;
      
      if (!hasPermission) {
        _error = 'Location permission not granted';
      } else {
        _error = null;
      }
      notifyListeners();
      return hasPermission;
    } catch (e) {
      _error = 'Error checking permission: $e';
      notifyListeners();
      return false;
    }
  }

  // Check if location services are enabled
  Future<bool> get isLocationServiceEnabled async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _error = 'Location services are disabled';
      } else {
        _error = null;
      }
      notifyListeners();
      return enabled;
    } catch (e) {
      _error = 'Error checking location service: $e';
      notifyListeners();
      return false;
    }
  }

  // Request location permission with simplified logic
  Future<bool> requestPermission() async {
    try {
      _error = null;
      notifyListeners();

      // Check if location services are enabled first
      bool serviceEnabled = await isLocationServiceEnabled;
      if (!serviceEnabled) {
        return false;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      // If permission is denied, request it
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Check if permission is still denied
      if (permission == LocationPermission.denied) {
        _error = 'Location permission denied. Please grant permission to continue.';
        notifyListeners();
        return false;
      }

      // Check if permission is permanently denied
      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permission permanently denied. Please enable it in app settings.';
        notifyListeners();
        return false;
      }

      // Permission granted
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error requesting permission: $e';
      notifyListeners();
      return false;
    }
  }

  // Start real-time location tracking with simplified settings
  Future<void> startTracking(String busId) async {
    if (_isTracking) return;

    try {
      // Check permissions first
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        _error = 'Location permission required to start tracking';
        notifyListeners();
        return;
      }

      _isTracking = true;
      _error = null;
      notifyListeners();

      // Use simpler location settings for better reliability
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.medium, // Use medium accuracy for better reliability
        distanceFilter: 5, // Update every 5 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          await _updateLocation(busId, position);
        },
        onError: (error) {
          print('Location tracking error: $error');
          _error = 'Location tracking error: $error';
          _isTracking = false;
          notifyListeners();
        },
        cancelOnError: true, // Cancel stream on error to prevent continuous errors
      );
    } catch (e) {
      print('Error starting location tracking: $e');
      _error = 'Error starting location tracking: $e';
      _isTracking = false;
      notifyListeners();
    }
  }

  // Start background location tracking
  Future<void> startBackgroundTracking(String busId) async {
    if (_isTracking) return;

    bool hasPermission = await requestPermission();
    if (!hasPermission) return;

    try {
      _isTracking = true;
      _error = null;
      notifyListeners();

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.medium, // Use medium accuracy for background
        distanceFilter: 50, // Update every 50 meters for background
        timeLimit: Duration(minutes: 1), // Timeout after 1 minute
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          await _updateLocation(busId, position);
        },
        onError: (error) {
          _error = 'Background location tracking error: $error';
          _isTracking = false;
          notifyListeners();
          
          // Try to restart tracking after a longer delay for background
          Future.delayed(const Duration(seconds: 30), () {
            if (!_isTracking && mounted) {
              try {
                startBackgroundTracking(busId);
              } catch (e) {
                print('Error restarting background tracking: $e');
              }
            }
          });
        },
        cancelOnError: false,
      );
    } catch (e) {
      _error = 'Error starting background location tracking: $e';
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

  // Check and handle location service status
  Future<bool> checkLocationServiceStatus() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled;
      if (!serviceEnabled) {
        _error = 'Location services are disabled. Please enable location services in your device settings.';
        _isTracking = false;
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _error = 'Error checking location service status: $e';
      notifyListeners();
      return false;
    }
  }

  // Restart location tracking if it was stopped due to errors
  Future<void> restartTrackingIfNeeded(String busId) async {
    if (!_isTracking && await hasPermission && await isLocationServiceEnabled) {
      await startTracking(busId);
    }
  }

  // Handle app lifecycle changes
  Future<void> handleAppLifecycleChange(String busId, bool isAppInForeground) async {
    try {
      if (!_isTracking) return;

      // Stop current tracking
      stopTracking();

      // Wait a bit before restarting
      await Future.delayed(const Duration(seconds: 1));

      if (isAppInForeground) {
        // App is in foreground, use high accuracy tracking
        await startTracking(busId);
      } else {
        // App is in background, use background tracking
        await startBackgroundTracking(busId);
      }
    } catch (e) {
      _error = 'Error handling app lifecycle change: $e';
      notifyListeners();
    }
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

  // Get current position once with simplified error handling
  Future<LocationData?> getCurrentPosition(String busId) async {
    try {
      // Check permissions first
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        _error = 'Location permission required';
        notifyListeners();
        return null;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Use medium accuracy for better reliability
        timeLimit: const Duration(seconds: 10), // 10 second timeout
      );

      // Try to get address (optional)
      String? address;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
          address = address.replaceAll(', ,', ',').replaceAll(RegExp(r'^,\s*|,\s*$'), '');
        }
      } catch (e) {
        print('Address lookup failed: $e');
        // Continue without address
      }

      final locationData = LocationData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        busId: busId,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: (position.speed * 3.6).clamp(0.0, 200.0), // Convert m/s to km/h and clamp
        heading: position.heading,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
        address: address?.isNotEmpty == true ? address : null,
      );

      _currentLocation = locationData;
      _error = null;
      notifyListeners();
      return locationData;
    } catch (e) {
      print('Error getting current position: $e');
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
    _mounted = false;
    _permissionCheckTimer?.cancel();
    stopTracking();
    super.dispose();
  }
}
