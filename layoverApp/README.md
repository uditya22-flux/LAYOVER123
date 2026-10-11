<div align="center">

# 🧭 ROVEYA

### *Find your kind of places.*
**Skip the crowded five-star tourist traps. Visit an overlooked one-star legacy place and discover the one five-star treasure hidden inside it.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![OpenStreetMap](https://img.shields.io/badge/Maps-OpenStreetMap-7EBC6F?logo=openstreetmap&logoColor=white)](https://www.openstreetmap.org)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-4285F4)](https://github.com/uditya22-flux/LAYOVER123)
[![License](https://img.shields.io/badge/License-MIT-amber.svg)](LICENSE)

---

</div>

## 📖 Overview

Mainstream travel apps optimize for consensus: crowded cafes, sanitized tourist hubs, and five-star ratings driven by marketing. **Roveya** flips the script.

Roveya is a mobile discovery and challenge app that routes travelers to places with **1-star to 2-star legacy ratings**, specifically to experience their **verified 5-star standout feature** — whether it's a fragrant cardamom coffee in a cramped back alley, an untouched sunset ledge up an overgrown quarry trail, or the inspiring maker spirit behind a creaky metal gate.

---

## ✨ Key Features

### 🎯 Multi-Mood & Energy Matchmaking
- Select single or **multiple moods simultaneously** (*Calm, Curious, Adventurous, Reflective, Social*).
- Match your energy level (*Low, Medium, High*).
- **Unrestricted Distance Input**: Set any distance in meters or kilometers without artificial limits (quick chips: `400 m`, `500 m`, `1 km`, `3 km`, `5 km`, `10 km`, `25 km`).

### 🗺️ Smooth Live Navigation & Compass Bearing
- **Real-Time 60/120 FPS Movement**: Smooth cubic interpolation (`Curves.easeInOutCubic`) ensures walking animations never jump or stutter.
- **Shortest-Arc Compass Rotation**: Heading marker rotates naturally without 360° flipping.
- **Auto-Follow Camera**: Follows the user smoothly as they walk.
- **Smart Turn-by-Turn Routing**: OpenStreetMap & OSRM road navigation with automatic straight-line fallback.
- **Built-in Walk Simulation**: Test GPS routing and check-in without walking away from your desk.

### 📍 75-Meter Proximity Check-in
- Places remain locked until you physically arrive within **75 meters** (`kArrivalRadiusM`).
- Real-time distance countdown badge that unlocks the review camera upon arrival.
- Collect a unique digital travel stamp for every hidden gem you discover.

### 📹 Video Reviews with Real Thumbnails
- Record or upload short video reviews right from the location.
- **Authentic Video Previews**: Feed automatically displays the real frame of user-uploaded videos as cover thumbnails.
- Tap-to-play with frosted overlay controls.

### 🌐 Multi-Device Cloud Sync (Powered by Supabase)
- **Global Community Feed**: Reviews and video uploads sync instantly across all devices via Supabase Database and Storage.
- Pull-to-refresh and a dedicated top-bar refresh button for live updates.
- Offline-first fallback: uploaded reviews persist locally on-device so content is never lost.

### 🎨 Retro Travel Design System
- Warm parchment color palette: Ocean Teal (`#205B68`), Butter Gold (`#F6DDA5`), Coral Peach (`#F3A184`), and Warm Cream (`#FFF8ED`).
- Handcrafted vector **Compass Rose & 5-Star Beacon** logo widget.
- Clean animated **Splash Screen** welcoming travelers into the experience.

---

## 🏛️ Architecture & Directory Structure

```text
layover/
├── .gitignore                      # Root workspace ignore rules
├── README.md                       # Main documentation
└── layoverApp/                     # Flutter application root
    ├── lib/
    │   ├── main.dart               # App entry point (Splash -> Home)
    │   ├── config.dart             # API keys, arrival radius, Supabase config
    │   ├── theme.dart              # Color palette (C.ocean, C.cream) & fonts
    │   ├── models.dart             # Place, Review, RouteInfo data models
    │   ├── screens/
    │   │   ├── splash_screen.dart       # Animated brand intro splash screen
    │   │   ├── home_screen.dart         # Hero header, coastal art & action buttons
    │   │   ├── mood_screen.dart         # Multi-mood chips, energy, custom distance
    │   │   ├── suggestions_screen.dart  # Scored recommendation cards
    │   │   ├── navigation_screen.dart   # Live map, smoothed compass, GPS tracking
    │   │   ├── review_screen.dart       # Proximity check-in, video recorder & tagger
    │   │   └── feed_screen.dart         # Community reviews with video playback
    │   ├── services/
    │   │   ├── backend.dart             # Supabase client, offline sync & seed data
    │   │   ├── location_service.dart    # Geolocator, Haversine math & OSRM routes
    │   │   ├── osm_places.dart          # OpenStreetMap Overpass API integration
    │   │   └── google_places.dart       # Google Places API client (optional)
    │   └── widgets/
    │       ├── roveya_logo.dart         # Vector-drawn compass & star logo widget
    │       └── common.dart              # SoftCard, TagPill, StarRow, CoastPainter
    ├── supabase/
    │   ├── schema.sql              # Database tables, RLS policies, storage bucket
    │   └── add_tinkerspace.sql     # TinkerHub Calicut demo place & sync setup
    └── pubspec.yaml                # Dependencies & asset declarations
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.3.0 or later)
- Android Studio / VS Code with Flutter extension
- An Android device or emulator with Location permissions enabled

### 1. Clone the Repository
```bash
git clone https://github.com/uditya22-flux/LAYOVER123.git
cd LAYOVER123/layoverApp
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Verify Code Health
```bash
flutter analyze
flutter test
```

### 4. Run the Application
```bash
# Debug run on connected device
flutter run

# Or build debug APK
flutter build apk --debug
```

The APK will be generated at:
`layoverApp/build/app/outputs/flutter-apk/app-debug.apk`

---

## 🗄️ Supabase Backend Setup

Roveya uses Supabase for database storage and video streaming with anonymous public access.

### 1. Create a Supabase Project
1. Go to [supabase.com](https://supabase.com) and create a free project.
2. In **Project Settings** $\rightarrow$ **API**, copy your **Project URL** and **anon public key**.
3. Paste them into `layoverApp/lib/config.dart`:
```dart
const supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 2. Execute SQL Schema
Navigate to **SQL Editor** in your Supabase dashboard and run [`layoverApp/supabase/add_tinkerspace.sql`](layoverApp/supabase/add_tinkerspace.sql):

```sql
-- 1. Create Places Table
create table if not exists places (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text default '',
  lat double precision not null,
  lng double precision not null,
  legacy_rating numeric(2,1) not null default 1.0,
  mood_tags text[] default '{}',
  energy text not null default 'medium' check (energy in ('low','medium','high')),
  is_sample boolean not null default true,
  created_at timestamptz default now()
);

-- 2. Create Reviews Table
create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references places(id) on delete cascade,
  video_url text not null,
  rating int not null default 5 check (rating = 5),
  feature_tag text not null default 'Other',
  highlight text not null,
  created_at timestamptz default now()
);

-- 3. Public Permissions
alter table places enable row level security;
alter table reviews enable row level security;

create policy "places read" on places for select to public using (true);
create policy "places insert" on places for insert to public with check (true);
create policy "reviews read" on reviews for select to public using (true);
create policy "reviews insert" on reviews for insert to public with check (true);

-- 4. Storage Bucket for Video Uploads
insert into storage.buckets (id, name, public)
values ('review-videos', 'review-videos', true)
on conflict (id) do nothing;

create policy "videos read" on storage.objects for select to public using (bucket_id = 'review-videos');
create policy "videos upload" on storage.objects for insert to public with check (bucket_id = 'review-videos');
create policy "videos update" on storage.objects for update to public using (bucket_id = 'review-videos');
```

---

## 📱 Device Permissions

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

## 🎪 Demo Features for Presentations

- **TinkerSpace Calicut Gate**: Anchored ~290 m from current coordinates so selecting `400 m` or `500 m` highlights the spot immediately for a live walk-and-review demo.
- **Desk Testing Simulation**:
  - Tap **Simulate walk** in the navigation screen to test live GPS updates, compass rotation, and proximity countdown without leaving your seat.
  - Set `kDemoUnlock = true` in `lib/config.dart` to bypass the 75-meter requirement during live stage presentations.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

<div align="center">
<sub>Crafted with curiosity by the Roveya Team. Built for travelers who seek the extraordinary in the overlooked.</sub>
</div>
