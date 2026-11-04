-- Quantidade de OS da organização em cada status.
-- Usada nas etiquetas de filtro da lista e no "Hoje na bancada" da Início.
-- security invoker: o RLS garante que cada um só conta as próprias OS.
create function public.contar_os_por_status()
returns table (status public.status_os, quantidade integer)
language sql
stable
security invoker
set search_path = ''
as $$
  select o.status, count(*)::integer
  from public.ordens_servico o
  group by o.status;
$$;

revoke execute on function public.contar_os_por_status() from public, anon;
grant execute on function public.contar_os_por_status() to authenticated;
