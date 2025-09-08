

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/family_vehicle_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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
        title: const Text('Reports & Analytics'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Trigger rebuild to refresh data
              });
            },
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _showExportOptions(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Export Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<FamilyVehicleService>(
        builder: (context, vehicleService, child) {
          final stats = vehicleService.getVehicleStatistics();
          final vehicles = vehicleService.vehicles;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(stats),
                const SizedBox(height: 24),
                _buildInteractiveCharts(vehicles),
                const SizedBox(height: 24),
                _buildVehiclePerformanceChart(vehicles),
                const SizedBox(height: 24),
                _buildMaintenanceReport(vehicles),
                const SizedBox(height: 24),
                _buildFuelEfficiencyReport(vehicles),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Vehicles',
          '${stats['totalVehicles']}',
          Icons.directions_car,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Vehicles',
          '${stats['activeVehicles']}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Need Service',
          '${stats['vehiclesNeedingService']}',
          Icons.build,
          Colors.orange,
        ),
        _buildStatCard(
          'Total Distance',
          '${(stats['totalDistance'] / 1000).toStringAsFixed(1)}k km',
          Icons.speed,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCharts(List<dynamic> vehicles) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: _buildPieChart(vehicles),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildBarChart(vehicles),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<dynamic> vehicles) {
    if (vehicles.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final totalDistance = vehicles.fold(0.0, (sum, v) => sum + v.totalDistance);
    final pieData = vehicles.map((vehicle) {
      final percentage = totalDistance > 0 ? (vehicle.totalDistance / totalDistance) * 100 : 0;
      return PieChartSectionData(
        color: _getVehicleColor(vehicle.name),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        const Text(
          'Distance Distribution',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: pieData,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: vehicles.map((vehicle) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getVehicleColor(vehicle.name),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  vehicle.name,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<dynamic> vehicles) {
    if (vehicles.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final maxEfficiency = vehicles.map((v) => v.averageFuelConsumption).reduce((a, b) => a > b ? a : b);
    
    return Column(
      children: [
        const Text(
          'Fuel Efficiency',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxEfficiency * 1.2,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${vehicles[group.x].name}\n${rod.toY.toStringAsFixed(1)} L/100km',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < vehicles.length) {
                        return Text(
                          vehicles[value.toInt()].name.substring(0, 3),
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: vehicles.asMap().entries.map((entry) {
                final index = entry.key;
                final vehicle = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: vehicle.averageFuelConsumption,
                      color: _getVehicleColor(vehicle.name),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getVehicleColor(String vehicleName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final index = vehicleName.hashCode % colors.length;
    return colors[index];
  }

  Widget _buildVehiclePerformanceChart(List<dynamic> vehicles) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          ...vehicles.map((vehicle) {
            final efficiency = vehicle.averageFuelConsumption;
            final maxEfficiency = vehicles.map((v) => v.averageFuelConsumption).reduce((a, b) => a > b ? a : b);
            final percentage = (efficiency / maxEfficiency) * 100;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${efficiency.toStringAsFixed(1)} L/100km',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      efficiency <= 8 ? Colors.green : efficiency <= 10 ? Colors.orange : Colors.red,
                    ),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMaintenanceReport(List<dynamic> vehicles) {
    final vehiclesNeedingService = vehicles.where((v) => v.needsService).toList();
    final vehiclesWithExpiringInsurance = vehicles.where((v) => v.insuranceExpiringSoon).toList();
    final vehiclesWithExpiringRegistration = vehicles.where((v) => v.registrationExpiringSoon).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Maintenance Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          _buildReportItem(
            'Vehicles Needing Service',
            vehiclesNeedingService.length,
            Icons.build,
            Colors.orange,
            vehiclesNeedingService.map((v) => v.name as String).toList(),
          ),
          const SizedBox(height: 16),
          _buildReportItem(
            'Insurance Expiring Soon',
            vehiclesWithExpiringInsurance.length,
            Icons.warning,
            Colors.red,
            vehiclesWithExpiringInsurance.map((v) => v.name as String).toList(),
          ),
          const SizedBox(height: 16),
          _buildReportItem(
            'Registration Expiring Soon',
            vehiclesWithExpiringRegistration.length,
            Icons.description,
            Colors.blue,
            vehiclesWithExpiringRegistration.map((v) => v.name as String).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelEfficiencyReport(List<dynamic> vehicles) {
    final totalDistance = vehicles.fold(0.0, (sum, v) => sum + v.totalDistance);
    final totalTrips = vehicles.fold(0, (sum, v) => sum + (v.totalTrips as int));
    final averageEfficiency = vehicles.isNotEmpty 
        ? vehicles.fold(0.0, (sum, v) => sum + v.averageFuelConsumption) / vehicles.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fuel Efficiency Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildFuelStatItem(
                  'Total Distance',
                  '${(totalDistance / 1000).toStringAsFixed(1)}k km',
                  Icons.speed,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildFuelStatItem(
                  'Total Trips',
                  '$totalTrips',
                  Icons.trip_origin,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFuelStatItem(
                  'Avg Efficiency',
                  '${averageEfficiency.toStringAsFixed(1)} L/100km',
                  Icons.local_gas_station,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildFuelStatItem(
                  'Best Vehicle',
                  vehicles.isNotEmpty 
                      ? (vehicles.reduce((a, b) => a.averageFuelConsumption < b.averageFuelConsumption ? a : b).name as String)
                      : 'N/A',
                  Icons.star,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(String title, int count, IconData icon, Color color, List<String> vehicleNames) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
              if (vehicleNames.isNotEmpty)
                Text(
                  vehicleNames.join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFuelStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
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
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Export Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export as PDF'),
                subtitle: const Text('Generate a PDF report with charts and data'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsPDF(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Export as Excel'),
                subtitle: const Text('Generate an Excel spreadsheet with data'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsExcel(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Export Charts as Images'),
                subtitle: const Text('Save charts as PNG images'),
                onTap: () {
                  Navigator.pop(context);
                  _exportChartsAsImages(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportAsPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportAsExcel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel export feature coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportChartsAsImages(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image export feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
