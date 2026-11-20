-- ============================================================================
-- HOMEGUARDIAN: COMPLETE SUPABASE POSTGRESQL DATABASE SCHEMA & RLS POLICIES
-- Smart Household Management & Maintenance System
-- Course: Software Construction and Development (SCD)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. EXTENSIONS & CLEANUP
-- ----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop existing tables if re-running (in dependency reverse order)
DROP TABLE IF EXISTS public.reminders CASCADE;
DROP TABLE IF EXISTS public.maintenance_records CASCADE;
DROP TABLE IF EXISTS public.appliances CASCADE;
DROP TABLE IF EXISTS public.tasks CASCADE;
DROP TABLE IF EXISTS public.household_members CASCADE;
DROP TABLE IF EXISTS public.households CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Drop helper functions
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.join_household_by_invite_code(TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.is_household_member(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.is_household_admin(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.validate_task_assignment() CASCADE;
DROP FUNCTION IF EXISTS public.update_timestamp() CASCADE;

-- ----------------------------------------------------------------------------
-- 1. PROFILES TABLE (Linked directly to Supabase auth.users)
-- ----------------------------------------------------------------------------
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_profiles_email ON public.profiles(email);

-- ----------------------------------------------------------------------------
-- 2. HOUSEHOLDS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE public.households (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL CHECK (char_length(trim(name)) >= 2),
    invite_code VARCHAR(6) NOT NULL UNIQUE CHECK (invite_code ~* '^[A-Z0-9]{6}$'),
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE UNIQUE INDEX idx_households_invite_code ON public.households(invite_code);
CREATE INDEX idx_households_created_by ON public.households(created_by);

-- ----------------------------------------------------------------------------
-- 3. HOUSEHOLD MEMBERS TABLE
-- Supports:
-- (a) Registered members linked to auth users (user_id IS NOT NULL)
-- (b) Family members added by name without accounts (user_id IS NULL)
-- ----------------------------------------------------------------------------
CREATE TABLE public.household_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    member_name TEXT NOT NULL CHECK (char_length(trim(member_name)) >= 1),
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    -- An authenticated user cannot join the same household more than once
    CONSTRAINT uq_household_user UNIQUE (household_id, user_id)
);

CREATE INDEX idx_household_members_household_id ON public.household_members(household_id);
CREATE INDEX idx_household_members_user_id ON public.household_members(user_id);

-- ----------------------------------------------------------------------------
-- 4. TASKS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    assigned_member_id UUID REFERENCES public.household_members(id) ON DELETE SET NULL,
    title TEXT NOT NULL CHECK (char_length(trim(title)) >= 2),
    description TEXT,
    due_date TIMESTAMPTZ,
    priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_tasks_household_id ON public.tasks(household_id);
CREATE INDEX idx_tasks_assigned_member ON public.tasks(assigned_member_id);
CREATE INDEX idx_tasks_status ON public.tasks(status);
CREATE INDEX idx_tasks_due_date ON public.tasks(due_date);

-- ----------------------------------------------------------------------------
-- 5. APPLIANCES TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE public.appliances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    name TEXT NOT NULL CHECK (char_length(trim(name)) >= 2),
    brand TEXT,
    model TEXT,
    purchase_date DATE,
    warranty_months INTEGER NOT NULL DEFAULT 12 CHECK (warranty_months >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_appliances_household_id ON public.appliances(household_id);

-- ----------------------------------------------------------------------------
-- 6. MAINTENANCE RECORDS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE public.maintenance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appliance_id UUID NOT NULL REFERENCES public.appliances(id) ON DELETE CASCADE,
    service_date DATE NOT NULL DEFAULT CURRENT_DATE,
    description TEXT NOT NULL CHECK (char_length(trim(description)) >= 2),
    cost NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (cost >= 0.00),
    service_provider TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_maintenance_appliance_id ON public.maintenance_records(appliance_id);
CREATE INDEX idx_maintenance_service_date ON public.maintenance_records(service_date);

-- ----------------------------------------------------------------------------
-- 7. REMINDERS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE public.reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
    appliance_id UUID REFERENCES public.appliances(id) ON DELETE CASCADE,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    title TEXT NOT NULL CHECK (char_length(trim(title)) >= 2),
    description TEXT,
    reminder_type TEXT NOT NULL CHECK (reminder_type IN ('task', 'bill', 'maintenance', 'warranty')),
    reminder_date TIMESTAMPTZ NOT NULL,
    is_dismissed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_reminders_household_id ON public.reminders(household_id);
CREATE INDEX idx_reminders_date_dismissed ON public.reminders(reminder_date, is_dismissed);
CREATE INDEX idx_reminders_type ON public.reminders(reminder_type);

-- ============================================================================
-- DATABASE TRIGGERS & FUNCTIONS
-- ============================================================================

-- Function 1: Automatic updated_at timestamp trigger
CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
CREATE TRIGGER trg_households_updated_at BEFORE UPDATE ON public.households FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
CREATE TRIGGER trg_tasks_updated_at BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
CREATE TRIGGER trg_appliances_updated_at BEFORE UPDATE ON public.appliances FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
CREATE TRIGGER trg_reminders_updated_at BEFORE UPDATE ON public.reminders FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

-- Function 2: Automatic Profile Creation on auth.users Sign Up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (
        NEW.id,
        COALESCE(NEW.email, ''),
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Household Member')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function 3: Cross-Household Task Assignment Integrity Guard
-- Guarantees that a task cannot be assigned to a member of a different household
CREATE OR REPLACE FUNCTION public.validate_task_assignment()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.assigned_member_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.household_members
            WHERE id = NEW.assigned_member_id
              AND household_id = NEW.household_id
        ) THEN
            RAISE EXCEPTION 'Cannot assign task to a member outside the task household.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_task_assignment
BEFORE INSERT OR UPDATE OF assigned_member_id, household_id ON public.tasks
FOR EACH ROW EXECUTE FUNCTION public.validate_task_assignment();

-- ============================================================================
-- SECURITY DEFINER ACCESS CHECKERS (Prevents Infinite RLS Recursion)
-- ============================================================================

-- Check if authenticated user is a member of the household
CREATE OR REPLACE FUNCTION public.is_household_member(h_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.household_members
        WHERE household_id = h_id
          AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public STABLE;

-- Check if authenticated user is an admin of the household
CREATE OR REPLACE FUNCTION public.is_household_admin(h_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.household_members
        WHERE household_id = h_id
          AND user_id = auth.uid()
          AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public STABLE;

-- ============================================================================
-- SECURE STORED PROCEDURE: JOIN HOUSEHOLD VIA 6-CHARACTER INVITE CODE
-- Protects against invite-code scraping and unauthorized self-assignment
-- ============================================================================
CREATE OR REPLACE FUNCTION public.join_household_by_invite_code(code_input TEXT)
RETURNS JSONB AS $$
DECLARE
    v_household RECORD;
    v_profile RECORD;
    v_existing_member RECORD;
    v_clean_code TEXT;
BEGIN
    -- Verify caller is authenticated
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentication required to join a household.';
    END IF;

    v_clean_code := UPPER(TRIM(code_input));

    -- Look up household by code
    SELECT * INTO v_household
    FROM public.households
    WHERE invite_code = v_clean_code;

    IF v_household.id IS NULL THEN
        RAISE EXCEPTION 'Invalid invite code. No matching household found.';
    END IF;

    -- Look up caller profile
    SELECT * INTO v_profile
    FROM public.profiles
    WHERE id = auth.uid();

    -- Check if already an enrolled member
    SELECT * INTO v_existing_member
    FROM public.household_members
    WHERE household_id = v_household.id
      AND user_id = auth.uid();

    IF v_existing_member.id IS NOT NULL THEN
        RETURN jsonb_build_object(
            'success', true,
            'household_id', v_household.id,
            'household_name', v_household.name,
            'message', 'Already a member of this household.'
        );
    END IF;

    -- Insert new member with strict 'member' role (never self-admin)
    INSERT INTO public.household_members (
        household_id,
        user_id,
        member_name,
        role
    ) VALUES (
        v_household.id,
        auth.uid(),
        COALESCE(v_profile.full_name, 'Member'),
        'member'
    );

    RETURN jsonb_build_object(
        'success', true,
        'household_id', v_household.id,
        'household_name', v_household.name,
        'message', 'Successfully joined household.'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS across all 7 public tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appliances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- RLS 1: PROFILES
-- ----------------------------------------------------------------------------
-- Users can view their own profile, or profiles of members sharing their households
CREATE POLICY "profiles_select_policy"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (
        id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.household_members m1
            JOIN public.household_members m2 ON m1.household_id = m2.household_id
            WHERE m1.user_id = auth.uid()
              AND m2.user_id = profiles.id
        )
    );

CREATE POLICY "profiles_update_own_policy"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- ----------------------------------------------------------------------------
-- RLS 2: HOUSEHOLDS
-- ----------------------------------------------------------------------------
-- Members can view households they belong to, or creators during creation
CREATE POLICY "households_select_policy"
    ON public.households FOR SELECT
    TO authenticated
    USING (
        public.is_household_member(id) OR created_by = auth.uid()
    );

-- Any authenticated user can create a household
CREATE POLICY "households_insert_policy"
    ON public.households FOR INSERT
    TO authenticated
    WITH CHECK (created_by = auth.uid());

-- Only household admins can update household details
CREATE POLICY "households_update_policy"
    ON public.households FOR UPDATE
    TO authenticated
    USING (public.is_household_admin(id))
    WITH CHECK (public.is_household_admin(id));

-- Only household admins can delete a household
CREATE POLICY "households_delete_policy"
    ON public.households FOR DELETE
    TO authenticated
    USING (public.is_household_admin(id));

-- ----------------------------------------------------------------------------
-- RLS 3: HOUSEHOLD MEMBERS
-- ----------------------------------------------------------------------------
-- Household members can view the member roster of their households
CREATE POLICY "household_members_select_policy"
    ON public.household_members FOR SELECT
    TO authenticated
    USING (public.is_household_member(household_id));

-- Admins can add members (including unlinked family members by name),
-- OR creators can add their initial admin record
CREATE POLICY "household_members_insert_policy"
    ON public.household_members FOR INSERT
    TO authenticated
    WITH CHECK (
        public.is_household_admin(household_id) OR
        (
            user_id = auth.uid() AND
            EXISTS (
                SELECT 1 FROM public.households
                WHERE id = household_id AND created_by = auth.uid()
            )
        )
    );

-- Only admins can update member details/roles, but members cannot promote themselves
CREATE POLICY "household_members_update_policy"
    ON public.household_members FOR UPDATE
    TO authenticated
    USING (public.is_household_admin(household_id))
    WITH CHECK (public.is_household_admin(household_id));

-- Admins can remove members, or members can leave the household
CREATE POLICY "household_members_delete_policy"
    ON public.household_members FOR DELETE
    TO authenticated
    USING (
        public.is_household_admin(household_id) OR
        user_id = auth.uid()
    );

-- ----------------------------------------------------------------------------
-- RLS 4: TASKS
-- ----------------------------------------------------------------------------
CREATE POLICY "tasks_select_policy"
    ON public.tasks FOR SELECT
    TO authenticated
    USING (public.is_household_member(household_id));

CREATE POLICY "tasks_insert_policy"
    ON public.tasks FOR INSERT
    TO authenticated
    WITH CHECK (public.is_household_member(household_id));

CREATE POLICY "tasks_update_policy"
    ON public.tasks FOR UPDATE
    TO authenticated
    USING (public.is_household_member(household_id))
    WITH CHECK (public.is_household_member(household_id));

CREATE POLICY "tasks_delete_policy"
    ON public.tasks FOR DELETE
    TO authenticated
    USING (public.is_household_member(household_id));

-- ----------------------------------------------------------------------------
-- RLS 5: APPLIANCES
-- ----------------------------------------------------------------------------
CREATE POLICY "appliances_select_policy"
    ON public.appliances FOR SELECT
    TO authenticated
    USING (public.is_household_member(household_id));

CREATE POLICY "appliances_insert_policy"
    ON public.appliances FOR INSERT
    TO authenticated
    WITH CHECK (public.is_household_member(household_id));

CREATE POLICY "appliances_update_policy"
    ON public.appliances FOR UPDATE
    TO authenticated
    USING (public.is_household_member(household_id))
    WITH CHECK (public.is_household_member(household_id));

CREATE POLICY "appliances_delete_policy"
    ON public.appliances FOR DELETE
    TO authenticated
    USING (public.is_household_member(household_id));

-- ----------------------------------------------------------------------------
-- RLS 6: MAINTENANCE RECORDS (Secured through parent appliance)
-- ----------------------------------------------------------------------------
CREATE POLICY "maintenance_select_policy"
    ON public.maintenance_records FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.appliances a
            WHERE a.id = maintenance_records.appliance_id
              AND public.is_household_member(a.household_id)
        )
    );

CREATE POLICY "maintenance_insert_policy"
    ON public.maintenance_records FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.appliances a
            WHERE a.id = maintenance_records.appliance_id
              AND public.is_household_member(a.household_id)
        )
    );

CREATE POLICY "maintenance_update_policy"
    ON public.maintenance_records FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.appliances a
            WHERE a.id = maintenance_records.appliance_id
              AND public.is_household_member(a.household_id)
        )
    );

CREATE POLICY "maintenance_delete_policy"
    ON public.maintenance_records FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.appliances a
            WHERE a.id = maintenance_records.appliance_id
              AND public.is_household_member(a.household_id)
        )
    );

-- ----------------------------------------------------------------------------
-- RLS 7: REMINDERS
-- ----------------------------------------------------------------------------
CREATE POLICY "reminders_select_policy"
    ON public.reminders FOR SELECT
    TO authenticated
    USING (public.is_household_member(household_id));

CREATE POLICY "reminders_insert_policy"
    ON public.reminders FOR INSERT
    TO authenticated
    WITH CHECK (public.is_household_member(household_id));

CREATE POLICY "reminders_update_policy"
    ON public.reminders FOR UPDATE
    TO authenticated
    USING (public.is_household_member(household_id))
    WITH CHECK (public.is_household_member(household_id));

CREATE POLICY "reminders_delete_policy"
    ON public.reminders FOR DELETE
    TO authenticated
    USING (public.is_household_member(household_id));
