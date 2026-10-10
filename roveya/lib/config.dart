// Fill these from Supabase -> Project Settings -> API
const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

/// Default distance on the slider (user can change it, in km).
const kDefaultRadiusKm = 10.0;
const kMinRadiusKm = 1.0;
const kMaxRadiusKm = 50.0;

/// How close (meters) the user must be before check-in unlocks.
const kArrivalRadiusM = 75.0;

/// Set true ONLY for demos at a desk: check-in button is always enabled.
const kDemoUnlock = false;
