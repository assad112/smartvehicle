import 'package:flutter/foundation.dart';
import '../models/vehicle_model.dart';
import '../models/sensor_data_model.dart';
import '../services/database_service.dart';

class VehicleProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  VehicleModel? _currentVehicle;
  SensorDataModel? _latestSensorData;
  bool _isLoading = false;
  String? _errorMessage;

  VehicleModel? get currentVehicle => _currentVehicle;
  SensorDataModel? get latestSensorData => _latestSensorData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load vehicle by owner ID
  Future<void> loadVehicleByOwner(String ownerId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentVehicle = await _databaseService.getVehicleByOwner(ownerId);

      if (_currentVehicle != null) {
        // Load latest sensor data
        _databaseService
            .getLatestSensorData(_currentVehicle!.id)
            .listen((sensorData) {
          _latestSensorData = sensorData;
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

  // Load vehicle by ID
  Future<void> loadVehicle(String vehicleId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentVehicle = await _databaseService.getVehicle(vehicleId);

      if (_currentVehicle != null) {
        // Load latest sensor data
        _databaseService
            .getLatestSensorData(_currentVehicle!.id)
            .listen((sensorData) {
          _latestSensorData = sensorData;
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
}

