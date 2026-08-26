-- Run once in Supabase SQL Editor.
-- Student requests: absence, lateness, course transfer, refund, or other.
create table if not exists public.student_requests (
  id uuid primary key default gen_random_uuid(),
  student_profile_id uuid not null references public.profiles(id) on delete cascade,
  instructor_profile_id uuid references public.profiles(id) on delete set null,
  request_type text not null check (request_type in ('absence', 'late', 'course_change', 'refund', 'other')),
  details text not null,
  status text not null default 'pending' check (status in ('pending', 'reviewing', 'approved', 'rejected')),
  admin_note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.student_requests enable row level security;

create policy "students create own requests"
on public.student_requests for insert to authenticated
with check (student_profile_id = auth.uid());

create policy "students view own requests"
on public.student_requests for select to authenticated
using (student_profile_id = auth.uid());

create policy "staff view requests"
on public.student_requests for select to authenticated
using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin', 'instructor'))
  and (instructor_profile_id = auth.uid() or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'))
);

create policy "staff update requests"
on public.student_requests for update to authenticated
using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin', 'instructor'))
  and (instructor_profile_id = auth.uid() or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'))
)
with check (true);

create index if not exists student_requests_student_idx on public.student_requests(student_profile_id);
create index if not exists student_requests_instructor_idx on public.student_requests(instructor_profile_id);
create index if not exists student_requests_status_idx on public.student_requests(status);
