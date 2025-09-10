import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with WidgetsBindingObserver {
  List<Map<String, double>> _trackingPoints = []; // Store lat/lng as simple map
  bool _isTracking = false;
  bool _hasPermission = false;
  bool _isRequestingPermission = false;
  Timer? _locationCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocation();
    _startLocationCheckTimer();
    _setupLocationListener();
  }

  void _setupLocationListener() {
    // Listen to location service changes
    final locationService = context.read<LocationService>();
    locationService.addListener(() {
      if (mounted && _isTracking && locationService.currentLocation != null) {
        final location = locationService.currentLocation!;
        // Add new tracking point
        _trackingPoints.add({
          'latitude': location.latitude,
          'longitude': location.longitude,
        });
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (!mounted) return;
    
    try {
      final locationService = context.read<LocationService>();
      
      if (state == AppLifecycleState.resumed) {
        // App came back to foreground, check location status
        _checkLocationStatus();
        // Switch to foreground tracking if we were tracking
        if (_isTracking) {
          locationService.handleAppLifecycleChange('default', true);
        }
      } else if (state == AppLifecycleState.paused) {
        // App went to background, switch to background tracking if we were tracking
        if (_isTracking) {
          locationService.handleAppLifecycleChange('default', false);
        }
      }
    } catch (e) {
      // Handle any errors silently to prevent crashes
      print('Error in app lifecycle change: $e');
    }
  }

  void _startLocationCheckTimer() {
    _locationCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _checkLocationStatus();
      }
    });
  }

  Future<void> _checkLocationStatus() async {
    if (!mounted) return;
    
    try {
      final locationService = context.read<LocationService>();
      bool serviceEnabled = await locationService.isLocationServiceEnabled;
      bool hasPermission = await locationService.hasPermission;
      
      if (!serviceEnabled || !hasPermission) {
        if (mounted) {
          setState(() {
            _hasPermission = false;
          });
          
          if (!serviceEnabled) {
            _showLocationServiceDialog();
          } else {
            _showPermissionDialog();
          }
        }
      } else if (!_hasPermission) {
        if (mounted) {
          setState(() {
            _hasPermission = true;
          });
          // Try to get current location if we have permission now
          await locationService.getCurrentPosition('default');
          _updateLocationDisplay();
        }
      }
    } catch (e) {
      // Handle errors silently to prevent crashes
      print('Error checking location status: $e');
    }
  }

  Future<void> _initializeLocation() async {
    if (!mounted) return;
    
    try {
      final locationService = context.read<LocationService>();
      
      setState(() {
        _isRequestingPermission = true;
      });
      
      // Check if location services are enabled first
      bool serviceEnabled = await locationService.isLocationServiceEnabled;
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _hasPermission = false;
            _isRequestingPermission = false;
          });
          _showLocationServiceDialog();
        }
        return;
      }
      
      // Request permission
      bool hasPermission = await locationService.requestPermission();
      
      if (mounted) {
        setState(() {
          _hasPermission = hasPermission;
          _isRequestingPermission = false;
        });
        
        if (hasPermission) {
          // Try to get current position
          await locationService.getCurrentPosition('default');
          _updateLocationDisplay();
        } else {
          _showPermissionDialog();
        }
      }
    } catch (e) {
      print('Error initializing location: $e');
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isRequestingPermission = false;
        });
        _showLocationServiceDialog();
      }
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_disabled, color: Colors.red),
              SizedBox(width: 8),
              Text('Location Services Disabled'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location services are currently disabled on your device.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'To use this app, please:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Go to your device Settings'),
              Text('2. Find Location or Privacy & Security'),
              Text('3. Turn on Location Services'),
              Text('4. Return to this app'),
              SizedBox(height: 16),
              Text(
                'Location services are required for:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Tracking your current location'),
              Text('• Displaying your position on the map'),
              Text('• Monitoring your movement and speed'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
                // Wait a bit and then check again
                Future.delayed(const Duration(seconds: 2), () {
                  _initializeLocation();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('Location Permission Required'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This app needs location permission to:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Track your current location'),
              Text('• Display your position on the map'),
              Text('• Monitor your movement and speed'),
              SizedBox(height: 16),
              Text(
                'Please grant location permission in your device settings to continue.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestPermissionAgain();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestPermissionAgain() async {
    setState(() {
      _isRequestingPermission = true;
    });
    
    final locationService = context.read<LocationService>();
    
    // First check if location services are enabled
    bool serviceEnabled = await locationService.isLocationServiceEnabled;
    if (!serviceEnabled) {
      setState(() {
        _hasPermission = false;
        _isRequestingPermission = false;
      });
      if (mounted) {
        _showLocationServiceDialog();
      }
      return;
    }
    
    bool hasPermission = await locationService.requestPermission();
    
    setState(() {
      _hasPermission = hasPermission;
      _isRequestingPermission = false;
    });
    
    if (hasPermission) {
      await locationService.getCurrentPosition('default');
      _updateLocationDisplay();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission granted!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locationService.error ?? 'Permission denied'),
          backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () async {
                await Geolocator.openAppSettings();
              },
            ),
        ),
      );
    }
  }

  void _updateLocationDisplay() {
    // This method is called when location is updated
    // The UI will automatically rebuild through the Consumer widget
    setState(() {});
  }

  Widget _buildLocationDisplay(LocationService locationService) {
    final location = locationService.currentLocation!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Status Card
          Card(
            elevation: 4,
            color: location.accuracy < 10 ? Colors.green.shade50 : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    location.accuracy < 10 ? Icons.location_on : Icons.location_searching,
                    color: location.accuracy < 10 ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.accuracy < 10 ? 'High Accuracy' : 'Low Accuracy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: location.accuracy < 10 ? Colors.green : Colors.orange,
                          ),
                        ),
                        Text(
                          'Accuracy: ${location.accuracy.toStringAsFixed(1)} meters',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          // Current Location Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Current Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLocationInfoRow('Latitude', location.latitude.toStringAsFixed(6)),
                  _buildLocationInfoRow('Longitude', location.longitude.toStringAsFixed(6)),
                  _buildLocationInfoRow('Speed', '${location.speed.toStringAsFixed(1)} km/h'),
                  _buildLocationInfoRow('Accuracy', '${location.accuracy.toStringAsFixed(1)} meters'),
                  _buildLocationInfoRow('Heading', '${location.heading.toStringAsFixed(1)}°'),
                  if (location.address != null) ...[
                    const SizedBox(height: 8),
                    _buildLocationInfoRow('Address', location.address!),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tracking Status Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isTracking ? Icons.play_circle : Icons.pause_circle,
                        color: _isTracking ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tracking Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatusRow('Status', _isTracking ? 'Active' : 'Inactive', 
                    _isTracking ? Colors.green : Colors.orange),
                  _buildStatusRow('Points Recorded', '${_trackingPoints.length}', Colors.blue),
                  _buildStatusRow('Last Update', _formatTime(location.timestamp), Colors.grey),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Location History Card
          if (_trackingPoints.isNotEmpty)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timeline,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Location History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _trackingPoints.length,
                        itemBuilder: (context, index) {
                          final point = _trackingPoints[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text('${index + 1}'),
                            ),
                            title: Text('Point ${index + 1}'),
                            subtitle: Text(
                              'Lat: ${point['latitude']!.toStringAsFixed(4)}\nLng: ${point['longitude']!.toStringAsFixed(4)}',
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
              ),
            );
          }

  Widget _buildLocationInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  void _toggleTracking() {
    if (!mounted) return;
    
    try {
      final locationService = context.read<LocationService>();
      
      setState(() {
        _isTracking = !_isTracking;
        if (!_isTracking) {
          _trackingPoints.clear();
          locationService.stopTracking();
        } else {
          // Start tracking with the location service
          locationService.startTracking('default');
          // Add current location as first tracking point
          if (locationService.currentLocation != null) {
            _trackingPoints.add({
              'latitude': locationService.currentLocation!.latitude,
              'longitude': locationService.currentLocation!.longitude,
            });
          }
        }
      });
    } catch (e) {
      print('Error toggling tracking: $e');
      // Reset state on error
      if (mounted) {
        setState(() {
          _isTracking = false;
        });
      }
    }
  }

  void _clearTracking() {
    setState(() {
      _trackingPoints.clear();
    });
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isRequestingPermission = true;
    });
    
    final locationService = context.read<LocationService>();
    
    // Check location service status first
    bool serviceEnabled = await locationService.isLocationServiceEnabled;
    if (!serviceEnabled) {
      setState(() {
        _hasPermission = false;
        _isRequestingPermission = false;
      });
      if (mounted) {
        _showLocationServiceDialog();
      }
      return;
    }
    
    // Check permission
    bool hasPermission = await locationService.hasPermission;
    if (!hasPermission) {
      setState(() {
        _hasPermission = false;
        _isRequestingPermission = false;
      });
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }
    
    // Try to get current location
    try {
      await locationService.getCurrentPosition('default');
      _updateLocationDisplay();
      
      setState(() {
        _hasPermission = true;
        _isRequestingPermission = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location refreshed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRequestingPermission = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocation,
            tooltip: 'Refresh Location',
          ),
          if (!_hasPermission)
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: _requestPermissionAgain,
              tooltip: 'Grant Location Permission',
            ),
          IconButton(
            icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
            onPressed: _hasPermission ? _toggleTracking : null,
            tooltip: _isTracking ? 'Stop Tracking' : 'Start Tracking',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _hasPermission ? _clearTracking : null,
            tooltip: 'Clear Path',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Consumer2<LocationService, SensorService>(
                  builder: (context, locationService, sensorService, child) {
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _hasPermission ? Icons.location_on : Icons.location_off,
                                size: 16,
                                color: _hasPermission ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Status: ${_hasPermission ? "Ready" : "Not Ready"}',
                                style: TextStyle(
                                  color: _hasPermission ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Location: ${locationService.isTracking ? "Active" : "Inactive"}',
                            style: TextStyle(
                              color: locationService.isTracking ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Speed: ${sensorService.currentSpeed.toStringAsFixed(1)} km/h',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isTracking ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isTracking ? 'TRACKING' : 'STOPPED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (!_hasPermission) ...[
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: _requestPermissionAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        child: const Text(
                          'Grant Permission',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Location Display
          Expanded(
            child: Consumer<LocationService>(
              builder: (context, locationService, child) {
                // Show loading state while requesting permission
                if (_isRequestingPermission) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Requesting location permission...'),
                      ],
                    ),
                  );
                }
                
                // Show permission denied state
                if (!_hasPermission) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_disabled,
                            size: 80,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Location Permission Required',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'This app needs location permission to track your position.',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _requestPermissionAgain,
                            icon: const Icon(Icons.location_on),
                            label: const Text('Grant Permission'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Go Back'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await Geolocator.openLocationSettings();
                                },
                                icon: const Icon(Icons.settings),
                                label: const Text('Open Settings'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Show no location data state
                if (locationService.currentLocation == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_searching,
                          size: 64,
                          color: Colors.orange.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Getting your location...',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text('Please wait while we find your position'),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final locationService = context.read<LocationService>();
                            await locationService.getCurrentPosition('default');
                            _updateLocationDisplay();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Location'),
                        ),
                      ],
                    ),
                  );
                }

                // Show location information
                return _buildLocationDisplay(locationService);
              },
            ),
          ),
          
          // Bottom Info Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Consumer2<LocationService, SensorService>(
                  builder: (context, locationService, sensorService, child) {
                    final location = locationService.currentLocation;
                    if (location == null) {
                      return const Text('No location data');
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem('Latitude', location.latitude.toStringAsFixed(6)),
                            _buildInfoItem('Longitude', location.longitude.toStringAsFixed(6)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem('Speed', '${location.speed.toStringAsFixed(1)} km/h'),
                            _buildInfoItem('Accuracy', '${location.accuracy.toStringAsFixed(1)} m'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem('Device Speed', '${sensorService.currentSpeed.toStringAsFixed(1)} km/h'),
                            _buildInfoItem('Moving', sensorService.isMoving ? 'Yes' : 'No'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _hasPermission ? _toggleTracking : null,
                        icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                        label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTracking ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _hasPermission ? _clearTracking : null,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Path'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_hasPermission) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Location permission required to start tracking',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshLocation,
        tooltip: 'Refresh Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}