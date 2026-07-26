-- 1. OFFICIAL RACKETS TABLE (Static Domain Database)
CREATE TABLE IF NOT EXISTS rackets (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    brand TEXT CHECK (brand IN ('Yonex', 'Li-Ning', 'Victor', 'YONEX PROFESSIONAL', 'AERO', 'VOLT')),
    weight_class TEXT NOT NULL, -- e.g. '3U', '4U', '5U'
    weight_grams_range TEXT NOT NULL, -- e.g. '80-84g'
    balance_point_mm INT NOT NULL, -- e.g. 300
    balance_category TEXT NOT NULL, -- 'Head Heavy', 'Even Balance', 'Head Light'
    shaft_flexibility TEXT NOT NULL, -- 'Stiff', 'Medium', 'Flexible'
    price_myr NUMERIC(10, 2) NOT NULL,
    price_tier TEXT CHECK (price_tier IN ('Budget', 'Mid-Range', 'Premium')),
    asset_image_path TEXT NOT NULL, -- Local asset path: 'assets/images/astrox99.png'
    match_rating INT NOT NULL DEFAULT 80,
    match_explanation TEXT NOT NULL DEFAULT ''
);

-- 2. USER PROFILES TABLE (Quiz Answers & Player State)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    skill_level INT NOT NULL DEFAULT 1, -- Matches AppState int index (0=Beginner, 1=Intermediate, 2=Advanced)
    matches INT NOT NULL DEFAULT 0,
    win_rate INT NOT NULL DEFAULT 0,
    power_index INT NOT NULL DEFAULT 50,
    control INT NOT NULL DEFAULT 50,
    playing_style TEXT DEFAULT 'All-Rounder',
    has_low_strength BOOLEAN DEFAULT FALSE,
    match_type TEXT DEFAULT 'Singles',
    preferred_budget_tier TEXT DEFAULT 'Mid-Range',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop policy if exists and create
DROP POLICY IF EXISTS "Users can view and edit own profile" ON profiles;
CREATE POLICY "Users can view and edit own profile" ON profiles 
FOR ALL USING (auth.uid() = id);

-- 3. C2C MARKETPLACE TABLE (Pre-Owned Gear)
CREATE TABLE IF NOT EXISTS market_listings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    seller_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    brand TEXT CHECK (brand IN ('Yonex', 'Li-Ning', 'Victor', 'Other')),
    price_myr NUMERIC(10, 2) NOT NULL,
    item_condition TEXT NOT NULL, -- e.g. 'Used - Like New', 'Minor Paint Chips'
    location TEXT NOT NULL, -- e.g. 'Subang Jaya', 'Kuala Lumpur'
    image_url TEXT NOT NULL, -- Public Supabase Storage URL
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
ALTER TABLE market_listings ENABLE ROW LEVEL SECURITY;

-- Drop policies if exist and create
DROP POLICY IF EXISTS "Anyone can view market listings" ON market_listings;
CREATE POLICY "Anyone can view market listings" ON market_listings FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can create own listings" ON market_listings;
CREATE POLICY "Users can create own listings" ON market_listings FOR INSERT WITH CHECK (auth.uid() = seller_id);

-- 4. SUPABASE STORAGE BUCKET FOR MARKETPLACE IMAGES
INSERT INTO storage.buckets (id, name, public)
VALUES ('marketplace-images', 'marketplace-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage object policies
DROP POLICY IF EXISTS "Public Read Access" ON storage.objects;
CREATE POLICY "Public Read Access" ON storage.objects
FOR SELECT USING (bucket_id = 'marketplace-images');

DROP POLICY IF EXISTS "Authenticated Insert Access" ON storage.objects;
CREATE POLICY "Authenticated Insert Access" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'marketplace-images' AND auth.role() = 'authenticated');
