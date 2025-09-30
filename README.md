# HealthLab Starter

A Flutter application for healthcare data visualization and patient management, featuring real-time vital signs monitoring and FHIR patient data integration.

## Features

### 🏥 Patient Management

- **FHIR Integration**: Fetches patient data from HAPI FHIR test server
- **Patient List**: Browse and search through patient records
- **Detailed Views**: View comprehensive patient information including:
  - Patient demographics (name, gender, birth date)
  - Raw FHIR JSON data for technical analysis
  - Patient ID and metadata

### 📊 Real-time Vital Signs Monitoring

- **Live Heart Rate Chart**: Real-time heart rate visualization using fl_chart
- **SpO2 Monitoring**: Oxygen saturation levels tracking
- **WebSocket Integration**: Live data streaming from medical devices
- **Interactive Controls**: Connect/disconnect from data streams
- **Historical Data**: Rolling 60-second data window

### 🔧 Technical Features

- **Cross-platform**: Supports Android, iOS, Web, Windows, macOS, and Linux
- **Modern UI**: Material Design 3 with responsive layout
- **Real-time Updates**: WebSocket-based live data streaming
- **FHIR Compliance**: Healthcare interoperability standards
- **Modular Architecture**: Clean separation of services and UI components

## Screenshots

### Patient Management

![Patient List](assets/images/patient-list.png)
_Browse and search patient records from FHIR server_

![Patient Details](assets/images/patient-details.png)
_Detailed patient information with FHIR JSON data_

### Live Monitoring

![Live Vitals](assets/images/live-vitals.png)
_Real-time heart rate and SpO2 monitoring with interactive charts_

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Node.js (for WebSocket server)
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd healthlab_start
   ```

2. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

3. **Install Node.js dependencies**

   ```bash
   npm install
   ```

4. **Start the WebSocket server** (for live data simulation)

   ```bash
   node fake-ws-server/fake-ws-server.js
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

### Configuration

#### WebSocket Server

The app connects to a WebSocket server for live vital signs data. By default, it connects to:

- **Android Emulator**: `ws://10.0.2.2:8080`
- **Desktop/Web**: `ws://localhost:8080`

To change the WebSocket URL, modify the `url` property in `lib/service/ws_service.dart`:

```dart
String url = 'ws://your-server:8080';
```

#### FHIR Server

The app uses the public HAPI FHIR test server by default. To use a different FHIR server, update the `_base` URL in `lib/service/patient_service.dart`:

```dart
static const _base = 'https://your-fhir-server.com/baseR4';
```

## Project Structure

```
lib/
├── main.dart                 # Main application entry point
└── service/
    ├── patient_service.dart  # FHIR patient data service
    └── ws_service.dart       # WebSocket connection service

fake-ws-server/
└── fake-ws-server.js        # Node.js WebSocket server for testing

assets/
└── images/                  # App screenshots and images
```

## Dependencies

### Flutter Packages

- `http: ^1.5.0` - HTTP client for FHIR API calls
- `web_socket_channel: ^3.0.3` - WebSocket communication
- `fl_chart: ^1.1.1` - Charts and graphs for vital signs
- `intl: ^0.20.2` - Internationalization and date formatting

### Node.js Packages

- `ws: ^8.18.3` - WebSocket server implementation

## Usage

### Patient Management

1. Navigate to the "Patients" tab
2. Browse the list of patients fetched from the FHIR server
3. Tap on a patient to view detailed information
4. Review both human-readable data and raw FHIR JSON

### Live Monitoring

1. Navigate to the "Live Vitals" tab
2. Ensure the WebSocket server is running
3. Tap "Connect" to start receiving live data
4. Monitor real-time heart rate and SpO2 levels
5. View the rolling 60-second chart of heart rate data

## Development

### Adding New Features

- **New Data Sources**: Extend the service classes in `lib/service/`
- **UI Components**: Add new widgets in `lib/`
- **Charts**: Use fl_chart for additional data visualization
- **FHIR Resources**: Extend PatientService for other FHIR resource types

### Testing

```bash
# Run Flutter tests
flutter test

# Run with coverage
flutter test --coverage
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## API Reference

### PatientService

- `fetchPatients({int count = 20})` - Fetch patients from FHIR server
- `getDisplayName(Map<String, dynamic> patient)` - Extract display name from FHIR patient

### WsService

- `connect()` - Connect to WebSocket server
- `disconnect()` - Disconnect from WebSocket server
- `stream` - Stream of real-time vital signs data

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:

- Create an issue in the repository
- Check the Flutter documentation: https://docs.flutter.dev/
- FHIR documentation: https://www.hl7.org/fhir/

## Roadmap

- [ ] Add more vital signs (blood pressure, temperature)
- [ ] Implement patient search and filtering
- [ ] Add data export functionality
- [ ] Support for more FHIR resource types
- [ ] Offline data caching
- [ ] User authentication and authorization
- [ ] Integration with real medical devices
