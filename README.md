## Car — Mini Ride‑Hailing Demo (Flutter)

![Mockup](https://github.com/user-attachments/assets/24a71453-c4d6-4f0f-ab27-22c0eaf97480)

A small ride-hailing demo built with Flutter, focused on Web and Windows. No API keys required. State is managed with BLoC; dependencies are wired via a simple injector.

- Platforms: Web, Windows
- Status: Demo/Prototype
- Tech: Flutter (stable) • Dart SDK >= 3.9.0 • BLoC

# Features
- View current location on the map
- Search and select pickup/drop-off
- Preview the route (polyline, distance/ETA)
- Choose a car type
- Manage ride status via bottom sheets (start/cancel)
- Responsive layout for Web/Windows

# Tech Stack
- Flutter + Dart
- State management: BLoC (flutter_bloc)
- Utilities: equatable
- Theming and shared UI components
- Simple DI (injector)

# Getting Started
Prerequisites
- Flutter (stable) installed and on PATH
- Dart SDK compatible with >= 3.9.0 (bundled with Flutter)
- For Windows desktop:
  - flutter config --enable-windows-desktop
  - Visual Studio (not VS Code) with “Desktop development with C++” workload

# Install
Clone the repo
install :
```
flutter pub get
```
Run (development)
Web (Chrome):
```
flutter run -d chrome
```
Windows:
```
flutter run -d windows
```
Build (release)
Web:
```
flutter build web --release
```
Output: build/web
Windows:
```
flutter build windows --release
```
output:
```
 C:\Users\USER\Projects<PROJECT>\build\windows\runner\Release
```
# Configuration
No environment variables or API keys are required for this demo.
A static map image is used for demonstration purposes.

# Screenshots
<img width="282" height="518" alt="two" src="https://github.com/user-attachments/assets/4aa990a3-a794-4120-9c94-e17b393b46dd" />
<img width="294" height="516" alt="one" src="https://github.com/user-attachments/assets/b3c6e0d3-8df5-4853-adf9-ba228dd71a4e" />

# How It Works (High-level)
- Each feature (map, route, search, car, sheet) is managed by its own BLoC for clear separation of concerns.
- A simple injector wires dependencies at app startup.
- Screens consume BLoCs and render a responsive UI for Web/Windows.
