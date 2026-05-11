revoke execute on function public.clone_task_templates(uuid, uuid[]) from public;
revoke execute on function public.clone_task_templates(uuid, uuid[]) from anon;
grant execute on function public.clone_task_templates(uuid, uuid[]) to authenticated;
