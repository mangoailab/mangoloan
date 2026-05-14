-- Run in Supabase SQL Editor or via Supabase CLI.
-- Adds real borrowed/disbursement rows so borrower activity can show advances and payments together.

create table if not exists public.loan_advances (
  id uuid primary key default gen_random_uuid(),
  loan_id uuid not null references public.loans(id) on delete cascade,
  date date not null,
  amount numeric not null check (amount > 0),
  method text,
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists loan_advances_loan_id_date_idx
  on public.loan_advances (loan_id, date, created_at);

alter table public.loan_advances enable row level security;

-- ---------- admin ----------
drop policy if exists "loan_advances_admin_select" on public.loan_advances;
drop policy if exists "loan_advances_admin_insert" on public.loan_advances;
drop policy if exists "loan_advances_admin_update" on public.loan_advances;
drop policy if exists "loan_advances_admin_delete" on public.loan_advances;

create policy "loan_advances_admin_select"
  on public.loan_advances for select to authenticated
  using ((auth.jwt() ->> 'aal' = 'aal2' and exists (select 1 from public.admin_users au where au.user_id = auth.uid())));

create policy "loan_advances_admin_insert"
  on public.loan_advances for insert to authenticated
  with check ((auth.jwt() ->> 'aal' = 'aal2' and exists (select 1 from public.admin_users au where au.user_id = auth.uid())));

create policy "loan_advances_admin_update"
  on public.loan_advances for update to authenticated
  using ((auth.jwt() ->> 'aal' = 'aal2' and exists (select 1 from public.admin_users au where au.user_id = auth.uid())))
  with check ((auth.jwt() ->> 'aal' = 'aal2' and exists (select 1 from public.admin_users au where au.user_id = auth.uid())));

create policy "loan_advances_admin_delete"
  on public.loan_advances for delete to authenticated
  using ((auth.jwt() ->> 'aal' = 'aal2' and exists (select 1 from public.admin_users au where au.user_id = auth.uid())));

-- ---------- borrower portal ----------
drop policy if exists "loan_advances_borrower_select" on public.loan_advances;
create policy "loan_advances_borrower_select"
  on public.loan_advances for select to authenticated
  using (
    exists (
      select 1 from public.loans l
      join public.borrowers b on b.id = l.borrower_id
      where l.id = loan_id and b.auth_user_id = auth.uid()
    )
  );
