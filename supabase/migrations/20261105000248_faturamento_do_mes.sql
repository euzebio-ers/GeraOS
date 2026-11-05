-- Faturamento de um mês: soma das OS entregues no mês, pela data de
-- entrega (RN008). Só administradores podem consultar (RN002).
--
-- security invoker: o RLS garante que só entram as OS da própria
-- organização. A conferência de administrador é feita por dentro.
create function public.faturamento_do_mes(p_mes date default null)
returns jsonb
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  v_organizacao uuid := public.organizacao_do_usuario();
  v_inicio      date := date_trunc(
    'month',
    coalesce(p_mes, (now() at time zone 'America/Sao_Paulo')::date)
  )::date;
  v_resultado   jsonb;
begin
  if v_organizacao is null or not public.eh_admin(v_organizacao) then
    raise exception 'Apenas administradores veem o faturamento'
      using errcode = '42501';
  end if;

  select jsonb_build_object(
    'mes',        v_inicio,
    'total',      coalesce(sum(o.valor_total), 0),
    'quantidade', count(*)
  )
  into v_resultado
  from public.ordens_servico o
  where o.status = 'entregue'
    and (o.entregue_em at time zone 'America/Sao_Paulo') >= v_inicio
    and (o.entregue_em at time zone 'America/Sao_Paulo') < v_inicio + interval '1 month';

  return v_resultado;
end;
$$;

revoke execute on function public.faturamento_do_mes(date) from public, anon;
grant execute on function public.faturamento_do_mes(date) to authenticated;
