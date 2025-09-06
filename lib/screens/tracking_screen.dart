import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';
import '../services/bus_service.dart';
import '../models/bus.dart';
import '../models/location_data.dart';
import '../models/sensor_data.dart';
import '../widgets/error_boundary.dart';
import '../utils/qr_connection_helper.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Bus? _selectedBus;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeLocation();
    debugPrint('TrackingScreen initialized - QR code should be available');
  }

  Future<void> _initializeLocation() async {
    // Request location permission
    final locationService = context.read<LocationService>();
    bool hasPermission = await locationService.requestPermission();
    
    if (hasPermission) {
      // Try to get current position
      await locationService.getCurrentPosition('default');
      _updateMapWithCurrentLocation();
    } else {
      // Show helpful message about location permission
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(locationService.error ?? 'Location permission required'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _initializeLocation(),
            ),
          ),
        );
      }
    }
  }

  void _updateMapWithCurrentLocation() {
    try {
      final locationService = context.read<LocationService>();
      if (locationService.currentLocation != null && _mapController != null) {
        final location = locationService.currentLocation!;
        
        // Validate coordinates
        if (location.latitude.isFinite && location.longitude.isFinite) {
          // Add current location marker
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(location.latitude, location.longitude),
              infoWindow: const InfoWindow(
                title: 'Current Location',
                snippet: 'You are here',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );

          // Add bus location marker if tracking
          if (_selectedBus != null && _isTracking) {
            if (_selectedBus!.currentLatitude.isFinite && _selectedBus!.currentLongitude.isFinite) {
              _markers.add(
                Marker(
                  markerId: MarkerId('bus_${_selectedBus!.id}'),
                  position: LatLng(_selectedBus!.currentLatitude, _selectedBus!.currentLongitude),
                  infoWindow: InfoWindow(
                    title: 'Bus ${_selectedBus!.busNumber}',
                    snippet: 'Status: ${_selectedBus!.status}',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              );
            }
          }

          // Update polylines with location history
          _updatePolylines();

          // Move camera to current location
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(location.latitude, location.longitude),
              15.0,
            ),
          );

          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error updating map with current location: $e');
    }
  }

  void _updatePolylines() {
    try {
      final locationService = context.read<LocationService>();
      if (locationService.locationHistory.length > 1) {
        final points = locationService.locationHistory
            .where((location) => 
                location.latitude.isFinite && 
                location.longitude.isFinite)
            .map((location) => LatLng(location.latitude, location.longitude))
            .toList();

        if (points.length > 1) {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: Colors.blue,
              width: 4,
              patterns: [PatternItem.dash(20), PatternItem.gap(10)],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating polylines: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Real-Time Tracking'),
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.map), text: 'Map View'),
              Tab(icon: Icon(Icons.speed), text: 'Sensors'),
              Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () {
                debugPrint('QR Code button pressed');
                _showSimpleQRDialog(context);
              },
              tooltip: 'Connect to Phone',
            ),
            IconButton(
              icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
              onPressed: _toggleTracking,
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMapView(),
            _buildSensorView(),
            _buildAnalyticsView(),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "test_qr",
              onPressed: () {
                debugPrint('Test QR button pressed');
                _showSimpleQRDialog(context);
              },
              child: const Icon(Icons.qr_code),
              backgroundColor: Colors.green,
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "center_location_tracking",
              onPressed: _centerMapOnCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "select_bus_tracking",
              onPressed: _showBusSelector,
              child: const Icon(Icons.bus_alert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Consumer2<LocationService, BusService>(
      builder: (context, locationService, busService, child) {
        return Stack(
          children: [
            // Custom map view instead of Google Maps
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[50]!, Colors.white],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 80, color: Colors.blue[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Map View',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Location tracking is active',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showSimpleQRDialog(context);
                      },
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Connect to Phone'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (locationService.currentLocation != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Current Location',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: locationService.isTracking ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    locationService.isTracking ? Icons.gps_fixed : Icons.gps_off,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    locationService.isTracking ? 'Tracking' : 'Static',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Lat: ${locationService.currentLocation!.latitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Lng: ${locationService.currentLocation!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Speed: ${locationService.currentLocation!.speed.toStringAsFixed(1)} km/h',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        if (locationService.currentLocation!.address != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Address: ${locationService.currentLocation!.address}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Updated: ${_formatTime(locationService.currentLocation!.timestamp)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _initializeLocation();
                                    _updateMapWithCurrentLocation();
                                  },
                                  icon: const Icon(Icons.refresh, size: 16),
                                  tooltip: 'Refresh Location',
                                ),
                                IconButton(
                                  onPressed: _showLocationInputDialog,
                                  icon: const Icon(Icons.edit_location, size: 16),
                                  tooltip: 'Set Custom Location',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSensorView() {
    return Consumer<SensorService>(
      builder: (context, sensorService, child) {
        if (sensorService.currentSensorData == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sensors_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No sensor data available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Start tracking to see sensor data',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final sensorData = sensorService.currentSensorData!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            color: _getHealthStatusColor(sensorData.healthStatus),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Health Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getHealthStatusColor(sensorData.healthStatus),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getHealthStatusIcon(sensorData.healthStatus),
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  sensorData.healthStatus,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Last Updated: ${_formatTime(sensorData.timestamp)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  _buildSensorCard(
                    'Engine Temperature',
                    '${sensorData.engineTemperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    _getTemperatureColor(sensorData.engineTemperature),
                  ),
                  _buildSensorCard(
                    'Fuel Level',
                    '${sensorData.fuelLevel.toStringAsFixed(1)}%',
                    Icons.local_gas_station,
                    _getFuelColor(sensorData.fuelLevel),
                  ),
                  _buildSensorCard(
                    'Battery Voltage',
                    '${sensorData.batteryVoltage.toStringAsFixed(1)}V',
                    Icons.battery_std,
                    _getBatteryColor(sensorData.batteryVoltage),
                  ),
                  _buildSensorCard(
                    'Tire Pressure',
                    '${sensorData.tirePressure.toStringAsFixed(1)} PSI',
                    Icons.tire_repair,
                    _getTireColor(sensorData.tirePressure),
                  ),
                  _buildSensorCard(
                    'Brake Pad Wear',
                    '${sensorData.brakePadWear.toStringAsFixed(1)}%',
                    Icons.directions_car,
                    _getBrakeColor(sensorData.brakePadWear),
                  ),
                  _buildSensorCard(
                    'Engine Oil Level',
                    '${sensorData.engineOilLevel.toStringAsFixed(1)}%',
                    Icons.oil_barrel,
                    _getOilColor(sensorData.engineOilLevel),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return Consumer2<LocationService, SensorService>(
      builder: (context, locationService, sensorService, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatistics(locationService, sensorService),
              const SizedBox(height: 24),
              _buildSpeedChart(locationService),
              const SizedBox(height: 24),
              _buildSensorChart(sensorService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatistics(LocationService locationService, SensorService sensorService) {
    final avgSpeed = locationService.locationHistory.isNotEmpty
        ? locationService.locationHistory.map((l) => l.speed).reduce((a, b) => a + b) / locationService.locationHistory.length
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Avg Speed', '${avgSpeed.toStringAsFixed(1)} km/h', Icons.speed),
            _buildStatItem('Total Distance', '${_calculateTotalDistance(locationService.locationHistory).toStringAsFixed(1)} km', Icons.route),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Data Points', '${locationService.locationHistory.length}', Icons.data_usage),
            _buildStatItem('Health Status', sensorService.currentSensorData?.healthStatus ?? 'Unknown', Icons.health_and_safety),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFF667eea)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSpeedChart(LocationService locationService) {
    if (locationService.locationHistory.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('Not enough data for speed chart'),
          ),
        ),
      );
    }

    final speedData = locationService.locationHistory
        .map((location) => location.speed)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Speed Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: speedData.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFF667eea),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorChart(SensorService sensorService) {
    if (sensorService.sensorHistory.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No sensor data available'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensor Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sensorService.sensorHistory
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.engineTemperature))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTracking() {
    if (_selectedBus == null) {
      _showBusSelector();
      return;
    }

    setState(() {
      _isTracking = !_isTracking;
    });

    if (_isTracking) {
      context.read<LocationService>().startTracking(_selectedBus!.id);
      context.read<SensorService>().startMonitoring(_selectedBus!.id);
      
      // Update map with tracking data
      _updateMapWithCurrentLocation();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tracking started'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      context.read<LocationService>().stopTracking();
      context.read<SensorService>().stopMonitoring();
      
      // Clear bus markers when stopping
      _markers.removeWhere((marker) => marker.markerId.value.startsWith('bus_'));
      setState(() {});
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tracking stopped'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _centerMapOnCurrentLocation() {
    // Map is disabled, show QR dialog instead
    _showSimpleQRDialog(context);
  }

  void _showBusSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Bus'),
        content: Consumer<BusService>(
          builder: (context, busService, child) {
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: busService.buses.length,
                itemBuilder: (context, index) {
                  final bus = busService.buses[index];
                  return ListTile(
                    title: Text(bus.busNumber),
                    subtitle: Text('${bus.model} - ${bus.status}'),
                    onTap: () {
                      setState(() {
                        _selectedBus = bus;
                      });
                      Navigator.pop(context);
                      _updateMapWithCurrentLocation();
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Color _getHealthStatusColor(String status) {
    switch (status) {
      case 'Good':
        return Colors.green;
      case 'Warning':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getHealthStatusIcon(String status) {
    switch (status) {
      case 'Good':
        return Icons.check_circle;
      case 'Warning':
        return Icons.warning;
      case 'Critical':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getTemperatureColor(double temp) {
    if (temp > 100) return Colors.red;
    if (temp > 90) return Colors.orange;
    return Colors.green;
  }

  Color _getFuelColor(double fuel) {
    if (fuel < 20) return Colors.red;
    if (fuel < 50) return Colors.orange;
    return Colors.green;
  }

  Color _getBatteryColor(double voltage) {
    if (voltage < 12.0) return Colors.red;
    if (voltage < 12.5) return Colors.orange;
    return Colors.green;
  }

  Color _getTireColor(double pressure) {
    if (pressure < 30) return Colors.red;
    if (pressure < 35) return Colors.orange;
    return Colors.green;
  }

  Color _getBrakeColor(double wear) {
    if (wear > 80) return Colors.red;
    if (wear > 60) return Colors.orange;
    return Colors.green;
  }

  Color _getOilColor(double level) {
    if (level < 20) return Colors.red;
    if (level < 50) return Colors.orange;
    return Colors.green;
  }

  double _calculateTotalDistance(List<LocationData> locations) {
    if (locations.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 1; i < locations.length; i++) {
      final prev = locations[i - 1];
      final curr = locations[i];
      totalDistance += _calculateDistance(prev.latitude, prev.longitude, curr.latitude, curr.longitude);
    }
    return totalDistance;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _showLocationInputDialog() {
    final latitudeController = TextEditingController();
    final longitudeController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Your Location'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your current location coordinates:'),
              const SizedBox(height: 16),
              TextField(
                controller: latitudeController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'e.g., 6.9271',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: longitudeController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'e.g., 79.8612',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address (Optional)',
                  hintText: 'e.g., Your City, Country',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Get current location from device
                        _initializeLocation();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('Use GPS'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Use common locations
                        _showCommonLocationsDialog();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.location_city),
                      label: const Text('Common'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latitudeController.text);
              final lng = double.tryParse(longitudeController.text);
              
              if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
                final customLocation = LocationData(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  busId: 'custom',
                  latitude: lat,
                  longitude: lng,
                  speed: 0.0,
                  heading: 0.0,
                  accuracy: 5.0,
                  timestamp: DateTime.now(),
                  address: addressController.text.isNotEmpty ? addressController.text : null,
                );
                
                final locationService = context.read<LocationService>();
                locationService.setMockLocation(customLocation);
                _updateMapWithCurrentLocation();
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Custom location set successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid coordinates'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Set Location'),
          ),
        ],
      ),
    );
  }

  void _showCommonLocationsDialog() {
    final commonLocations = [
      {'name': 'Colombo, Sri Lanka', 'lat': 6.9271, 'lng': 79.8612},
      {'name': 'New York, USA', 'lat': 40.7128, 'lng': -74.0060},
      {'name': 'London, UK', 'lat': 51.5074, 'lng': -0.1278},
      {'name': 'Tokyo, Japan', 'lat': 35.6762, 'lng': 139.6503},
      {'name': 'Sydney, Australia', 'lat': -33.8688, 'lng': 151.2093},
      {'name': 'Dubai, UAE', 'lat': 25.2048, 'lng': 55.2708},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Common Location'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: commonLocations.length,
            itemBuilder: (context, index) {
              final location = commonLocations[index];
              return ListTile(
                title: Text(location['name'] as String),
                subtitle: Text('${location['lat']}, ${location['lng']}'),
                onTap: () {
                  final customLocation = LocationData(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    busId: 'common',
                    latitude: location['lat'] as double,
                    longitude: location['lng'] as double,
                    speed: 0.0,
                    heading: 0.0,
                    accuracy: 5.0,
                    timestamp: DateTime.now(),
                    address: location['name'] as String,
                  );
                  
                  final locationService = context.read<LocationService>();
                  locationService.setMockLocation(customLocation);
                  _updateMapWithCurrentLocation();
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Location set to ${location['name']}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSimpleQRDialog(BuildContext context) {
    debugPrint('QR dialog method called');
    showDialog(
      context: context,
      builder: (context) {
        debugPrint('QR dialog builder called');
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.qr_code, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Connect to Phone'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'To connect your phone to this Flutter app:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStep('1', 'Enable Developer Options on your phone'),
                _buildStep('2', 'Enable USB Debugging in Developer Options'),
                _buildStep('3', 'Connect phone to same WiFi network as this computer'),
                _buildStep('4', 'Open Command Prompt and run: adb tcpip 5555'),
                _buildStep('5', 'Run: adb connect 10.31.4.97:5555'),
                _buildStep('6', 'Run: flutter run'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code, size: 120, color: Colors.blue),
                      const SizedBox(height: 12),
                      const Text(
                        'Connection String:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '10.31.4.97:5555',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Copy this string and use it with adb connect',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'NOTE: This is NOT a web URL! Use with ADB command.',
                        style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('QR dialog closed');
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                debugPrint('Copy button pressed');
                Clipboard.setData(const ClipboardData(text: '10.31.4.97:5555'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connection string copied to clipboard!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    const double spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw some decorative circles
    final circlePaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 30, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 20, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.2), 15, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
