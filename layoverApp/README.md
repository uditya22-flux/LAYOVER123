# Roveya (Layover)

[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.3.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.3.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-4285F4)](https://github.com/uditya22-flux/LAYOVER123)
[![License](https://img.shields.io/badge/License-MIT-amber.svg)](LICENSE)

**Roveya** is a Flutter mobile exploration app that steers travelers away from crowded tourist consensus to discover **1-star legacy rated places** specifically for their **verified 5-star standout feature** (views, quiet, coffee, culture, people).

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Database Setup (Supabase)](#database-setup-supabase)
- [Common Commands](#common-commands)
- [Build APK](#build-apk)
- [Device Permissions](#device-permissions)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## Features

- **Mood & Energy Selection**: Choose multiple moods (*Calm, Curious, Adventurous, Reflective, Social*) and energy level with unrestricted distance input (default `500 m`, quick chips: `400 m`, `500 m`, `1 km`, `3 km`, `5 km`, `10 km`, `25 km`).
- **Live Navigation & Compass**: 60/120 FPS interpolated arrow movement, shortest-arc compass rotation auto-following user heading, turn-by-turn road routing via OpenStreetMap / OSRM, and built-in walk simulation for desk testing.
- **75m Proximity Check-in**: Arrive within 75 meters of the destination to unlock check-in and digital collectible stamps.
- **Video Proof Reviews with Real Thumbnails**: Record video reviews on-site; the community feed displays the actual video frame as cover thumbnail with tap-to-play playback.
- **Multi-Device Cloud Sync**: Powered by Supabase Database and Storage with real-time community feed and one-tap refresh.
- **Branded Design**: Custom vector compass rose & 5-star discovery logo widget and animated splash screen.
- **TinkerSpace Calicut Demo Spot**: Pre-configured demo destination anchored ~290 m from Kozhikode campus for live walking demos.

---

## Tech Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | Flutter (Material 3) |
| **Language** | Dart |
| **Backend & Auth** | Supabase (PostgreSQL + Storage) |
| **Mapping & Routing** | OpenStreetMap (flutter_map) + OSRM |
| **Geolocation** | geolocator (High Accuracy GPS) |
| **Media Playback** | video_player |
| **Typography** | google_fonts (Nunito + Caveat) |

---

## Project Structure

```text
layover/
├── .gitignore                      # Root workspace gitignore
├── README.md                       # Repository documentation
└── layoverApp/                     # Flutter mobile application
    ├── lib/
    │   ├── main.dart               # App entry point (Splash -> Home)
    │   ├── config.dart             # API keys, arrival radius & flags
    │   ├── theme.dart              # Theme palette & typography
    │   ├── models.dart             # Place, Review, RouteInfo models
    │   ├── screens/
    │   │   ├── splash_screen.dart       # Animated brand intro splash
    │   │   ├── home_screen.dart         # Home landing & navigation actions
    │   │   ├── mood_screen.dart         # Multi-mood & distance selection
    │   │   ├── suggestions_screen.dart  # Scored place recommendations
    │   │   ├── navigation_screen.dart   # Live map, smoothed compass, GPS
    │   │   ├── review_screen.dart       # Proximity check-in & video recording
    │   │   └── feed_screen.dart         # Community reviews with video playback
    │   ├── services/
    │   │   ├── backend.dart             # Supabase client, offline sync & persistence
    │   │   ├── location_service.dart    # GPS location, distance & OSRM routing
    │   │   ├── osm_places.dart          # OpenStreetMap Overpass API client
    │   │   └── google_places.dart       # Optional Google Places integration
    │   └── widgets/
    │       ├── roveya_logo.dart         # Vector-drawn compass logo widget
    │       └── common.dart              # Shared cards, pills, stars & painters
    ├── supabase/
    │   ├── schema.sql              # Database tables, RLS policies, storage bucket
    │   └── add_tinkerspace.sql     # TinkerHub Calicut demo place & sync setup
    └── pubspec.yaml                # Flutter packages & dependencies
```

---

## Prerequisites

- **Flutter SDK**: `>=3.3.0 <4.0.0`
- **Dart SDK**: bundled with Flutter
- **Android Studio** or **VS Code** with Flutter extension
- An Android device or emulator with Location permissions enabled

---

## Quick Start

```bash
# 1. Clone repository
git clone https://github.com/uditya22-flux/LAYOVER123.git
cd LAYOVER123/layoverApp

# 2. Install dependencies
flutter pub get

# 3. Analyze code
flutter analyze

# 4. Run application
flutter run
```

---

## Configuration

Update settings in [`layoverApp/lib/config.dart`](layoverApp/lib/config.dart):

```dart
const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

// Default distance radius in km (no limits enforced)
const kDefaultRadiusKm = 1.0;

// Proximity distance to unlock check-in (in meters)
const kArrivalRadiusM = 75.0;

// Set true ONLY for desk presentations (bypasses 75m arrival requirement)
const kDemoUnlock = false;
```

---

## Database Setup (Supabase)

1. Create a project at [supabase.com](https://supabase.com).
2. Go to **SQL Editor** in the Supabase Dashboard.
3. Run [`layoverApp/supabase/schema.sql`](layoverApp/supabase/schema.sql) to create:
   - `places` table with public read policy
   - `reviews` table with public read/insert policies
   - `review-videos` public storage bucket with upload policies
4. Run [`layoverApp/supabase/add_tinkerspace.sql`](layoverApp/supabase/add_tinkerspace.sql) to add the TinkerHub Calicut demo place and permissions.

---

## Common Commands

Run from `layoverApp/`:

| Command | Action |
| :--- | :--- |
| `flutter pub get` | Install package dependencies |
| `flutter analyze` | Run static analysis / linter |
| `flutter test` | Run automated unit tests |
| `flutter run` | Launch app on connected device |
| `flutter build apk --debug` | Build debug APK |
| `flutter build apk --release` | Build release APK |

---

## Build APK

```bash
cd layoverApp
flutter build apk --debug
```

The APK binary will be generated at:
```text
layoverApp/build/app/outputs/flutter-apk/app-debug.apk
```

To build a release APK:
```bash
flutter build apk --release
```

---

## Device Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find standout hidden spots near you.</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access so you can record your 5-star video review.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to capture audio with your video review.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Pick an existing video from your gallery to share as a review.</string>
```

---

## Troubleshooting

- **Supabase connection issue**: Confirm `supabaseUrl` and `supabaseAnonKey` in `config.dart`.
- **Location disabled**: Turn on GPS and grant High Accuracy location permission in phone settings.
- **Desk demo on stage**: Use the **Simulate walk** button on the map screen or set `kDemoUnlock = true` in `config.dart`.
- **Video preview**: Video thumbnails decode the actual video frame on mount; tap the card to play.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
