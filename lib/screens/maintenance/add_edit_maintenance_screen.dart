import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/database_service.dart';
import '../../models/maintenance_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';

class AddEditMaintenanceScreen extends StatefulWidget {
  final MaintenanceModel? maintenance;

  const AddEditMaintenanceScreen({super.key, this.maintenance});

  @override
  State<AddEditMaintenanceScreen> createState() =>
      _AddEditMaintenanceScreenState();
}

class _AddEditMaintenanceScreenState extends State<AddEditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  final _mileageController = TextEditingController();
  DateTime? _selectedDate;
  final DatabaseService _databaseService = DatabaseService();

  bool get isEditing => widget.maintenance != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final maintenance = widget.maintenance!;
      _typeController.text = maintenance.type;
      _costController.text = maintenance.cost.toStringAsFixed(2);
      _notesController.text = maintenance.notes ?? '';
      _mileageController.text = maintenance.mileage?.toStringAsFixed(0) ?? '';
      _selectedDate = maintenance.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _costController.dispose();
    _notesController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'US'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMaintenance() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      final vehicleId = vehicleProvider.currentVehicle?.id;

      if (vehicleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No vehicle registered'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      try {
        final maintenance = MaintenanceModel(
          id: widget.maintenance?.id ?? _databaseService.generateId(),
          vehicleId: vehicleId,
          type: _typeController.text.trim(),
          date: _selectedDate!,
          cost: double.parse(_costController.text),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          mileage: _mileageController.text.trim().isEmpty
              ? null
              : double.tryParse(_mileageController.text.trim()),
          createdAt: widget.maintenance?.createdAt ?? DateTime.now(),
          updatedAt: isEditing ? DateTime.now() : null,
        );

        if (isEditing) {
          await _databaseService.updateMaintenanceRecord(maintenance);
        } else {
          await _databaseService.addMaintenanceRecord(maintenance);
        }

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? 'Maintenance record updated successfully'
                  : 'Maintenance record added successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
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
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Maintenance Record' : 'Add New Maintenance Record',
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
              // Maintenance Type
              DropdownButtonFormField<String>(
                value: _typeController.text.isEmpty
                    ? null
                    : _typeController.text,
                decoration: const InputDecoration(
                  labelText: 'Maintenance Type',
                  prefixIcon: Icon(Icons.build),
                ),
                items: AppConstants.maintenanceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _typeController.text = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select maintenance type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('yyyy/MM/dd', 'en').format(_selectedDate!)
                        : 'Select date',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cost
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cost (${AppConstants.currency})',
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) < 0) {
                    return 'Cost must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mileage (optional)
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
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes - Optional',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveMaintenance,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Save Changes' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

