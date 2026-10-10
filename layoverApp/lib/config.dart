// Fill these from Supabase -> Project Settings -> API
const supabaseUrl = 'https://djmlwolaciymzxzyxqkq.supabase.co';
const supabaseAnonKey = 'sb_publishable_fr0zC8Q3OiVgM6DDTinZVA_Hh5GmaIo';

bool get isSupabaseConfigured =>
    supabaseUrl.startsWith('http') &&
    supabaseAnonKey.isNotEmpty;

/// Default distance on the slider (user can change it, in km).
const kDefaultRadiusKm = 10.0;
const kMinRadiusKm = 1.0;
const kMaxRadiusKm = 50.0;

/// How close (meters) the user must be before check-in unlocks.
const kArrivalRadiusM = 75.0;

/// Set true ONLY for demos at a desk: check-in button is always enabled.
const kDemoUnlock = false;

/// Optional: Google Places API Key (Places API New).
/// If left as 'YOUR_GOOGLE_API_KEY' or empty, the app uses Supabase / local curated spots.
const googleApiKey = 'YOUR_GOOGLE_API_KEY';

bool get useGoogle =>
    googleApiKey.isNotEmpty &&
    googleApiKey != 'YOUR_GOOGLE_API_KEY';

/// Filter for low-rated places from Google Places (e.g. <= 2.5 stars).
const kMaxLegacyRating = 2.5;

/// Minimum review count on Google Places to ensure genuine low ratings.
const kMinRatingCount = 3;
