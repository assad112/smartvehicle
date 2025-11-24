import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../models/maintenance_model.dart';
import '../../models/vehicle_model.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';

class AddMaintenanceForUserScreen extends StatefulWidget {
  const AddMaintenanceForUserScreen({super.key});

  @override
  State<AddMaintenanceForUserScreen> createState() =>
      _AddMaintenanceForUserScreenState();
}

class _AddMaintenanceForUserScreenState
    extends State<AddMaintenanceForUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  final _mileageController = TextEditingController();
  DateTime? _selectedDate;
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _selectedUser;
  VehicleModel? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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

  Future<void> _selectUser() async {
    // Get all users (excluding admins)
    final usersSnapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('isAdmin', isEqualTo: false)
        .get();

    if (usersSnapshot.docs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No registered users found'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    final userList = usersSnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();

    if (mounted) {
      final selectedUser = await showDialog<UserModel>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select User'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () {
                    Navigator.of(context).pop(user);
                  },
                );
              },
            ),
          ),
        ),
      );

      if (selectedUser != null) {
        // Get user's vehicle by ownerId
        VehicleModel? vehicle;
        try {
          final vehiclesSnapshot = await _firestore
              .collection(AppConstants.vehiclesCollection)
              .where('ownerId', isEqualTo: selectedUser.id)
              .limit(1)
              .get();

          if (vehiclesSnapshot.docs.isNotEmpty) {
            final vehicleData = vehiclesSnapshot.docs.first.data();
            vehicle = VehicleModel.fromMap(vehicleData);
          }
        } catch (e) {
          print('Error getting vehicle: $e');
        }

        setState(() {
          _selectedUser = selectedUser;
          _selectedVehicle = vehicle;
        });

        if (vehicle == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected user does not have a registered vehicle'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveMaintenance() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedUser != null &&
        _selectedVehicle != null) {
      try {
        final maintenance = MaintenanceModel(
          id: _databaseService.generateId(),
          vehicleId: _selectedVehicle!.id,
          type: _typeController.text.trim(),
          date: _selectedDate!,
          cost: double.parse(_costController.text),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          mileage: _mileageController.text.trim().isEmpty
              ? null
              : double.tryParse(_mileageController.text.trim()),
          createdAt: DateTime.now(),
          updatedAt: null,
        );

        await _databaseService.addMaintenanceRecord(maintenance);

        // Create notification for the user
        if (_selectedUser != null) {
          print('📤 Creating notification for user: ${_selectedUser!.id}');
          print('📤 User name: ${_selectedUser!.name}');
          print('📤 User email: ${_selectedUser!.email}');
          try {
            await _notificationService.createNotification(
              userId: _selectedUser!.id,
              title: 'New Maintenance Record Added',
              message: 'Maintenance record added: ${_typeController.text.trim()} - Cost: ${_costController.text} ${AppConstants.currency}',
              type: AppConstants.notificationTypeMaintenance,
              vehicleId: _selectedVehicle!.id,
              maintenanceId: maintenance.id,
            );
            print('✅ Notification created successfully');
          } catch (e) {
            print('❌ Error creating notification: $e');
            // Don't throw, just log the error
          }
        } else {
          print('⚠️ No user selected, skipping notification');
        }

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maintenance record added successfully and notification sent to user'),
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
    } else {
      if (_selectedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a user'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      } else if (_selectedVehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected user does not have a registered vehicle'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Maintenance Record',
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
              // User Selection
              InkWell(
                onTap: _selectUser,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'User',
                    prefixIcon: const Icon(Icons.person),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _selectedUser != null
                        ? '${_selectedUser!.name} - ${_selectedUser!.email}'
                        : 'Select User',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Vehicle Info (Read-only, shown after user selection)
              if (_selectedVehicle != null)
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Vehicle',
                    prefixIcon: const Icon(Icons.directions_car),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                  ),
                  child: Text(
                    '${_selectedVehicle!.model} - ${_selectedVehicle!.plateNumber}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              if (_selectedUser != null && _selectedVehicle == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.warningColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppTheme.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected user does not have a registered vehicle',
                          style: TextStyle(
                            color: AppTheme.warningColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

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
                        ? DateFormat('yyyy/MM/dd').format(_selectedDate!)
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
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

