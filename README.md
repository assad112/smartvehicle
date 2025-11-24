# Smart Vehicle Health Monitoring System

An integrated system for monitoring vehicle health and scheduling maintenance using Arduino and IoT

## 📋 Overview

This application is an intelligent system for monitoring vehicle status and maintenance consisting of:

- **Flutter Application** for drivers and administrators
- **Firebase Database** for data storage
- **IoT System** (Arduino/ESP32) for reading sensor data
- **Admin Dashboard** for monitoring all vehicles

## ✨ Features

### For Users (Drivers):
- ✅ Login and Registration
- ✅ Real-time vehicle status display
- ✅ Maintenance record management (add, edit, delete)
- ✅ Notifications and alerts display
- ✅ Profile management (edit data, change password)
- ✅ Vehicle information management

### For Administrators (Admin):
- ✅ Comprehensive dashboard for all vehicles
- ✅ Display status of each vehicle (OK, WARNING, CRITICAL)
- ✅ Monitor sensor data for each vehicle
- ✅ Track maintenance records

## 🏗️ Technical Architecture

### Technologies Used:
- **Flutter** - Application framework
- **Firebase** - Database and Authentication
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Messaging
- **Provider** - State Management
- **Material Design 3** - User Interface

### Project Structure:
```
lib/
├── models/          # Data models
├── services/        # Services (Auth, Database, Notifications)
├── providers/       # State Management
├── screens/         # Screens
│   ├── auth/       # Login and Registration
│   ├── home/       # Main Dashboard
│   ├── maintenance/# Maintenance Records
│   ├── profile/    # Profile
│   ├── notifications/ # Notifications
│   └── admin/      # Admin Dashboard
├── utils/          # Constants and Theme
└── main.dart       # Entry point
```

## 🚀 Getting Started

### Requirements:
- Flutter SDK (3.8.1 or later)
- Firebase project
- Android Studio / VS Code

### Installation Steps:

1. **Clone the project:**
```bash
git clone <repository-url>
cd smartvehicle
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Setup Firebase:**
   - Create a new Firebase project
   - Add Android/iOS app
   - Download configuration files:
     - `android/app/google-services.json` (for Android)
     - `ios/Runner/GoogleService-Info.plist` (for iOS)
   - Enable Authentication (Email/Password)
   - Create Firestore Database

4. **Run the application:**
```bash
flutter run
```

## 📱 Main Screens

### 1. Login
- Login with email and password
- Registration link

### 2. Main Dashboard
- Display vehicle information
- Vehicle status (OK/WARNING/CRITICAL)
- Sensor readings (engine temperature, battery voltage, fuel level, etc.)

### 3. Maintenance Records
- Display all maintenance records
- Add new maintenance record
- Edit existing record
- Delete record

### 4. Notifications
- Display all notifications
- Mark notifications as read
- Notification types (maintenance, warning, alert)

### 5. Profile
- Display user data
- Edit name and email
- Change password
- Manage vehicle information

### 6. Admin Dashboard
- Display all vehicles
- Status of each vehicle
- Sensor data for each vehicle

## 🔧 Database (Firebase Firestore)

### Collections:
- `users` - User data
- `vehicles` - Vehicle data
- `maintenance` - Maintenance records
- `sensor_data` - Sensor data
- `notifications` - Notifications

## 📊 Data Models

### UserModel
- id, email, name, phone, profileImageUrl
- isAdmin, createdAt, vehicleId

### VehicleModel
- id, plateNumber, model, year, brand, color
- currentMileage, lastMaintenanceDate, ownerId

### MaintenanceModel
- id, vehicleId, type, date, cost, notes, mileage

### SensorDataModel
- id, vehicleId, engineTemperature, batteryVoltage
- fuelLevel, vibrationLevel, oilPressure, status

## 🔔 Notifications

- Upcoming maintenance notifications
- Alerts when vehicle issues are detected
- Instant notifications for critical conditions

## 🌐 Language Support

- Arabic (default)
- English

## 📝 Important Notes

1. **Delete notifications on logout:** As required, all notifications are deleted when logging out.

2. **Instant updates:** When adding a new maintenance record, it appears immediately in the list without refreshing the page.

3. **Security:** All data is protected with Firebase Authentication.

## 🔌 Arduino/ESP32 Integration

To connect the system with Arduino/ESP32:

1. Send sensor data to Firebase Firestore in the `sensor_data` collection
2. Use the same structure as `SensorDataModel`
3. Send data periodically (every 10-30 seconds)

Example of data to send:
```json
{
  "id": "unique-id",
  "vehicleId": "vehicle-id",
  "engineTemperature": 85.5,
  "batteryVoltage": 12.6,
  "fuelLevel": 75.0,
  "oilPressure": 45.0,
  "status": "OK",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

## 👥 Contributing

We welcome all contributions! Please open an Issue or Pull Request.

## 📄 License

This project is open source.

---

**Developed by:** Smart Vehicle Team
**Version:** 1.0.0
