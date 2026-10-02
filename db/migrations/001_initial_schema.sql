
-- Extends auth.users with app-specific user preferences
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  preferred_language TEXT NOT NULL DEFAULT 'en' CHECK (preferred_language IN ('en', 'am')),
  theme_mode TEXT NOT NULL DEFAULT 'system' CHECK (theme_mode IN ('system', 'light', 'dark')),
  cloud_sync_enabled BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast email lookups
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- Comment
COMMENT ON TABLE public.profiles IS 'User profiles extending auth.users with app preferences';

-- Stores all coffee bean scan results with full prediction data
CREATE TABLE IF NOT EXISTS public.scans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  client_scan_id TEXT NOT NULL,
  
  -- Prediction results
  predicted_class TEXT NOT NULL CHECK (predicted_class IN ('defect', 'longberry', 'peaberry', 'premium')),
  confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
  
  -- Full probability distribution
  probability_defect REAL NOT NULL CHECK (probability_defect >= 0 AND probability_defect <= 1),
  probability_longberry REAL NOT NULL CHECK (probability_longberry >= 0 AND probability_longberry <= 1),
  probability_peaberry REAL NOT NULL CHECK (probability_peaberry >= 0 AND probability_peaberry <= 1),
  probability_premium REAL NOT NULL CHECK (probability_premium >= 0 AND probability_premium <= 1),
  
  -- OOD detection flag
  is_ood BOOLEAN NOT NULL DEFAULT false,
  
  -- Image storage
  image_url TEXT,              -- Supabase Storage URL (cloud)
  image_local_path TEXT,       -- Device path (not synced, metadata only)
  
  -- User notes
  notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  synced_at TIMESTAMPTZ,
  
  -- Ensure client_scan_id is unique per user (for offline deduplication)
  CONSTRAINT unique_user_client_scan UNIQUE (user_id, client_scan_id)
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_scans_user_id ON public.scans(user_id);
CREATE INDEX IF NOT EXISTS idx_scans_user_created ON public.scans(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_scans_predicted_class ON public.scans(predicted_class);

-- Comment
COMMENT ON TABLE public.scans IS 'Coffee bean scan results with full prediction data and sync metadata';
COMMENT ON COLUMN public.scans.client_scan_id IS 'Device-generated UUID for offline deduplication';
COMMENT ON COLUMN public.scans.is_ood IS 'Out-of-distribution detection flag (not a coffee bean)';

-- Enable RLS on both tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scans ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can only view and update their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- Scans: Users have full CRUD access to their own scans
CREATE POLICY "Users can view own scans"
  ON public.scans
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own scans"
  ON public.scans
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own scans"
  ON public.scans
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own scans"
  ON public.scans
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger function: Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply trigger to profiles table
DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Trigger function: Auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, preferred_language, theme_mode, cloud_sync_enabled)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', SPLIT_PART(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'en'),
    'system',
    true
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply trigger to auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
