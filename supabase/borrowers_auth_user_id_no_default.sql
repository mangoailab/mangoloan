-- Prevent newly-created admin borrowers from being auto-linked to the signed-in admin user.
-- Run once in Supabase SQL Editor if public.borrowers.auth_user_id currently defaults to auth.uid().

alter table public.borrowers
  alter column auth_user_id drop default;
