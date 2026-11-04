-- Tudo o que a tela de detalhe da OS precisa, numa única resposta JSON:
-- a OS, o cliente, os itens e o histórico com o nome de quem alterou.
-- Devolve null se a OS não existir ou for de outra organização (RLS).
create function public.detalhe_os(p_os_id uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'id',                 o.id,
    'numero',             o.numero,
    'status',             o.status,
    'equipamento',        o.equipamento,
    'descricao_problema', o.descricao_problema,
    'diagnostico',        o.diagnostico,
    'acessorios',         o.acessorios,
    'desconto',           o.desconto,
    'valor_total',        o.valor_total,
    'previsao_entrega',   o.previsao_entrega,
    'origem',             o.origem,
    'criado_em',          o.criado_em,
    'entregue_em',        o.entregue_em,
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

revoke execute on function public.detalhe_os(uuid) from public, anon;
grant execute on function public.detalhe_os(uuid) to authenticated;
