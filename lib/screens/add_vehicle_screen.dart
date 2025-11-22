import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/family_vehicle_service.dart';
import '../models/family_vehicle.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  final _fuelCapacityController = TextEditingController();
  final _odometerController = TextEditingController();
  final _ownerController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  String _fuelType = 'Gasoline';
  String _status = 'active';
  DateTime _insuranceExpiry = DateTime.now().add(const Duration(days: 365));
  DateTime _registrationExpiry = DateTime.now().add(const Duration(days: 365));
  List<String> _selectedFeatures = [];

  final List<String> _fuelTypes = ['Gasoline', 'Diesel', 'Hybrid', 'Electric'];
  final List<String> _statuses = ['active', 'maintenance', 'inactive'];
  final List<String> _availableFeatures = [
    'GPS',
    'Bluetooth',
    'Backup Camera',
    'Cruise Control',
    'AWD',
    'Sunroof',
    'Heated Seats',
    'Navigation',
    'Lane Departure Warning',
    'USB Ports',
    'Automatic Transmission',
    'Manual Transmission',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _fuelCapacityController.dispose();
    _odometerController.dispose();
    _ownerController.dispose();
    _insuranceProviderController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveVehicle,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Basic Information'),
              _buildTextField('Vehicle Name', _nameController, 'e.g., Family Car'),
              _buildTextField('Make', _makeController, 'e.g., Toyota'),
              _buildTextField('Model', _modelController, 'e.g., Camry'),
              _buildTextField('Year', _yearController, 'e.g., 2020', TextInputType.number),
              _buildTextField('License Plate', _licensePlateController, 'e.g., ABC-123'),
              _buildTextField('Color', _colorController, 'e.g., Silver'),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Technical Details'),
              _buildDropdown('Fuel Type', _fuelType, _fuelTypes, (value) {
                setState(() {
                  _fuelType = value!;
                });
              }),
              _buildTextField('Fuel Capacity (L)', _fuelCapacityController, 'e.g., 60', TextInputType.number),
              _buildTextField('Current Odometer (km)', _odometerController, 'e.g., 45000', TextInputType.number),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Ownership Information'),
              _buildTextField('Owner', _ownerController, 'e.g., John Smith'),
              _buildTextField('Insurance Provider', _insuranceProviderController, 'e.g., State Farm'),
              _buildDateField('Insurance Expiry', _insuranceExpiry, (date) {
                setState(() {
                  _insuranceExpiry = date;
                });
              }),
              _buildTextField('Registration Number', _registrationNumberController, 'e.g., REG-2020-001'),
              _buildDateField('Registration Expiry', _registrationExpiry, (date) {
                setState(() {
                  _registrationExpiry = date;
                });
              }),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Status & Features'),
              _buildDropdown('Status', _status, _statuses, (value) {
                setState(() {
                  _status = value!;
                });
              }),
              _buildFeaturesSelector(),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Vehicle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String label, DateTime value, ValueChanged<DateTime> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 3650)),
          );
          if (date != null) {
            onChanged(date);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${value.day}/${value.month}/${value.year}'),
              const Icon(Icons.calendar_today, color: Color(0xFF667eea)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableFeatures.map((feature) {
              final isSelected = _selectedFeatures.contains(feature);
              return FilterChip(
                label: Text(feature),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFeatures.add(feature);
                    } else {
                      _selectedFeatures.remove(feature);
                    }
                  });
                },
                selectedColor: const Color(0xFF667eea).withOpacity(0.2),
                checkmarkColor: const Color(0xFF667eea),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final vehicle = FamilyVehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        licensePlate: _licensePlateController.text,
        color: _colorController.text,
        fuelType: _fuelType,
        fuelCapacity: double.parse(_fuelCapacityController.text),
        currentFuelLevel: double.parse(_fuelCapacityController.text) * 0.75, // Start with 75% fuel
        odometerReading: int.parse(_odometerController.text),
        lastServiceDate: DateTime.now().subtract(const Duration(days: 30)),
        nextServiceDate: DateTime.now().add(const Duration(days: 90)),
        status: _status,
        owner: _ownerController.text,
        insuranceProvider: _insuranceProviderController.text,
        insuranceExpiry: _insuranceExpiry,
        registrationNumber: _registrationNumberController.text,
        registrationExpiry: _registrationExpiry,
        features: _selectedFeatures,
        maintenanceHistory: {},
        averageFuelConsumption: 8.5, // Default value
        totalTrips: 0,
        totalDistance: 0.0,
      );

      context.read<FamilyVehicleService>().addVehicle(vehicle);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }
}
