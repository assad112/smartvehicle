# ⚠️ Firebase Setup Required Now

## Current Problem
The application cannot build without the `google-services.json` file.

## Quick Solution (5 minutes)

### Step 1: Create Firebase Project
1. Go to: https://console.firebase.google.com/
2. Click **Add project**
3. Enter project name: `smart-vehicle`
4. Follow the steps to complete creation

### Step 2: Add Android App
1. In Firebase Console, click the **Android** icon 🟢
2. Enter:
   - **Package name**: `com.example.smartvehicle`
   - **App nickname**: Smart Vehicle (optional)
3. Click **Register app**

### Step 3: Download google-services.json
1. Click **Download google-services.json**
2. **Copy the file** to:
   ```
   android/app/google-services.json
   ```
   ⚠️ **Important**: The file name must be exactly `google-services.json` (without `.placeholder`)

### Step 4: Enable Google Services Plugin
Open the file `android/app/build.gradle.kts` and **uncomment** the line:
```kotlin
id("com.google.gms.google-services")
```

It should become:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← Uncomment here
}
```

### Step 5: Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click **Get started**
3. Enable **Email/Password**
4. Save

### Step 6: Create Firestore Database
1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode**
4. Choose location: `us-central1` (or any nearby location)
5. Click **Enable**

### Step 7: Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

## ✅ After Setup
- The application will work fully
- You can login and register
- All features will work

## 📝 Notes
- **Package name** must be exactly: `com.example.smartvehicle`
- The `google-services.json` file must be in `android/app/`
- After adding the file, uncomment the plugin in `build.gradle.kts`

## 🆘 If You Encounter Problems
1. Make sure the file is in the correct location
2. Make sure you uncommented the plugin
3. Run `flutter clean` then `flutter pub get`
4. Restart Android Studio
