-- YT001：更新已存在的 14 天清理排程，排除擁有者的記帳本。
-- 在 Supabase SQL Editor 執行一次即可；可安全重複執行。
-- 不立即刪除資料、不新建或啟用排程、不改變原本執行時間。
do $migration$
declare
  cleanup_job record;
  updated_count integer := 0;
begin
  if to_regclass('cron.job') is null then
    raise notice '未啟用 pg_cron，沒有清理排程需要更新。未刪除任何資料。';
    return;
  end if;

  for cleanup_job in
    select jobid from cron.job
    where jobname in (
      'yt001-cleanup-inactive-notebooks',
      'en-travel-cleanup-inactive-notebooks',
      'cleanup-inactive-notebooks'
    )
      and command ~* '\myt001_notebooks\M'
      and command ~* '\mdelete\M'
      and command ~* '\mlast_accessed_at\M'
  loop
    perform cron.alter_job(
      cleanup_job.jobid,
      command := $cleanup$
        delete from public.yt001_notebooks
        where last_accessed_at < now() - interval '14 days'
          and lower(btrim(creator_email)) <> 'yiting.useai@gmail.com';
      $cleanup$
    );
    updated_count := updated_count + 1;
  end loop;

  raise notice '已更新 % 個 YT001 清理排程。未刪除任何資料。', updated_count;
end;
$migration$;
