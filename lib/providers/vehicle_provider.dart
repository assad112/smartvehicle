import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/vehicle_model.dart';
import '../models/sensor_data_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class VehicleProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  VehicleModel? _currentVehicle;
  SensorDataModel? _latestSensorData;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<SensorDataModel?>? _sensorDataSubscription;
  String? _currentUserId;

  VehicleModel? get currentVehicle => _currentVehicle;
  SensorDataModel? get latestSensorData => _latestSensorData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load vehicle by owner ID
  Future<void> loadVehicleByOwner(String ownerId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _currentUserId = ownerId;
      notifyListeners();

      // Cancel previous subscription if exists
      await _sensorDataSubscription?.cancel();

      _currentVehicle = await _databaseService.getVehicleByOwner(ownerId);

      if (_currentVehicle != null) {
        // Load latest sensor data with notification monitoring
        _sensorDataSubscription = _databaseService
            .getLatestSensorData(_currentVehicle!.id)
            .listen((sensorData) {
          final previousStatus = _latestSensorData?.status;
          _latestSensorData = sensorData;
          
          // Check if status changed and create notifications
          if (sensorData != null && previousStatus != sensorData.status) {
            _checkAndCreateSensorNotifications(sensorData, ownerId);
          }
          
          notifyListeners();
        });
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check sensor data and create notifications if needed
  void _checkAndCreateSensorNotifications(SensorDataModel sensorData, String userId) async {
    if (sensorData.status == AppConstants.statusCritical) {
      // Critical status - create critical alert
      String alertMessage = _buildCriticalAlertMessage(sensorData);
      await _notificationService.createAlertNotification(
        userId: userId,
        vehicleId: sensorData.vehicleId,
        alertMessage: alertMessage,
        status: AppConstants.statusCritical,
      );
    } else if (sensorData.status == AppConstants.statusWarning) {
      // Warning status - create warning notification
      String alertMessage = _buildWarningMessage(sensorData);
      await _notificationService.createAlertNotification(
        userId: userId,
        vehicleId: sensorData.vehicleId,
        alertMessage: alertMessage,
        status: AppConstants.statusWarning,
      );
    }
  }

  // Build critical alert message based on sensor values
  String _buildCriticalAlertMessage(SensorDataModel sensorData) {
    List<String> issues = [];
    
    if (sensorData.engineTemperature != null && 
        sensorData.engineTemperature! > AppConstants.maxEngineTemperature) {
      issues.add('Engine temperature is critical: ${sensorData.engineTemperature!.toStringAsFixed(1)}°C');
    }
    
    if (sensorData.batteryVoltage != null && 
        sensorData.batteryVoltage! < AppConstants.minBatteryVoltage) {
      issues.add('Battery voltage is low: ${sensorData.batteryVoltage!.toStringAsFixed(1)}V');
    }
    
    if (sensorData.oilPressure != null && 
        sensorData.oilPressure! < AppConstants.minOilPressure) {
      issues.add('Oil pressure is critical: ${sensorData.oilPressure!.toStringAsFixed(1)} PSI');
    }
    
    if (sensorData.fuelLevel != null && 
        sensorData.fuelLevel! < AppConstants.minFuelLevel) {
      issues.add('Fuel level is very low: ${sensorData.fuelLevel!.toStringAsFixed(0)}%');
    }
    
    if (issues.isEmpty) {
      return 'Critical vehicle condition detected. Please check your vehicle immediately.';
    }
    
    return 'CRITICAL ALERT: ${issues.join('; ')}. Please check your vehicle immediately!';
  }

  // Build warning message based on sensor values
  String _buildWarningMessage(SensorDataModel sensorData) {
    List<String> warnings = [];
    
    if (sensorData.engineTemperature != null && 
        sensorData.engineTemperature! > AppConstants.warningEngineTemperature &&
        sensorData.engineTemperature! <= AppConstants.maxEngineTemperature) {
      warnings.add('Engine temperature is high: ${sensorData.engineTemperature!.toStringAsFixed(1)}°C');
    }
    
    if (sensorData.batteryVoltage != null && 
        sensorData.batteryVoltage! < AppConstants.warningBatteryVoltage &&
        sensorData.batteryVoltage! >= AppConstants.minBatteryVoltage) {
      warnings.add('Battery voltage is getting low: ${sensorData.batteryVoltage!.toStringAsFixed(1)}V');
    }
    
    if (sensorData.fuelLevel != null && sensorData.fuelLevel! < 20) {
      warnings.add('Fuel level is low: ${sensorData.fuelLevel!.toStringAsFixed(0)}%');
    }
    
    if (warnings.isEmpty) {
      return 'Warning: Vehicle condition needs attention.';
    }
    
    return 'WARNING: ${warnings.join('; ')}.';
  }

  // Load vehicle by ID
  Future<void> loadVehicle(String vehicleId, {String? userId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      if (userId != null) _currentUserId = userId;
      notifyListeners();

      // Cancel previous subscription if exists
      await _sensorDataSubscription?.cancel();

      _currentVehicle = await _databaseService.getVehicle(vehicleId);

      if (_currentVehicle != null && _currentUserId != null) {
        // Load latest sensor data with notification monitoring
        _sensorDataSubscription = _databaseService
            .getLatestSensorData(_currentVehicle!.id)
            .listen((sensorData) {
          final previousStatus = _latestSensorData?.status;
          _latestSensorData = sensorData;
          
          // Check if status changed and create notifications
          if (sensorData != null && previousStatus != sensorData.status && _currentUserId != null) {
            _checkAndCreateSensorNotifications(sensorData, _currentUserId!);
          }
          
          notifyListeners();
        });
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save vehicle
  Future<bool> saveVehicle(VehicleModel vehicle) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _databaseService.saveVehicle(vehicle);
      _currentVehicle = vehicle;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sensorDataSubscription?.cancel();
    super.dispose();
  }
}

