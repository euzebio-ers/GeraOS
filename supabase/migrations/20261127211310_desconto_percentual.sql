-- Desconto em porcentagem (RN008). A porcentagem fica guardada e o valor
-- em reais do desconto é recalculado pelo banco sempre que o subtotal muda.
-- A coluna "desconto" continua sendo o valor em reais, então o PDF, o
-- WhatsApp e o faturamento seguem funcionando sem mudança.

-- 1. A porcentagem. Vazia (null) quando o desconto é um valor em reais.
alter table public.ordens_servico
  add column desconto_percentual numeric(5,2)
    check (desconto_percentual is null
           or (desconto_percentual > 0 and desconto_percentual <= 100));

grant update (desconto_percentual) on public.ordens_servico to authenticated;

-- 2. Um lugar só para o cálculo: antes de gravar a OS, converte a
--    porcentagem em reais (se houver) e recalcula o total.
create or replace function public.aplicar_desconto_os()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_subtotal numeric(12,2);
begin
  v_subtotal := coalesce((select sum(i.quantidade * i.valor_unitario)
                          from public.itens_os i
                          where i.os_id = new.id), 0);

  if new.desconto_percentual is not null then
    new.desconto := round(v_subtotal * new.desconto_percentual / 100, 2);
  end if;

  new.valor_total := greatest(v_subtotal - new.desconto, 0);
  return new;
end;
$$;

-- O trigger passa a reagir também à mudança da porcentagem.
drop trigger ordens_servico_aplicar_desconto on public.ordens_servico;
create trigger ordens_servico_aplicar_desconto
  before update of desconto, desconto_percentual on public.ordens_servico
  for each row execute function public.aplicar_desconto_os();

-- 3. Quando os itens mudam, regrava o desconto da OS. Isso dispara o
--    trigger acima, que refaz a porcentagem e o total com o subtotal novo.
create or replace function public.recalcular_valor_os()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_os_id uuid;
begin
  if tg_op = 'DELETE' then
    v_os_id := old.os_id;
  else
    v_os_id := new.os_id;
  end if;

  update public.ordens_servico o
     set desconto = o.desconto
   where o.id = v_os_id;

  return null;
end;
$$;

-- 4. O detalhe da OS passa a devolver a porcentagem.
create or replace function public.detalhe_os(p_os_id uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'id',                  o.id,
    'numero',              o.numero,
    'status',              o.status,
    'equipamento',         o.equipamento,
    'descricao_problema',  o.descricao_problema,
    'diagnostico',         o.diagnostico,
    'acessorios',          o.acessorios,
    'desconto',            o.desconto,
    'desconto_percentual', o.desconto_percentual,
    'valor_total',         o.valor_total,
    'previsao_entrega',    o.previsao_entrega,
    'origem',              o.origem,
    'criado_em',           o.criado_em,
    'entregue_em',         o.entregue_em,
    'criado_por_nome', (
      select m.nome from public.membros m
      where m.usuario_id = o.criado_por
        and m.organizacao_id = o.organizacao_id
    ),
    'cliente', jsonb_build_object(
      'id',       c.id,
      'nome',     c.nome,
      'telefone', c.telefone,
      'email',    c.email,
      'quantidade_os', (
        select count(*) from public.ordens_servico x
        where x.cliente_id = c.id and x.organizacao_id = c.organizacao_id
      )
    ),
    'itens', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id',             i.id,
          'tipo',           i.tipo,
          'descricao',      i.descricao,
          'quantidade',     i.quantidade,
          'valor_unitario', i.valor_unitario
        ) order by i.criado_em
      )
      from public.itens_os i
      where i.os_id = o.id
    ), '[]'::jsonb),
    'historico', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'status_anterior',   h.status_anterior,
          'status_novo',       h.status_novo,
          'observacao',        h.observacao,
          'alterado_em',       h.alterado_em,
          'alterado_por_nome', m.nome
        ) order by h.alterado_em desc
      )
      from public.historico_status_os h
      left join public.membros m
        on m.usuario_id = h.alterado_por
       and m.organizacao_id = h.organizacao_id
      where h.os_id = o.id
    ), '[]'::jsonb)
  )
  from public.ordens_servico o
  join public.clientes c
    on c.id = o.cliente_id
   and c.organizacao_id = o.organizacao_id
  where o.id = p_os_id;
$$;
