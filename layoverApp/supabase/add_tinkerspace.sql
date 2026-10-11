-- ==============================================================================
-- Add TinkerHub / TinkerSpace Calicut and Enable Multi-Device Permissions
-- Instructions: Run this in Supabase -> SQL Editor -> "Run"
-- ==============================================================================

-- 1. Remove dummy butterfly test reviews so only real user-uploaded videos show
delete from reviews where video_url ilike '%butterfly%' or video_url ilike '%bee%';

-- 2. Clean up previous tinker place test entries if any
delete from places where name ilike '%tinker%';

-- 3. Insert TinkerHub Calicut Gate
insert into places (
  name,
  description,
  lat,
  lng,
  legacy_rating,
  mood_tags,
  energy,
  is_sample
) values (
  'TinkerHub Calicut Gate',
  '1-star reviews complain about the creaky metal gate and narrow path. But walk up to the gate for the cool breeze, open courtyard, and inspiring maker community spirit at TinkerHub / TinkerSpace Calicut.',
  11.2770,
  75.8215,
  1.0,
  array['calm', 'curious', 'adventurous', 'reflective', 'social'],
  'low',
  false
);

-- 4. Enable multi-device public permissions for places and reviews
alter table places enable row level security;
alter table reviews enable row level security;

drop policy if exists "places read" on places;
create policy "places read" on places for select to public using (true);

drop policy if exists "places insert" on places;
create policy "places insert" on places for insert to public with check (true);

drop policy if exists "reviews read" on reviews;
create policy "reviews read" on reviews for select to public using (true);

drop policy if exists "reviews insert" on reviews;
create policy "reviews insert" on reviews for insert to public with check (true);

-- 5. Storage bucket and policies for video uploads across all devices
insert into storage.buckets (id, name, public)
values ('review-videos', 'review-videos', true)
on conflict (id) do nothing;

drop policy if exists "videos read" on storage.objects;
create policy "videos read" on storage.objects for select to public using (bucket_id = 'review-videos');

drop policy if exists "videos upload" on storage.objects;
create policy "videos upload" on storage.objects for insert to public with check (bucket_id = 'review-videos');

drop policy if exists "videos update" on storage.objects;
create policy "videos update" on storage.objects for update to public using (bucket_id = 'review-videos');
