-- Run this whole file in Supabase -> SQL Editor

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

create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references places(id) on delete cascade,
  video_url text not null,
  rating int not null default 5 check (rating = 5),
  feature_tag text not null default 'Other',
  highlight text not null,
  created_at timestamptz default now()
);

create index if not exists reviews_feature_idx on reviews(feature_tag);

-- No auth: anonymous users can read everything and add reviews.
alter table places enable row level security;
alter table reviews enable row level security;

create policy "places read" on places for select using (true);
create policy "reviews read" on reviews for select using (true);
create policy "reviews insert" on reviews for insert with check (true);

-- Storage bucket for videos (public read)
insert into storage.buckets (id, name, public)
values ('review-videos', 'review-videos', true)
on conflict (id) do nothing;

create policy "videos read" on storage.objects for select using (bucket_id = 'review-videos');
create policy "videos upload" on storage.objects for insert with check (bucket_id = 'review-videos');

-- SAMPLE PLACES. Coordinates are placeholders around Tirurangadi, Kerala.
-- Replace them with real spots you have checked (see README). is_sample=true shows a "Sample data" tag in the app.
insert into places (name, description, lat, lng, legacy_rating, mood_tags, energy) values
('Sample Spot 1: Quiet river bend', 'Sample entry. Replace with a real low-rated spot.', 11.0420, 75.9250, 1.0, '{calm,reflective}', 'low'),
('Sample Spot 2: Old market lane', 'Sample entry. Replace with a real low-rated spot.', 11.0610, 75.9330, 1.5, '{curious,social}', 'low'),
('Sample Spot 3: Overgrown hill path', 'Sample entry. Replace with a real low-rated spot.', 11.0700, 75.9100, 1.0, '{adventurous,reflective}', 'high'),
('Sample Spot 4: Forgotten tea shop', 'Sample entry. Replace with a real low-rated spot.', 11.0500, 75.9400, 2.0, '{social,curious}', 'medium'),
('Sample Spot 5: Backwater jetty', 'Sample entry. Replace with a real low-rated spot.', 11.0300, 75.9000, 1.0, '{calm,curious}', 'medium'),
('Sample Spot 6: Disused railway cutting', 'Sample entry. Replace with a real low-rated spot.', 11.0800, 75.9500, 1.5, '{adventurous,curious}', 'high');
