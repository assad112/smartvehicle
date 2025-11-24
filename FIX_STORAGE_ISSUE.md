# Fix Insufficient Storage Issue in Emulator

## Problem
```
INSTALL_FAILED_INSUFFICIENT_STORAGE: Failed to override installation location
```

## Solutions

### Solution 1: Manually Delete Old App from Emulator

1. Open the Emulator
2. Go to **Settings**
3. Go to **Apps**
4. Search for the app `smartvehicle` or `com.example.smartvehicle`
5. Click on the app then **Uninstall**

### Solution 2: Wipe Emulator Data

1. In Android Studio, go to **Tools** > **Device Manager**
2. Click the arrow next to the emulator
3. Select **Wipe Data**
4. Restart the emulator

### Solution 3: Increase Emulator Storage

1. In Android Studio, go to **Tools** > **Device Manager**
2. Click **Edit** (pencil icon) next to the emulator
3. In **Show Advanced Settings**
4. Increase **Internal Storage** to at least 4GB
5. Save and restart the emulator

### Solution 4: Use a New Emulator

1. In Android Studio, go to **Tools** > **Device Manager**
2. Click **Create Device**
3. Select a new device
4. Make sure **Internal Storage** is at least 4GB
5. Create the new emulator

### Solution 5: Use ADB from Command Line

If ADB is installed in PATH:

```bash
# List installed apps
adb shell pm list packages | grep smartvehicle

# Uninstall the app
adb uninstall com.example.smartvehicle

# Or uninstall all old apps
adb shell pm uninstall com.example.smartvehicle
```

### Solution 6: Free Up Emulator Space

1. In the emulator, go to **Settings** > **Storage**
2. Click **Free up space** or **Clear cache**
3. Delete unused apps

## After Applying Solution

After applying any of the solutions above, try running the app again:

```bash
flutter run
```

## Note

If the problem persists, try:
- Restarting the emulator
- Restarting Android Studio
- Creating a new emulator with larger storage
