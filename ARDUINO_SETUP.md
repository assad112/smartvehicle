# Arduino/ESP32 Setup for Sending Sensor Data

## Requirements

- ESP32 or Arduino UNO + ESP8266
- Sensors:
  - Temperature Sensor (DS18B20 or LM35)
  - Vibration Sensor
  - Fuel Level Sensor (optional)
  - Voltage Sensor for battery
  - Oil Pressure Sensor (optional)

## Required Libraries

```cpp
#include <WiFi.h>  // For ESP32
#include <FirebaseESP32.h>  // Or FirebaseArduino for Arduino
#include <DHT.h>  // For sensors
```

## Code Example (ESP32)

```cpp
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <time.h>

// WiFi Settings
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Firebase Settings
#define FIREBASE_HOST "YOUR_PROJECT_ID.firebaseio.com"
#define FIREBASE_AUTH "YOUR_FIREBASE_SECRET"

FirebaseData firebaseData;

// Sensor Settings
const int tempPin = A0;
const int batteryPin = A1;
const int fuelPin = A2;

// Vehicle ID (must match the ID in the database)
String vehicleId = "YOUR_VEHICLE_ID";

void setup() {
  Serial.begin(115200);
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");
  
  // Setup Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  
  // Setup time
  configTime(0, 0, "pool.ntp.org");
}

void loop() {
  // Read sensors
  float engineTemp = readTemperature();
  float batteryVoltage = readBatteryVoltage();
  float fuelLevel = readFuelLevel();
  float oilPressure = readOilPressure();
  
  // Determine status
  String status = calculateStatus(engineTemp, batteryVoltage, oilPressure);
  
  // Create JSON for data
  String sensorDataId = generateId(); // UUID or timestamp
  
  // Send data to Firebase
  String path = "/sensor_data/" + sensorDataId;
  
  FirebaseJson json;
  json.set("id", sensorDataId);
  json.set("vehicleId", vehicleId);
  json.set("engineTemperature", engineTemp);
  json.set("batteryVoltage", batteryVoltage);
  json.set("fuelLevel", fuelLevel);
  json.set("oilPressure", oilPressure);
  json.set("status", status);
  json.set("timestamp", getCurrentTime());
  
  if (Firebase.setJSON(firebaseData, path, json)) {
    Serial.println("Data sent successfully");
  } else {
    Serial.println("Error: " + firebaseData.errorReason());
  }
  
  // Wait 10 seconds before next reading
  delay(10000);
}

float readTemperature() {
  // Read engine temperature
  int reading = analogRead(tempPin);
  float voltage = reading * (3.3 / 4095.0);
  float temperature = (voltage - 0.5) * 100; // According to sensor type
  return temperature;
}

float readBatteryVoltage() {
  // Read battery voltage
  int reading = analogRead(batteryPin);
  float voltage = (reading / 4095.0) * 3.3 * 4; // According to divider
  return voltage;
}

float readFuelLevel() {
  // Read fuel level (0-100%)
  int reading = analogRead(fuelPin);
  float percentage = (reading / 4095.0) * 100;
  return percentage;
}

float readOilPressure() {
  // Read oil pressure
  // According to sensor type used
  return 45.0; // Example
}

String calculateStatus(float temp, float voltage, float pressure) {
  if (temp > 100 || voltage < 11.5 || pressure < 20) {
    return "CRITICAL";
  } else if (temp > 85 || voltage < 12.0) {
    return "WARNING";
  }
  return "OK";
}

String getCurrentTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    return "";
  }
  char timeString[64];
  strftime(timeString, sizeof(timeString), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(timeString);
}

String generateId() {
  // Generate unique ID (can use timestamp + random)
  return String(millis()) + String(random(1000, 9999));
}
```

## Firebase Settings

1. In Firebase Console, go to **Project Settings**
2. In **Service accounts**, download JSON file
3. Use `private_key` and `client_email` in the code

## Data Structure to Send

```json
{
  "id": "unique-id",
  "vehicleId": "vehicle-id-from-database",
  "engineTemperature": 85.5,
  "batteryVoltage": 12.6,
  "fuelLevel": 75.0,
  "vibrationLevel": 0.5,
  "oilPressure": 45.0,
  "status": "OK",
  "timestamp": "2024-01-01T12:00:00Z",
  "latitude": null,
  "longitude": null
}
```

## Important Notes

1. **Security:** Use Firebase Security Rules to restrict writes to `sensor_data` to authorized devices only
2. **Frequency:** Send data every 10-30 seconds as needed
3. **Vehicle ID:** Make sure `vehicleId` matches the vehicle ID in the database
4. **Calibration:** Calibrate sensors before actual use

## Troubleshooting

- **Not connecting to WiFi:** Check SSID and password
- **Not sending data:** Check Firebase credentials
- **Incorrect values:** Calibrate sensors
- **Connection loss:** Add retry logic on failure
