# Roveya (Flutter + Supabase, no auth)

Flow: Home -> Mood -> 1-star spots (within the km the user picks) -> Map + check-in -> Video review -> Community feed.

## 1. Supabase (5 min)
1. Create a project at supabase.com.
2. SQL Editor -> paste and run `supabase/schema.sql`.
3. Project Settings -> API: copy the URL and anon key into `lib/config.dart`.
4. Edit the `places` table rows: put in real spots near where you will demo (lat/lng from Google Maps: long-press a point). Set `is_sample` to false for real ones.

## 2. Flutter (5 min)
```bash
flutter create --platforms=android,ios --org com.example --project-name roveya .
rm test/widget_test.dart
flutter pub get
flutter run
```
Run `flutter create .` INSIDE this folder; it adds android/ and ios/ without touching lib/.

## 3. Permissions
Android: `android/app/src/main/AndroidManifest.xml`, inside `<manifest>` above `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```
Also in `android/app/build.gradle(.kts)` set `minSdk = 21` or higher.

iOS: `ios/Runner/Info.plist`, inside the top `<dict>`:
```xml
<key>NSLocationWhenInUseUsageDescription</key><string>Find one-star spots near you</string>
<key>NSCameraUsageDescription</key><string>Record your video review</string>
<key>NSMicrophoneUsageDescription</key><string>Record audio for your review</string>
<key>NSPhotoLibraryUsageDescription</key><string>Pick a video review</string>
```

## 4. Demo tips
- Distance is chosen by the user on the mood screen (slider, range set in `lib/config.dart`). Also tune `kArrivalRadiusM`.
- Can't physically reach a spot on stage? Set `kDemoUnlock = true` (check-in always enabled). Turn it off for real use.
- Emulator: set a mock location near your seeded places.
