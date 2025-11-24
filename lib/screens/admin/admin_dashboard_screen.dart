import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/vehicle_model.dart';
import '../../models/sensor_data_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import 'add_maintenance_for_user_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Admin Dashboard',
        showBackButton: false,
        showUserAvatar: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.build, color: Colors.white),
            tooltip: 'Add Maintenance Record',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddMaintenanceForUserScreen(),
                ),
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () {
                  _showLogoutDialog(context);
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Force refresh
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Section
              _buildStatisticsSection(context, firestore),
              
              // Vehicles Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'All Vehicles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              
              // Vehicles List
              StreamBuilder<List<VehicleModel>>(
                stream: databaseService.getAllVehicles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading data: ${snapshot.error}',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final vehicles = snapshot.data ?? [];

                  if (vehicles.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 64,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No vehicles registered',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vehicles will be displayed here when registered',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return _buildVehicleCard(context, vehicle, databaseService);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, FirebaseFirestore firestore) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'System Overview',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.directions_car,
                    'Vehicles',
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection(AppConstants.vehiclesCollection).snapshots(),
                      builder: (context, snapshot) {
                        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Text(
                          count.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.people,
                    'Users',
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection(AppConstants.usersCollection).snapshots(),
                      builder: (context, snapshot) {
                        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Text(
                          count.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.build,
                    'Maintenance Records',
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection(AppConstants.maintenanceCollection).snapshots(),
                      builder: (context, snapshot) {
                        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Text(
                          count.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.notifications_active,
                    'Notifications',
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection(AppConstants.notificationsCollection).snapshots(),
                      builder: (context, snapshot) {
                        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Text(
                          count.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    Widget value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          value,
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    VehicleModel vehicle,
    DatabaseService databaseService,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
        // TODO: add a vehicle details page in the future
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.model,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.confirmation_number,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vehicle.plateNumber,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vehicle.year.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<SensorDataModel?>(
                stream: databaseService.getLatestSensorData(vehicle.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  final sensorData = snapshot.data;
                  final status = sensorData?.status ?? AppConstants.statusOK;
                  final statusColor = AppTheme.getStatusColor(status);

                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  status == AppConstants.statusOK
                                      ? Icons.check_circle
                                      : status == AppConstants.statusWarning
                                          ? Icons.warning
                                          : Icons.error,
                                  color: statusColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status == AppConstants.statusOK
                                      ? 'Status OK'
                                      : status == AppConstants.statusWarning
                                          ? 'Warning'
                                          : 'Critical',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (sensorData != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _buildSensorRow(
                                context,
                                Icons.thermostat,
                                'Engine Temperature',
                                sensorData.engineTemperature != null
                                    ? '${sensorData.engineTemperature!.toStringAsFixed(1)}°C'
                                    : 'Not available',
                                sensorData.engineTemperature != null &&
                                        sensorData.engineTemperature! >
                                            AppConstants.warningEngineTemperature
                                    ? AppTheme.warningColor
                                    : AppTheme.successColor,
                              ),
                              const SizedBox(height: 8),
                              _buildSensorRow(
                                context,
                                Icons.battery_charging_full,
                                'Battery Voltage',
                                sensorData.batteryVoltage != null
                                    ? '${sensorData.batteryVoltage!.toStringAsFixed(1)}V'
                                    : 'Not available',
                                sensorData.batteryVoltage != null &&
                                        sensorData.batteryVoltage! <
                                            AppConstants.warningBatteryVoltage
                                    ? AppTheme.warningColor
                                    : AppTheme.successColor,
                              ),
                              if (sensorData.fuelLevel != null) ...[
                                const SizedBox(height: 8),
                                _buildSensorRow(
                                  context,
                                  Icons.local_gas_station,
                                  'Fuel Level',
                                  '${sensorData.fuelLevel!.toStringAsFixed(0)}%',
                                  sensorData.fuelLevel! < AppConstants.minFuelLevel
                                      ? AppTheme.warningColor
                                      : AppTheme.successColor,
                                ),
                              ],
                              if (sensorData.oilPressure != null) ...[
                                const SizedBox(height: 8),
                                _buildSensorRow(
                                  context,
                                  Icons.oil_barrel,
                                  'Oil Pressure',
                                  '${sensorData.oilPressure!.toStringAsFixed(1)} PSI',
                                  sensorData.oilPressure! < AppConstants.minOilPressure
                                      ? AppTheme.errorColor
                                      : AppTheme.successColor,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Text(
                          'No sensor data available',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              if (vehicle.currentMileage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.speed,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Distance Traveled: ${vehicle.currentMileage!.toStringAsFixed(0)} km',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
