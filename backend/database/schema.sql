-- ============================================================
-- PIXELDROP PostgreSQL & Supabase Database Schema
-- ============================================================

-- Enable pgcrypto for UUID generation & SHA hashing
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Profiles Table (Linked with Supabase Auth)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    username TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 2. Devices Table
CREATE TABLE IF NOT EXISTS public.devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_name TEXT NOT NULL,
    platform TEXT CHECK (platform IN ('android', 'windows', 'web')),
    public_key TEXT,
    last_active TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 3. Pairing Sessions (5-Minute Expiring Session)
CREATE TABLE IF NOT EXISTS public.pairing_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    qr_token TEXT UNIQUE NOT NULL,
    verification_code VARCHAR(6) NOT NULL, -- 6-digit PIN e.g. '849201'
    initiator_device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    paired_device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'expired', 'revoked')),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (TIMEZONE('utc', NOW()) + INTERVAL '5 minutes'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Index for speedy token & pin lookup
CREATE INDEX IF NOT EXISTS idx_pairing_qr_token ON public.pairing_sessions(qr_token);
CREATE INDEX IF NOT EXISTS idx_pairing_expires ON public.pairing_sessions(expires_at);

-- 4. Transfers Record Table
CREATE TABLE IF NOT EXISTS public.transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID REFERENCES public.profiles(id),
    receiver_id UUID REFERENCES public.profiles(id),
    file_name TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    sha256 TEXT NOT NULL,
    transfer_mode TEXT CHECK (transfer_mode IN ('local_lan', 'cloud_r2')),
    status TEXT DEFAULT 'active' CHECK (status IN ('queued', 'active', 'paused', 'completed', 'failed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 5. Cloud File Shares (Public / Protected Links)
CREATE TABLE IF NOT EXISTS public.file_shares (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    storage_path TEXT NOT NULL,
    sha256 TEXT NOT NULL,
    password_hash TEXT,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (TIMEZONE('utc', NOW()) + INTERVAL '7 days'),
    download_limit INT DEFAULT 10,
    download_count INT DEFAULT 0,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 6. Application Releases & Updates Cache Table
CREATE TABLE IF NOT EXISTS public.app_releases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    version TEXT UNIQUE NOT NULL,
    release_notes TEXT,
    windows_url TEXT NOT NULL,
    windows_sha256 TEXT,
    android_url TEXT NOT NULL,
    android_sha256 TEXT,
    published_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_mandatory BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.file_shares ENABLE ROW LEVEL SECURITY;

-- Auto-expire Pairing Sessions Function
CREATE OR REPLACE FUNCTION expire_old_pairing_sessions()
RETURNS trigger AS $$
BEGIN
    UPDATE public.pairing_sessions
    SET status = 'expired'
    WHERE status = 'pending' AND expires_at < NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
