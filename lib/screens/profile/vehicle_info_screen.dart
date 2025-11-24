import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/vehicle_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_app_bar.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  void _loadVehicleData() {
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    final vehicle = vehicleProvider.currentVehicle;

    if (vehicle != null) {
      _plateNumberController.text = vehicle.plateNumber;
      _modelController.text = vehicle.model;
      _yearController.text = vehicle.year.toString();
      _brandController.text = vehicle.brand ?? '';
      _colorController.text = vehicle.color ?? '';
      _mileageController.text =
          vehicle.currentMileage?.toStringAsFixed(0) ?? '';
    }
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      final authProvider =
          Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentUser == null) return;

      try {
        final vehicle = VehicleModel(
          id: vehicleProvider.currentVehicle?.id ?? _databaseService.generateId(),
          plateNumber: _plateNumberController.text.trim(),
          model: _modelController.text.trim(),
          year: int.tryParse(_yearController.text) ?? DateTime.now().year,
          brand: _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
          color: _colorController.text.trim().isEmpty
              ? null
              : _colorController.text.trim(),
          currentMileage: _mileageController.text.trim().isEmpty
              ? null
              : double.tryParse(_mileageController.text.trim()),
          createdAt: vehicleProvider.currentVehicle?.createdAt ?? DateTime.now(),
          ownerId: authProvider.currentUser!.id,
        );

        await _databaseService.saveVehicle(vehicle);
        await vehicleProvider.saveVehicle(vehicle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle information saved successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Vehicle Information',
        showBackButton: true,
        showNotifications: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateNumberController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter plate number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter year';
                  }
                  final year = int.tryParse(value);
                  if (year == null) {
                    return 'Please enter a valid number';
                  }
                  if (year < 1900 || year > DateTime.now().year + 1) {
                    return 'Invalid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand - Optional',
                  prefixIcon: Icon(Icons.branding_watermark),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color - Optional',
                  prefixIcon: Icon(Icons.color_lens),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distance Traveled (km) - Optional',
                  prefixIcon: Icon(Icons.speed),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveVehicle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

