-- Run this once in Supabase SQL Editor to fix payment requests.
alter table public.student_requests drop constraint if exists student_requests_request_type_check;
alter table public.student_requests add constraint student_requests_request_type_check
  check (request_type in ('absence', 'late', 'course_change', 'refund', 'payment', 'other'));

alter table public.student_requests
  add column if not exists reference_code text,
  add column if not exists transfer_info text not null default '',
  add column if not exists receipt text not null default '',
  add column if not exists payment_method text not null default '',
  add column if not exists payment_amount numeric not null default 0,
  add column if not exists payment_status text not null default 'pending',
  add column if not exists payment_date date;

create index if not exists student_requests_reference_idx on public.student_requests(reference_code);