---
name: underrated-mobile-app
description: Core architecture, state management, styling tokens, and navigation flow for UnderRated / Roveya travel mobile app.
---

# UnderRated / Roveya Mobile App Architecture & Design Tokens

This document details the complete 6-screen architecture, design tokens, navigation flow, and state model for the **UnderRated** mobile application.

---

## 1. Design System & Theme Tokens

### Color Palette (Roveya Sea Glass & Cream Theme)
- **Primary / Ocean**: `#205B68` (Headers, main action buttons, active navigation states)
- **Secondary / Sea Glass**: `#3F8490` (Accents, user markers, secondary pills)
- **Background / Cream**: `#FFF8ED` (Scaffold background, bottom sheet surface)
- **Accent / Peach**: `#F3A184` (Warning pills, destination pin markers, strike-through highlights)
- **Accent / Butter**: `#F6DDA5` (Selected chip fills, badge highlights, stamp backgrounds)
- **Accent / Sage**: `#9AAE8B` (Match badges, verification tags)
- **Surface / Mist**: `#DCEBF0` (Card fills, unselected wells, video placeholder background)
- **Text / Ink**: `#25383A` (Primary body and heading text)

### Typography & Fonts
- **Headings & Title Accent**: `GoogleFonts.caveat()` (Handwritten aesthetic, 26pt to 54pt, weight 700)
- **Body & Controls**: `GoogleFonts.nunito()` (Clean legible sans-serif, 13pt to 18pt, weight 400 to 800)

### UI Shapes & Elevation
- **Card Corners**: `BorderRadius.circular(16)`
- **Button / Input Corners**: `BorderRadius.circular(14)`
- **Pills & Chips**: `BorderRadius.circular(9999)` / `BorderRadius.circular(8)`
- **Target Resolution**: 393 × 852 px (Mobile Portrait Frame)

---

## 2. Core 6-Screen User Architecture & Navigation Flow

```
                                [1. Landing Hub (Home)]
                                     /          \
                                    /            \
                (Option A: Challenge)            (Option B: Explore)
                                 /                  \
            [2. Solo Mood Check (Quiz)]     [6. Community Review Feed]
                         |                            ^
                         v                            |
            [3. Curated Recommendations]               |
                         |                            |
                         v                            |
            [4. Map & Waypoint Nav]                   |
                         |                            |
                         v                            |
            [5. Proof of Visit / Review] -------------+ (Publish)
```

---

## 3. Screen Specifications & Functional Requirements

### Screen 1: Dual-Path Landing Hub (`home_screen.dart`)
- **Header**: App title ("Roveya" / "UnderRated"), location chip (`Kochi, India • 10 km radius`), profile avatar icon.
- **Hero Banner & Slogan**: "Worst Rated. Best Stories." / "Skip the crowded five-star spots. Visit a one-star place and find the one five-star thing hiding inside it."
- **Gamified Level/Streak Card**: Explorer Level (Lv. 4), XP progress bar, +5 Day Streak pill.
- **Split Cards / Actions**:
  - **Option A (Take the Challenge)**: Leads to `MoodScreen` (Quiz).
  - **Option B (Explore Discovered Gems)**: Leads to `FeedScreen` (Community Feed).
- **Bottom Navigation Dock**: Home (Active), Map, Saved.

### Screen 2: Solo Mood & Vibe Check (`mood_screen.dart`)
- **Header**: Step indicator (`Step 1 of 2`), title: "What's your exploration vibe today?"
- **Multi-select Vibe Chips**: Seeking Chaos, Quiet & Weird, Nostalgic Run-Down, Hungry for Risks, Photogenic Decay, Accidental Comedy.
- **Energy Selectors**: Low, Medium, High.
- **Proximity Filter Slider**: 1 km to 50 km (default 10 km).
- **Primary CTA**: `Find My 1-Star Mission →` (Navigates to `SuggestionsScreen`).

### Screen 3: Curated 1-Star Recommendations (`suggestions_screen.dart`)
- **Header**: "One-star spots within X km".
- **Card Stack**: Scrollable card deck showing legacy rating (`★ 1.2`), distance/time tags (`3.4 km • 12 min away`), place name, description, "Matches your mood" tag.
- **Action CTA**: `Inspect on Map` (Navigates to `NavigationScreen`).
- **Floating Randomizer**: `Surprise Me` button picking a random 1-star mission.

### Screen 4: Map & Waypoint Navigation (`navigation_screen.dart`)
- **Map View**: Full-bleed `flutter_map` interactive OpenStreetMap view with custom user location marker (Sea Glass dot) & place pin marker (Peach pin).
- **Turn-by-turn Route**: OSRM polyline routing with distance readout and fallback straight-line route.
- **Bottom Sheet**: Distance remaining (`1.8 km to target`) and dynamic proximity lock button.
- **Proximity Security**: Button disabled (`Locked - Get within 75m`) vs enabled (`I Have Arrived • Start Video Review 🎥`).

### Screen 5: Proof of Visit & Video Review Submission (`review_screen.dart`)
- **Viewfinder**: Video recording simulation (Camera pick / Gallery 60s upload) with live preview player.
- **Inputs**:
  - "The 1-Star Reality" text notes.
  - "The 5-Star Saving Grace" pill selector (Views, Food, Quiet, Culture, Nature, Craft, People, Other).
  - 5-Star rating slider for the redeeming feature.
- **Publish Action**: `Publish to UnderRated Feed` -> triggers celebratory Stamp Collected modal and returns to main hub.

### Screen 6: Community Video Review Feed (`feed_screen.dart`)
- **Filter Bar**: Chips for Top Flipped, Near Me, Food, Views, Culture, etc.
- **Layout**: 2-column masonry / reel card list showing author badges, verification checkmarks, official rating vs community rating (`★ 1.1` vs `★ 5.0`), helpful quirk counters, and tap-to-play video preview.
- **Bottom Navigation Dock**: Home, Explore, Saved.

---

## 4. Backend & Data Contracts

### Tables Structure (Supabase / Local Fallback Mock)
- `places`: `id`, `name`, `description`, `lat`, `lng`, `legacy_rating`, `mood_tags`, `energy`, `is_sample`
- `reviews`: `id`, `place_id`, `video_url`, `rating`, `feature_tag`, `highlight`, `upvotes`, `created_at`

### Distance & Proximity Logic
- Distance formula: `Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000` (in km).
- Arrival radius: `distM <= 75.0` meters (or `kDemoUnlock = true`).
