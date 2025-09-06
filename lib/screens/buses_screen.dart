import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bus_service.dart';
import '../models/bus.dart';

class BusesScreen extends StatefulWidget {
  const BusesScreen({super.key});

  @override
  State<BusesScreen> createState() => _BusesScreenState();
}

class _BusesScreenState extends State<BusesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusService>().getAllBuses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(
            child: _buildBusesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBusDialog,
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Bus Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Consumer<BusService>(
              builder: (context, busService, child) {
                return Text(
                  '${busService.buses.length} Buses',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search buses...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', _filterStatus == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Available', _filterStatus == 'Available'),
                const SizedBox(width: 8),
                _buildFilterChip('In Use', _filterStatus == 'In Use'),
                const SizedBox(width: 8),
                _buildFilterChip('Maintenance', _filterStatus == 'Maintenance'),
                const SizedBox(width: 8),
                _buildFilterChip('Service Due', _filterStatus == 'Service Due'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBusesList() {
    return Consumer<BusService>(
      builder: (context, busService, child) {
        if (busService.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          );
        }

        List<Bus> buses = _getFilteredBuses(busService.buses);

        if (buses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_bus,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'No buses found' : 'No buses match your search',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a new bus',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: buses.length,
          itemBuilder: (context, index) {
            final bus = buses[index];
            return _buildBusCard(bus);
          },
        );
      },
    );
  }

  List<Bus> _getFilteredBuses(List<Bus> buses) {
    List<Bus> filteredBuses = buses;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredBuses = context.read<BusService>().searchBuses(_searchQuery);
    }

    // Apply status filter
    switch (_filterStatus) {
      case 'Available':
        filteredBuses = filteredBuses.where((bus) => bus.isAvailable).toList();
        break;
      case 'In Use':
        filteredBuses = filteredBuses.where((bus) => bus.isInUse).toList();
        break;
      case 'Maintenance':
        filteredBuses = filteredBuses.where((bus) => bus.isInMaintenance).toList();
        break;
      case 'Service Due':
        filteredBuses = filteredBuses.where((bus) => bus.needsService).toList();
        break;
    }

    return filteredBuses;
  }

  Widget _buildBusCard(Bus bus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _showBusDetails(bus),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(bus.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: _getStatusColor(bus.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.busNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${bus.manufacturer} ${bus.model}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bus.registrationNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(bus.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(bus.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${bus.capacity} seats',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip('Year: ${bus.year}', Icons.calendar_today),
                  const SizedBox(width: 8),
                  _buildInfoChip('${bus.mileage.toStringAsFixed(0)} km', Icons.speed),
                  const SizedBox(width: 8),
                  _buildInfoChip(bus.fuelType, Icons.local_gas_station),
                ],
              ),
              if (bus.needsService || bus.isServiceDueSoon) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bus.needsService ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.build,
                        color: bus.needsService ? Colors.red : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        bus.needsService
                            ? 'Service overdue since ${bus.nextServiceDate.day}/${bus.nextServiceDate.month}/${bus.nextServiceDate.year}'
                            : 'Service due on ${bus.nextServiceDate.day}/${bus.nextServiceDate.month}/${bus.nextServiceDate.year}',
                        style: TextStyle(
                          color: bus.needsService ? Colors.red : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'in_use':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'out_of_service':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'Available';
      case 'in_use':
        return 'In Use';
      case 'maintenance':
        return 'Maintenance';
      case 'out_of_service':
        return 'Out of Service';
      default:
        return status;
    }
  }

  void _showAddBusDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddBusDialog(),
    );
  }

  void _showBusDetails(Bus bus) {
    showDialog(
      context: context,
      builder: (context) => BusDetailsDialog(bus: bus),
    );
  }
}

class AddBusDialog extends StatefulWidget {
  const AddBusDialog({super.key});

  @override
  State<AddBusDialog> createState() => _AddBusDialogState();
}

class _AddBusDialogState extends State<AddBusDialog> {
  final _formKey = GlobalKey<FormState>();
  final _busNumberController = TextEditingController();
  final _registrationController = TextEditingController();
  final _modelController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _capacityController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();
  int _year = 2020;
  String _fuelType = 'Diesel';
  DateTime _lastServiceDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _nextServiceDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_bus, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Bus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(_busNumberController, 'Bus Number', Icons.confirmation_number),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(_registrationController, 'Registration', Icons.directions_car),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(_manufacturerController, 'Manufacturer', Icons.business),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(_modelController, 'Model', Icons.directions_bus),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(_capacityController, 'Capacity', Icons.people),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(_colorController, 'Color', Icons.palette),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(_mileageController, 'Mileage', Icons.speed),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown('Year', _year.toString(), List.generate(25, (index) => (2024 - index).toString()), (value) {
                              setState(() {
                                _year = int.parse(value!);
                              });
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown('Fuel Type', _fuelType, ['Diesel', 'Petrol', 'Electric', 'Hybrid'], (value) {
                        setState(() {
                          _fuelType = value!;
                        });
                      }),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _addBus,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Add Bus'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: label == 'Capacity' || label == 'Mileage' ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  void _addBus() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final bus = Bus(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        busNumber: _busNumberController.text,
        registrationNumber: _registrationController.text,
        model: _modelController.text,
        manufacturer: _manufacturerController.text,
        year: _year,
        capacity: int.parse(_capacityController.text),
        color: _colorController.text,
        fuelType: _fuelType,
        mileage: double.parse(_mileageController.text),
        lastServiceDate: _lastServiceDate,
        nextServiceDate: _nextServiceDate,
        createdAt: now,
        updatedAt: now,
      );

      context.read<BusService>().addBus(bus).then((success) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bus added successfully')),
          );
        }
      });
    }
  }
}

class BusDetailsDialog extends StatelessWidget {
  final Bus bus;

  const BusDetailsDialog({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_bus, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bus.busNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Registration', bus.registrationNumber, Icons.directions_car),
                    _buildDetailRow('Model', '${bus.manufacturer} ${bus.model}', Icons.directions_bus),
                    _buildDetailRow('Year', bus.year.toString(), Icons.calendar_today),
                    _buildDetailRow('Capacity', '${bus.capacity} seats', Icons.people),
                    _buildDetailRow('Color', bus.color, Icons.palette),
                    _buildDetailRow('Fuel Type', bus.fuelType, Icons.local_gas_station),
                    _buildDetailRow('Mileage', '${bus.mileage.toStringAsFixed(0)} km', Icons.speed),
                    _buildDetailRow('Status', _getStatusText(bus.status), Icons.circle),
                    _buildDetailRow('Total Trips', bus.totalTrips.toString(), Icons.directions_bus),
                    _buildDetailRow('Total Distance', '${bus.totalDistance.toStringAsFixed(0)} km', Icons.route),
                    _buildDetailRow('Last Service', '${bus.lastServiceDate.day}/${bus.lastServiceDate.month}/${bus.lastServiceDate.year}', Icons.build),
                    _buildDetailRow('Next Service', '${bus.nextServiceDate.day}/${bus.nextServiceDate.month}/${bus.nextServiceDate.year}', Icons.schedule),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'Available';
      case 'in_use':
        return 'In Use';
      case 'maintenance':
        return 'Maintenance';
      case 'out_of_service':
        return 'Out of Service';
      default:
        return status;
    }
  }
}
