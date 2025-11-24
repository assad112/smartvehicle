# Firebase Setup for the Project

## Firebase Setup Steps

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., smart-vehicle)
4. Follow the steps to complete project creation

### 2. Add Android App

1. In Firebase Console, click the Android icon
2. Enter Package name: `com.example.smartvehicle`
3. Download `google-services.json` file
4. Place the file in: `android/app/google-services.json`

### 3. Add iOS App (Optional)

1. In Firebase Console, click the iOS icon
2. Enter Bundle ID
3. Download `GoogleService-Info.plist` file
4. Place the file in: `ios/Runner/GoogleService-Info.plist`

### 4. Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click **Get started**
3. Enable **Email/Password** provider
4. Save changes

### 5. Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for testing)
4. Choose database location (e.g., us-central1)
5. Click **Enable**

### 6. Setup Firestore Rules (Security Rules)

Replace the default rules with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Vehicles collection
    match /vehicles/{vehicleId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && 
        request.resource.data.ownerId == request.auth.uid;
      allow delete: if request.auth != null && 
        (resource.data.ownerId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
    }
    
    // Maintenance collection
    match /maintenance/{maintenanceId} {
      allow read, write: if request.auth != null;
    }
    
    // Sensor data collection
    match /sensor_data/{sensorId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Can restrict this to IoT devices only
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### 7. Setup Firebase Messaging (For Notifications)

1. In Firebase Console, go to **Cloud Messaging**
2. Add Server Key if needed
3. For Android, make sure `google-services.json` is added correctly

### 8. Android Setup

In the file `android/app/build.gradle.kts`, make sure you have:

```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

In the file `android/build.gradle.kts`, add:

```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")
}
```

### 9. Test Connection

1. Run the application
2. Try registering a new account
3. Check Firebase Console that data appears in Firestore

## Required Collections

The application uses these Collections:

1. **users** - User data
2. **vehicles** - Vehicle data
3. **maintenance** - Maintenance records
4. **sensor_data** - Sensor data
5. **notifications** - Notifications

## Create Admin User

To create an admin user:

1. Register a regular user from the application
2. In Firebase Console, go to Firestore
3. Open the user document in the `users` collection
4. Change `isAdmin` from `false` to `true`
5. Save changes

Now the user can login as Admin from the Admin Login screen.

## Notes

- Make sure `google-services.json` is in the correct path
- Make sure Email/Password authentication is enabled
- Make sure Firestore Database is enabled
- For testing, you can use Test Mode, but for production use appropriate Security Rules
