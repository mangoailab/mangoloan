-- Run in Supabase → SQL Editor.
-- Fixes: "new row violates row-level security policy" for admins on payments (and related tables).
-- Requires: public.admin_users.user_id = auth.users.id, and admins can SELECT their own row in admin_users.

-- ---------- payments ----------
drop policy if exists "payments_admin_select" on public.payments;
drop policy if exists "payments_admin_insert" on public.payments;
drop policy if exists "payments_admin_update" on public.payments;
drop policy if exists "payments_admin_delete" on public.payments;

create policy "payments_admin_select"
  on public.payments for select to authenticated
  using (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

create policy "payments_admin_insert"
  on public.payments for insert to authenticated
  with check (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

create policy "payments_admin_update"
  on public.payments for update to authenticated
  using (exists (select 1 from public.admin_users au where au.user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

create policy "payments_admin_delete"
  on public.payments for delete to authenticated
  using (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

-- ---------- loans (admin page + tracker) ----------
drop policy if exists "loans_admin_select" on public.loans;
drop policy if exists "loans_admin_insert" on public.loans;
drop policy if exists "loans_admin_update" on public.loans;
drop policy if exists "loans_admin_delete" on public.loans;

create policy "loans_admin_select"
  on public.loans for select to authenticated
  using (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

create policy "loans_admin_insert"
  on public.loans for insert to authenticated
  with check (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

create policy "loans_admin_update"
  on public.loans for update to authenticated
  using (exists (select 1 from public.admin_users au where au.user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

create policy "loans_admin_delete"
  on public.loans for delete to authenticated
  using (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

-- ---------- borrowers ----------
drop policy if exists "borrowers_admin_select" on public.borrowers;
drop policy if exists "borrowers_admin_insert" on public.borrowers;
drop policy if exists "borrowers_admin_update" on public.borrowers;
drop policy if exists "borrowers_admin_delete" on public.borrowers;

create policy "borrowers_admin_select"
  on public.borrowers for select to authenticated
  using (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

create policy "borrowers_admin_insert"
  on public.borrowers for insert to authenticated
  with check (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

create policy "borrowers_admin_update"
  on public.borrowers for update to authenticated
  using (exists (select 1 from public.admin_users au where au.user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

create policy "borrowers_admin_delete"
  on public.borrowers for delete to authenticated
  using (exists (select 1 from public.admin_users au where au.user_id = auth.uid()));

-- ---------- borrower portal (read-only for own data) ----------
-- Skip this block if you already have equivalent policies.

drop policy if exists "borrowers_self_select" on public.borrowers;
create policy "borrowers_self_select"
  on public.borrowers for select to authenticated
  using (auth_user_id = auth.uid());

drop policy if exists "loans_borrower_select" on public.loans;
create policy "loans_borrower_select"
  on public.loans for select to authenticated
  using (
    exists (
      select 1 from public.borrowers b
      where b.id = borrower_id and b.auth_user_id = auth.uid()
    )
  );

drop policy if exists "payments_borrower_select" on public.payments;
create policy "payments_borrower_select"
  on public.payments for select to authenticated
  using (
    exists (
      select 1 from public.loans l
      join public.borrowers b on b.id = l.borrower_id
      where l.id = loan_id and b.auth_user_id = auth.uid()
    )
  );
