-- ==============================================================================
-- Migration 002: Fix Row Level Security (RLS) Policies for Bids, Milestones, and Profiles
-- Ensures Engineers can submit bids, Clients can review/accept, and live Supabase sync works
-- ==============================================================================

-- 0. Ensure proposed_milestones column exists on project_bids
ALTER TABLE public.project_bids ADD COLUMN IF NOT EXISTS proposed_milestones jsonb not null default '[]'::jsonb;

-- 1. Profiles: Allow all authenticated users to read profiles (needed for engineer names, avatars, client names)
DROP POLICY IF EXISTS "profiles_self_access" ON public.profiles;
DROP POLICY IF EXISTS "profiles_read_all" ON public.profiles;
DROP POLICY IF EXISTS "profiles_upsert_own" ON public.profiles;

CREATE POLICY "profiles_read_all" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "profiles_upsert_own" ON public.profiles
  FOR ALL USING (auth.uid() = id);

-- 2. Engineer Profiles
DROP POLICY IF EXISTS "engineer_profiles_self_access" ON public.engineer_profiles;
DROP POLICY IF EXISTS "engineer_profiles_read_all" ON public.engineer_profiles;
DROP POLICY IF EXISTS "engineer_profiles_write_own" ON public.engineer_profiles;

CREATE POLICY "engineer_profiles_read_all" ON public.engineer_profiles
  FOR SELECT USING (true);

CREATE POLICY "engineer_profiles_write_own" ON public.engineer_profiles
  FOR ALL USING (auth.uid() = user_id);

-- 3. Projects
DROP POLICY IF EXISTS "projects_read_all" ON public.projects;
DROP POLICY IF EXISTS "projects_write_own" ON public.projects;
DROP POLICY IF EXISTS "projects_update_involved" ON public.projects;

CREATE POLICY "projects_read_all" ON public.projects
  FOR SELECT USING (true);

CREATE POLICY "projects_write_own" ON public.projects
  FOR INSERT WITH CHECK (auth.uid() = client_id);

CREATE POLICY "projects_update_involved" ON public.projects
  FOR UPDATE USING (auth.uid() = client_id OR auth.uid() = selected_engineer_id);

-- 4. Project Bids (العروض الهندسية)
DROP POLICY IF EXISTS "bids_read_all" ON public.project_bids;
DROP POLICY IF EXISTS "bids_insert_engineer" ON public.project_bids;
DROP POLICY IF EXISTS "bids_update_involved" ON public.project_bids;

CREATE POLICY "bids_read_all" ON public.project_bids
  FOR SELECT USING (true);

CREATE POLICY "bids_insert_engineer" ON public.project_bids
  FOR INSERT WITH CHECK (auth.uid() = engineer_id);

CREATE POLICY "bids_update_involved" ON public.project_bids
  FOR UPDATE USING (
    auth.uid() = engineer_id OR 
    EXISTS (SELECT 1 FROM public.projects p WHERE p.id = project_id AND p.client_id = auth.uid())
  );

-- 5. Project Milestones (مراحل الإنجاز)
DROP POLICY IF EXISTS "milestones_read_all" ON public.project_milestones;
DROP POLICY IF EXISTS "milestones_insert_all" ON public.project_milestones;
DROP POLICY IF EXISTS "milestones_update_all" ON public.project_milestones;

CREATE POLICY "milestones_read_all" ON public.project_milestones
  FOR SELECT USING (true);

CREATE POLICY "milestones_insert_all" ON public.project_milestones
  FOR INSERT WITH CHECK (true);

CREATE POLICY "milestones_update_all" ON public.project_milestones
  FOR UPDATE USING (true);

-- 6. Micro Tasks (مهام الطلاب)
DROP POLICY IF EXISTS "micro_tasks_read_all" ON public.micro_tasks;
DROP POLICY IF EXISTS "micro_tasks_insert_engineer" ON public.micro_tasks;
DROP POLICY IF EXISTS "micro_tasks_update_involved" ON public.micro_tasks;

CREATE POLICY "micro_tasks_read_all" ON public.micro_tasks
  FOR SELECT USING (true);

CREATE POLICY "micro_tasks_insert_engineer" ON public.micro_tasks
  FOR INSERT WITH CHECK (auth.uid() = engineer_id);

CREATE POLICY "micro_tasks_update_involved" ON public.micro_tasks
  FOR UPDATE USING (auth.uid() = engineer_id OR auth.uid() = assigned_student_id);

-- 7. Chat Messages
DROP POLICY IF EXISTS "chat_messages_access" ON public.chat_messages;
DROP POLICY IF EXISTS "chat_messages_read_all" ON public.chat_messages;
DROP POLICY IF EXISTS "chat_messages_insert_own" ON public.chat_messages;

CREATE POLICY "chat_messages_read_all" ON public.chat_messages
  FOR SELECT USING (true);

CREATE POLICY "chat_messages_insert_own" ON public.chat_messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);
