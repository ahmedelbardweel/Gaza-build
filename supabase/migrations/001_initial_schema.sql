-- ==============================================================================
-- Gaza Build / إعمار Hub - Complete Eco-system Database Schema
-- Supports: Clients, Interior Designers / Architects, Syndicate, Engineering Students
-- Pattern: Extensible Base Profile + Role Extension Tables (Doctors/Consultants can be added easily)
-- ==============================================================================

-- 1. Enums
create type public.user_role as enum (
  'client',
  'engineer',
  'student',
  'syndicate'
);

create type public.verification_status as enum (
  'unsubmitted',
  'pending',
  'approved',
  'rejected'
);

create type public.project_status as enum (
  'bidding',
  'in_progress',
  'completed',
  'disputed'
);

create type public.micro_task_status as enum (
  'available',
  'in_progress',
  'under_review',
  'completed'
);

-- 2. Base Profile Table
create table public.profiles (
  id                  uuid primary key references auth.users(id) on delete cascade,
  email               text not null,
  role                public.user_role not null default 'client',
  full_name           text not null default '',
  phone               text not null default '',
  city                text not null default 'غزة',
  avatar_url          text not null default '',
  bio                 text not null default '',
  is_profile_complete boolean not null default false,
  verification_status public.verification_status not null default 'unsubmitted',
  rejection_reason    text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index profiles_role_idx on public.profiles (role);
create index profiles_verification_idx on public.profiles (verification_status);

-- 3. Role-Specific Profile Extension Tables
create table public.engineer_profiles (
  user_id                     uuid primary key references public.profiles(id) on delete cascade,
  syndicate_membership_number text not null default '',
  university_degree_url       text not null default '',
  years_of_experience         int not null default 0,
  specialties                 text[] not null default '{}',
  portfolio_description       text not null default '',
  portfolio_project_images    text[] not null default '{}',
  rating                      numeric(3, 2) not null default 5.0,
  completed_projects_count    int not null default 0,
  created_at                  timestamptz not null default now(),
  updated_at                  timestamptz not null default now()
);

create table public.client_profiles (
  user_id                 uuid primary key references public.profiles(id) on delete cascade,
  address                 text not null default '',
  preferred_project_types text[] not null default '{}',
  property_condition_note text not null default '',
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now()
);

create table public.student_profiles (
  user_id                  uuid primary key references public.profiles(id) on delete cascade,
  university               text not null default '',
  department               text not null default '',
  year_of_study            int not null default 1,
  enrollment_proof_url     text not null default '',
  available_for_internship boolean not null default true,
  skills                   text[] not null default '{}',
  mentorship_score         numeric(3, 2) not null default 5.0,
  completed_micro_tasks    int not null default 0,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);

create table public.syndicate_profiles (
  user_id                    uuid primary key references public.profiles(id) on delete cascade,
  official_title             text not null default '',
  department                 text not null default '',
  authorization_document_url text not null default '',
  created_at                 timestamptz not null default now(),
  updated_at                 timestamptz not null default now()
);

-- 4. Projects, Bids, and Milestones
create table public.projects (
  id                     uuid primary key default gen_random_uuid(),
  client_id              uuid not null references public.profiles(id) on delete cascade,
  client_name            text not null,
  title                  text not null,
  description            text not null,
  project_type           text not null,
  area_m2                numeric(10, 2) not null,
  approximate_budget_usd numeric(12, 2) not null,
  preferred_style        text not null,
  city                   text not null,
  detailed_address       text not null default '',
  site_photos            text[] not null default '{}',
  status                 public.project_status not null default 'bidding',
  selected_engineer_id   uuid references public.profiles(id) on delete set null,
  selected_engineer_name text,
  agreed_price_usd       numeric(12, 2),
  is_escrow_secured      boolean not null default false,
  completion_percentage  int not null default 0,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

create table public.project_bids (
  id                      uuid primary key default gen_random_uuid(),
  project_id              uuid not null references public.projects(id) on delete cascade,
  engineer_id             uuid not null references public.profiles(id) on delete cascade,
  engineer_name           text not null,
  engineer_specialty      text not null default 'تصميم داخلي ومعماري',
  engineer_rating         numeric(3, 2) not null default 5.0,
  proposed_price_usd      numeric(12, 2) not null,
  estimated_duration_days int not null default 14,
  proposal_message        text not null,
  mood_board_description  text not null default '',
  mood_board_images       text[] not null default '{}',
  status                  text not null default 'pending', -- 'pending', 'accepted', 'rejected'
  created_at              timestamptz not null default now()
);

create table public.project_milestones (
  id                 uuid primary key default gen_random_uuid(),
  project_id         uuid not null references public.projects(id) on delete cascade,
  title              text not null,
  description        text not null,
  percentage_weight  int not null default 25,
  is_completed       boolean not null default false,
  payment_amount_usd numeric(12, 2) not null default 0.0,
  is_paid            boolean not null default false,
  proof_image_url    text,
  completed_at       timestamptz
);

-- 5. Student Micro Tasks
create table public.micro_tasks (
  id                   uuid primary key default gen_random_uuid(),
  engineer_id          uuid not null references public.profiles(id) on delete cascade,
  engineer_name        text not null,
  assigned_student_id  uuid references public.profiles(id) on delete set null,
  assigned_student_name text,
  title                text not null,
  description          text not null,
  task_type            text not null,
  software_needed      text not null default 'AutoCAD',
  reward_usd           numeric(8, 2) not null,
  deadline_days        int not null default 3,
  status               public.micro_task_status not null default 'available',
  deliverable_note     text,
  deliverable_file_url text,
  mentor_feedback      text,
  rating               numeric(3, 2),
  created_at           timestamptz not null default now()
);

-- 6. Syndicate Guidelines & Arbitration Panel
create table public.reconstruction_guides (
  id                 uuid primary key default gen_random_uuid(),
  title              text not null,
  category           text not null default 'مواد بديلة',
  summary            text not null,
  full_content       text not null,
  approved_materials text[] not null default '{}',
  author             text not null default 'نقابة المهندسين',
  published_date     timestamptz not null default now()
);

create table public.arbitration_cases (
  id                   uuid primary key default gen_random_uuid(),
  project_id           text not null,
  project_title        text not null,
  client_id            uuid not null references public.profiles(id) on delete cascade,
  client_name          text not null,
  engineer_id          uuid not null references public.profiles(id) on delete cascade,
  engineer_name        text not null,
  dispute_reason       text not null,
  requested_resolution text not null,
  syndicate_ruling     text,
  status               text not null default 'pending_review',
  created_at           timestamptz not null default now()
);

-- 7. Chat & Consultations
create table public.chat_messages (
  id               uuid primary key default gen_random_uuid(),
  conversation_key text not null,
  sender_id        uuid not null references public.profiles(id) on delete cascade,
  sender_name      text not null,
  sender_role      text not null,
  text             text not null,
  attachment_url   text,
  is_quick_consult boolean not null default false,
  created_at       timestamptz not null default now()
);

-- 8. Row Level Security
alter table public.profiles enable row level security;
alter table public.engineer_profiles enable row level security;
alter table public.client_profiles enable row level security;
alter table public.student_profiles enable row level security;
alter table public.syndicate_profiles enable row level security;
alter table public.projects enable row level security;
alter table public.project_bids enable row level security;
alter table public.project_milestones enable row level security;
alter table public.micro_tasks enable row level security;
alter table public.reconstruction_guides enable row level security;
alter table public.arbitration_cases enable row level security;
alter table public.chat_messages enable row level security;

-- Basic RLS Policies
create policy "profiles_self_access" on public.profiles for all using (auth.uid() = id);
create policy "engineer_profiles_self_access" on public.engineer_profiles for all using (auth.uid() = user_id);
create policy "client_profiles_self_access" on public.client_profiles for all using (auth.uid() = user_id);
create policy "student_profiles_self_access" on public.student_profiles for all using (auth.uid() = user_id);
create policy "syndicate_profiles_self_access" on public.syndicate_profiles for all using (auth.uid() = user_id);

create policy "projects_read_all" on public.projects for select using (true);
create policy "projects_write_own" on public.projects for insert with check (auth.uid() = client_id);
create policy "projects_update_involved" on public.projects for update using (auth.uid() = client_id or auth.uid() = selected_engineer_id);

create policy "guides_read_all" on public.reconstruction_guides for select using (true);
create policy "micro_tasks_read_all" on public.micro_tasks for select using (true);
create policy "chat_messages_access" on public.chat_messages for all using (auth.uid() = sender_id);
