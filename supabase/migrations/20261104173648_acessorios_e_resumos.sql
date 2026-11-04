-- 1. Acessórios deixados com o equipamento
alter table public.ordens_servico
  add column acessorios text check (char_length(acessorios) <= 500);

grant update (acessorios) on public.ordens_servico to authenticated;

-- 2. Resumo das OS para as listas: OS + cliente numa consulta só.
--    security_invoker = true: a view respeita o RLS de quem consulta.
create view public.ordens_servico_resumo
with (security_invoker = true) as
select
  o.id,
  o.organizacao_id,
  o.numero,
  o.status,
  o.equipamento,
  o.descricao_problema,
  o.valor_total,
  o.previsao_entrega,
  o.origem,
  o.criado_em,
  o.atualizado_em,
  o.entregue_em,
  c.id       as cliente_id,
  c.nome     as cliente_nome,
  c.telefone as cliente_telefone,
  (select count(*)::int from public.itens_os i where i.os_id = o.id)
             as quantidade_itens
from public.ordens_servico o
join public.clientes c
  on c.id = o.cliente_id
 and c.organizacao_id = o.organizacao_id;

-- 3. Resumo dos clientes: quantas OS e quando foi a última.
create view public.clientes_resumo
with (security_invoker = true) as
select
  c.id,
  c.organizacao_id,
  c.nome,
  c.telefone,
  c.email,
  c.documento,
  c.criado_em,
  count(o.id)::int  as quantidade_os,
  max(o.criado_em)  as ultima_os_em
from public.clientes c
left join public.ordens_servico o
  on o.cliente_id = c.id
 and o.organizacao_id = c.organizacao_id
where c.excluido_em is null
group by c.id;

-- 4. Permissões explícitas, como em todas as tabelas
revoke all on public.ordens_servico_resumo, public.clientes_resumo
  from anon, authenticated;
grant select on public.ordens_servico_resumo, public.clientes_resumo
  to authenticated;
grant select on public.ordens_servico_resumo, public.clientes_resumo
  to service_role;