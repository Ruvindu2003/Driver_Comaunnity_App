import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/family_vehicle_service.dart';
import '../models/family_vehicle.dart';
import 'add_vehicle_screen.dart';

class FamilyVehiclesScreen extends StatefulWidget {
  const FamilyVehiclesScreen({super.key});

  @override
  State<FamilyVehiclesScreen> createState() => _FamilyVehiclesScreenState();
}

class _FamilyVehiclesScreenState extends State<FamilyVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vehicleService = context.read<FamilyVehicleService>();
      await vehicleService.loadVehicles();
      await vehicleService.initializeSampleData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Vehicles'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddVehicleDialog(),
          ),
        ],
      ),
      body: Consumer<FamilyVehicleService>(
        builder: (context, vehicleService, child) {
          if (vehicleService.vehicles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No vehicles added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first vehicle',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicleService.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicleService.vehicles[index];
              return _buildVehicleCard(vehicle);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleDialog(),
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildVehicleCard(FamilyVehicle vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showVehicleDetails(vehicle),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(vehicle.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: _getStatusColor(vehicle.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          vehicle.fullName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(vehicle.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vehicle.statusDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(vehicle.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoItem(
                    'Fuel',
                    '${vehicle.fuelPercentage.toStringAsFixed(0)}%',
                    Icons.local_gas_station,
                    _getFuelColor(vehicle.fuelPercentage),
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    'Odometer',
                    '${(vehicle.odometerReading / 1000).toStringAsFixed(0)}k km',
                    Icons.speed,
                    Colors.blue,
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    'Trips',
                    '${vehicle.totalTrips}',
                    Icons.trip_origin,
                    Colors.green,
                  ),
                ],
              ),
              if (vehicle.needsService || vehicle.insuranceExpiringSoon || vehicle.registrationExpiringSoon) ...[
                const SizedBox(height: 12),
                _buildAlertsRow(vehicle),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsRow(FamilyVehicle vehicle) {
    List<Widget> alerts = [];
    
    if (vehicle.needsService) {
      alerts.add(_buildAlertChip('Service Due', Colors.orange));
    }
    if (vehicle.insuranceExpiringSoon) {
      alerts.add(_buildAlertChip('Insurance Expiring', Colors.red));
    }
    if (vehicle.registrationExpiringSoon) {
      alerts.add(_buildAlertChip('Registration Expiring', Colors.red));
    }

    return Row(
      children: alerts,
    );
  }

  Widget _buildAlertChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getFuelColor(double percentage) {
    if (percentage < 20) return Colors.red;
    if (percentage < 50) return Colors.orange;
    return Colors.green;
  }

  void _showVehicleDetails(FamilyVehicle vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                vehicle.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                vehicle.fullName,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('License Plate', vehicle.licensePlate),
              _buildDetailRow('Color', vehicle.color),
              _buildDetailRow('Fuel Type', vehicle.fuelType),
              _buildDetailRow('Owner', vehicle.owner),
              _buildDetailRow('Insurance Provider', vehicle.insuranceProvider),
              _buildDetailRow('Registration Number', vehicle.registrationNumber),
              const SizedBox(height: 24),
              const Text(
                'Maintenance History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: vehicle.maintenanceHistory.length,
                  itemBuilder: (context, index) {
                    final entry = vehicle.maintenanceHistory.entries.elementAt(index);
                    final record = entry.value as Map<String, dynamic>;
                    return ListTile(
                      title: Text(record['type'] ?? 'Unknown'),
                      subtitle: Text(record['notes'] ?? ''),
                      trailing: Text('\$${record['cost']?.toStringAsFixed(2) ?? '0.00'}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showAddVehicleDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
    );
  }
}
