-- Run this in Supabase SQL Editor
-- Project: yitinguseai/en_travel_table（旅行分帳）
-- All tables use the en_travel_ prefix. Run once in an empty database.

create extension if not exists "uuid-ossp";

create table en_travel_notebooks (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  creator_email text not null,
  password_hash text,
  is_closed boolean not null default false,
  created_at timestamptz not null default now(),
  last_accessed_at timestamptz not null default now()
);

create table en_travel_members (
  id uuid primary key default uuid_generate_v4(),
  notebook_id uuid not null references en_travel_notebooks(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  unique(notebook_id, name)
);

create table en_travel_currencies (
  id uuid primary key default uuid_generate_v4(),
  notebook_id uuid not null references en_travel_notebooks(id) on delete cascade,
  code text not null,
  exchange_rate numeric,
  base_currency text,
  decimal_places integer not null default 2,
  unique(notebook_id, code)
);

create table en_travel_expenses (
  id uuid primary key default uuid_generate_v4(),
  notebook_id uuid not null references en_travel_notebooks(id) on delete cascade,
  title text not null,
  date date not null,
  amount numeric not null,
  currency text not null,
  payer text not null,
  split_method text not null check (split_method in ('equal', 'custom', 'ratio')),
  notes text,
  receipt_url text,
  visibility text not null default 'shared' check (visibility in ('private', 'shared')),
  created_by text not null,
  created_at timestamptz not null default now()
);

create table en_travel_expense_splits (
  id uuid primary key default uuid_generate_v4(),
  expense_id uuid not null references en_travel_expenses(id) on delete cascade,
  member_name text not null,
  amount numeric not null,
  ratio numeric
);

create table en_travel_settlement_items (
  id uuid primary key default uuid_generate_v4(),
  notebook_id uuid not null references en_travel_notebooks(id) on delete cascade,
  from_member text not null,
  to_member text not null,
  amount numeric not null,
  currency text not null,
  status text not null default 'unpaid' check (status in ('unpaid', 'paid', 'confirmed')),
  proof_url text,
  original_amounts jsonb
);

create table en_travel_collection_info (
  id uuid primary key default uuid_generate_v4(),
  notebook_id uuid not null references en_travel_notebooks(id) on delete cascade,
  member_name text not null,
  account_info text,
  qr_code_url text,
  notes text,
  unique(notebook_id, member_name)
);

-- 專案識別、資料表保護與網站後端權限
comment on table public.en_travel_notebooks is '專案：yitinguseai/en_travel_table｜旅行分帳｜旅行記帳本';
alter table public.en_travel_notebooks enable row level security;
comment on table public.en_travel_members is '專案：yitinguseai/en_travel_table｜旅行分帳｜記帳本成員';
alter table public.en_travel_members enable row level security;
comment on table public.en_travel_currencies is '專案：yitinguseai/en_travel_table｜旅行分帳｜幣別與匯率';
alter table public.en_travel_currencies enable row level security;
comment on table public.en_travel_expenses is '專案：yitinguseai/en_travel_table｜旅行分帳｜支出紀錄';
alter table public.en_travel_expenses enable row level security;
comment on table public.en_travel_expense_splits is '專案：yitinguseai/en_travel_table｜旅行分帳｜支出分攤明細';
alter table public.en_travel_expense_splits enable row level security;
comment on table public.en_travel_settlement_items is '專案：yitinguseai/en_travel_table｜旅行分帳｜結算與匯款狀態';
alter table public.en_travel_settlement_items enable row level security;
comment on table public.en_travel_collection_info is '專案：yitinguseai/en_travel_table｜旅行分帳｜收款帳號與 QR Code';
alter table public.en_travel_collection_info enable row level security;

grant usage on schema public to service_role;
grant select, insert, update, delete on table
  public.en_travel_notebooks,
  public.en_travel_members,
  public.en_travel_currencies,
  public.en_travel_expenses,
  public.en_travel_expense_splits,
  public.en_travel_settlement_items,
  public.en_travel_collection_info
to service_role;

-- Storage buckets (create in Supabase dashboard > Storage)
-- bucket: tp-receipts    (public: true)
-- bucket: tp-proofs      (public: true)
-- bucket: tp-qrcodes     (public: true)

-- ============================================================
-- Migration: run in Supabase SQL Editor for existing databases
-- ============================================================
-- alter table en_travel_notebooks
--   add column if not exists last_accessed_at timestamptz not null default now();
-- alter table en_travel_notebooks drop column if exists expires_at;

-- ============================================================
-- Auto-delete inactive notebooks (14 days)
-- Enable pg_cron: Supabase dashboard > Database > Extensions > pg_cron
-- Then run:
-- ============================================================
-- select cron.schedule(
--   'en-travel-cleanup-inactive-notebooks',
--   '0 2 * * *',
--   $$
--     delete from en_travel_notebooks
--     where last_accessed_at < now() - interval '14 days';
--   $$
-- );
