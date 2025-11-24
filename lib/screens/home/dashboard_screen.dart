import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/database_service.dart';
import '../../models/sensor_data_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicleData();
    });
  }

  void _loadVehicleData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      vehicleProvider.loadVehicleByOwner(authProvider.currentUser!.id);
    }
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications_rounded,
                label: 'Notifications',
                index: 1,
                showBadge: true,
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Settings',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool showBadge = false,
  }) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primaryColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      color: isActive
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                  if (showBadge && index == 1)
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final userId = authProvider.currentUser?.id;
                        if (userId == null) return const SizedBox.shrink();
                        final databaseService = DatabaseService();
                        return StreamBuilder<int>(
                          stream: databaseService.getUnreadNotificationsCount(userId),
                          builder: (context, snapshot) {
                            final unreadCount = snapshot.data ?? 0;
                            if (unreadCount == 0) return const SizedBox.shrink();
                            return Positioned(
                              right: -3,
                              top: -3,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.errorColor.withOpacity(0.5),
                                      blurRadius: 3,
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: isActive ? 24 : 0,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardHome(),
          NotificationsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  String _getAirQualityStatus(double? fuelLevel, String status) {
    if (status == AppConstants.statusCritical) return 'Critical';
    if (status == AppConstants.statusWarning) return 'Warning';
    if (fuelLevel != null && fuelLevel < 20) return 'Low';
    return 'Good';
  }

  Color _getAirQualityColor(String airQuality) {
    if (airQuality == 'Critical') return AppTheme.errorColor;
    if (airQuality == 'Warning' || airQuality == 'Low') return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final user = authProvider.currentUser;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.transparent,
                          child: user != null && user.name.isNotEmpty
                              ? Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 24,
                                  color: Colors.white,
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            final user = authProvider.currentUser;
                            return Text(
                              user != null && user.name.isNotEmpty
                                  ? 'Hello, ${user.name}'
                                  : 'Hello',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Smart Vehicle System',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final userId = authProvider.currentUser?.id;
                      if (userId == null) {
                        return IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          },
                        );
                      }

                      final databaseService = DatabaseService();
                      return StreamBuilder<int>(
                        stream: databaseService.getUnreadNotificationsCount(userId),
                        builder: (context, snapshot) {
                          final unreadCount = snapshot.data ?? 0;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_outlined),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const NotificationsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.errorColor,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final vehicleProvider =
              Provider.of<VehicleProvider>(context, listen: false);
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.currentUser != null) {
            await vehicleProvider.loadVehicleByOwner(authProvider.currentUser!.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Consumer<VehicleProvider>(
            builder: (context, vehicleProvider, _) {
              if (vehicleProvider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (vehicleProvider.currentVehicle == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No vehicle registered',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please add vehicle information from Settings',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final vehicle = vehicleProvider.currentVehicle!;
              final sensorData = vehicleProvider.latestSensorData;
              final status = sensorData?.status ?? AppConstants.statusOK;

              // Calculate battery percentage from voltage
              double? batteryPercentage;
              if (sensorData?.batteryVoltage != null) {
                // Assume 12.6V = 100% and 11.5V = 0%
                double voltage = sensorData!.batteryVoltage!;
                batteryPercentage = ((voltage - 11.5) / (12.6 - 11.5) * 100).clamp(0.0, 100.0);
              }

              // Air quality derived from vehicle status and fuel level
              final airQuality = _getAirQualityStatus(
                sensorData?.fuelLevel,
                status,
              );
              final airQualityColor = _getAirQualityColor(airQuality);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Name Header with Gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vehicle.model,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                        if (vehicle.plateNumber.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            vehicle.plateNumber,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Battery Card
                  _buildInfoCard(
                    context,
                    icon: Icons.battery_charging_full,
                    label: 'Battery',
                    value: batteryPercentage != null
                        ? '${batteryPercentage.toStringAsFixed(0)}%'
                        : sensorData?.batteryVoltage != null
                            ? '${sensorData!.batteryVoltage!.toStringAsFixed(1)}V'
                            : 'Not available',
                    iconColor: batteryPercentage != null && batteryPercentage < 20
                        ? AppTheme.warningColor
                        : AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // Location Card
                  GestureDetector(
                    onTap: () {
                      final lat = sensorData?.latitude ?? AppConstants.defaultLatitude;
                      final lng = sensorData?.longitude ?? AppConstants.defaultLongitude;
                      _showLocationDialog(context, lat, lng);
                    },
                    child: _buildInfoCard(
                      context,
                      icon: Icons.location_on,
                      label: 'Location',
                      value: sensorData?.latitude != null && sensorData?.longitude != null
                          ? '${sensorData?.latitude!.toStringAsFixed(4)}, ${sensorData?.longitude!.toStringAsFixed(4)}'
                          : '${AppConstants.defaultLatitude.toStringAsFixed(4)}, ${AppConstants.defaultLongitude.toStringAsFixed(4)}',
                      iconColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Air Quality Card
                  _buildInfoCard(
                    context,
                    icon: Icons.air,
                    label: 'Air Quality',
                    value: airQuality,
                    iconColor: airQualityColor,
                  ),
                  const SizedBox(height: 24),

                  // Vehicle Status Chart
                  if (sensorData != null) ...[
                    _buildVehicleStatusChart(context, sensorData, vehicle),
                    const SizedBox(height: 24),
                  ],

                  // Additional Info Section
                  if (sensorData != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Additional Information',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (sensorData.fuelLevel != null)
                              _buildAdditionalInfoRow(
                                context,
                                Icons.local_gas_station,
                                'Fuel Level',
                                '${sensorData.fuelLevel!.toStringAsFixed(0)}%',
                              ),
                            if (sensorData.oilPressure != null) ...[
                              const SizedBox(height: 12),
                              _buildAdditionalInfoRow(
                                context,
                                Icons.oil_barrel,
                                'Oil Pressure',
                                '${sensorData.oilPressure!.toStringAsFixed(1)} PSI',
                              ),
                            ],
                            if (vehicle.currentMileage != null) ...[
                              const SizedBox(height: 12),
                              _buildAdditionalInfoRow(
                                context,
                                Icons.speed,
                                'Distance Traveled',
                                '${vehicle.currentMileage!.toStringAsFixed(0)} km',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, double latitude, double longitude) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vehicle Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Map
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latitude, longitude),
                        zoom: 16.0,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('vehicle_location'),
                          position: LatLng(latitude, longitude),
                          infoWindow: InfoWindow(
                            title: '🚗 Vehicle Location',
                            snippet: 'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                          draggable: false,
                          anchor: const Offset(0.5, 1.0),
                          visible: true,
                          zIndex: 1,
                        ),
                      },
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      mapType: MapType.normal,
                      compassEnabled: true,
                      mapToolbarEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        // Additional map configuration can be added here
                      },
                    ),
                  ),
                ),
                // Footer with coordinates
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            iconColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withOpacity(0.2),
                    iconColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 24,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleStatusChart(
    BuildContext context,
    sensorData,
    vehicle,
  ) {
    final databaseService = DatabaseService();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Vehicle Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Status Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  context,
                  'Battery',
                  sensorData.batteryVoltage != null
                      ? '${((sensorData.batteryVoltage! - 11.5) / (12.6 - 11.5) * 100).clamp(0.0, 100.0).toStringAsFixed(0)}%'
                      : 'Not available',
                  sensorData.batteryVoltage != null &&
                          ((sensorData.batteryVoltage! - 11.5) / (12.6 - 11.5) * 100) < 20
                      ? AppTheme.warningColor
                      : AppTheme.successColor,
                  Icons.battery_charging_full,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  context,
                  'Location',
                  sensorData.latitude != null && sensorData.longitude != null
                      ? '${sensorData.latitude!.toStringAsFixed(3)}, ${sensorData.longitude!.toStringAsFixed(3)}'
                      : '${AppConstants.defaultLatitude.toStringAsFixed(3)}, ${AppConstants.defaultLongitude.toStringAsFixed(3)}',
                  AppTheme.successColor,
                  Icons.location_on,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Line Chart for Sensor Data History
          StreamBuilder<List<SensorDataModel>>(
            stream: databaseService.getSensorDataHistory(vehicle.id, 10),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final historyData = snapshot.data ?? [];
              
              if (historyData.isEmpty) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No historical data',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Prepare data for chart
              final batteryData = <FlSpot>[];
              final temperatureData = <FlSpot>[];
              
              for (int i = 0; i < historyData.length; i++) {
                final data = historyData[i];
                if (data.batteryVoltage != null) {
                  final percentage = ((data.batteryVoltage! - 11.5) / (12.6 - 11.5) * 100).clamp(0.0, 100.0);
                  batteryData.add(FlSpot(i.toDouble(), percentage));
                }
                if (data.engineTemperature != null) {
                  temperatureData.add(FlSpot(i.toDouble(), data.engineTemperature!));
                }
              }

              return SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppTheme.textSecondary.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: AppTheme.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    minX: 0,
                    maxX: (historyData.length - 1).toDouble(),
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      // Battery Line
                      if (batteryData.isNotEmpty)
                        LineChartBarData(
                          spots: batteryData,
                          isCurved: true,
                          color: AppTheme.primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                        ),
                      // Temperature Line
                      if (temperatureData.isNotEmpty)
                        LineChartBarData(
                          spots: temperatureData.map((spot) => FlSpot(spot.x, spot.y * 2)).toList(),
                          isCurved: true,
                          color: AppTheme.warningColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.warningColor.withOpacity(0.1),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                context,
                AppTheme.primaryColor,
                'Battery (%)',
              ),
              const SizedBox(width: 20),
              _buildLegendItem(
                context,
                AppTheme.warningColor,
                'Location',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}
