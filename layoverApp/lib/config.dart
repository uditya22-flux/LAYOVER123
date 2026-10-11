// Fill these from Supabase -> Project Settings -> API
const supabaseUrl = 'https://djmlwolaciymzxzyxqkq.supabase.co';
const supabaseAnonKey = 'sb_publishable_fr0zC8Q3OiVgM6DDTinZVA_Hh5GmaIo';

bool get isSupabaseConfigured =>
    supabaseUrl.startsWith('http') &&
    supabaseAnonKey.isNotEmpty &&
    !supabaseUrl.contains('YOUR_PROJECT');

/// Default distance (in km). No minimum or maximum limits are enforced.
const kDefaultRadiusKm = 1.0;

/// How close (meters) the user must be before check-in unlocks.
const kArrivalRadiusM = 75.0;

/// Set true ONLY for demos at a desk: check-in button is always enabled.
const kDemoUnlock = false;

// ---- Google Places (optional). Leave as is to use only Supabase places. ----
const googleApiKey = 'YOUR_GOOGLE_API_KEY';
bool get useGoogle => googleApiKey != 'YOUR_GOOGLE_API_KEY';

/// A place counts as "1-star" if its Google rating is at or below this.
const kMaxLegacyRating = 2.0;

/// Ignore places with fewer Google ratings than this (avoids a single angry review).
const kMinRatingCount = 5;