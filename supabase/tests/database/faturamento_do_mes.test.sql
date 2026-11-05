begin;
create extension if not exists pgtap with schema extensions;

select plan(5);

insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'admin.a@teste.com'),
  ('22222222-2222-2222-2222-222222222222', 'tecnico.a@teste.com'),
  ('33333333-3333-3333-3333-333333333333', 'admin.b@teste.com');

insert into public.organizacoes (id, nome) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Assistência A'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Assistência B');

insert into public.membros (organizacao_id, usuario_id, nome, papel) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Admin A',   'administrador'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Técnico A', 'tecnico'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', 'Admin B',   'administrador');

insert into public.clientes (id, organizacao_id, nome, telefone) values
  ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Maria Souza', '+5575999990000');

insert into public.ordens_servico (id, organizacao_id, cliente_id, equipamento, descricao_problema) values
  ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'Notebook Dell', 'Não liga'),
  ('d2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'iPhone 12',     'Tela quebrada'),
  ('d3d3d3d3-d3d3-d3d3-d3d3-d3d3d3d3d3d3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'Impressora HP', 'Atolando');

insert into public.itens_os (organizacao_id, os_id, descricao, valor_unitario) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'Fonte',       150),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'd2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2', 'Tela',        300),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'd3d3d3d3-d3d3-d3d3-d3d3-d3d3d3d3d3d3', 'Tracionador', 999);

-- d1: entregue neste mês (entra). d2: entregue há 40 dias (não entra).
-- d3: pronta, mas não entregue (não entra).
update public.ordens_servico set status = 'entregue', entregue_em = now()
  where id = 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1';
update public.ordens_servico set status = 'entregue', entregue_em = now() - interval '40 days'
  where id = 'd2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2';
update public.ordens_servico set status = 'pronta'
  where id = 'd3d3d3d3-d3d3-d3d3-d3d3-d3d3d3d3d3d3';

-- ===== Admin A =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select is(
  (public.faturamento_do_mes() ->> 'total')::numeric, 150::numeric,
  'Soma só as OS entregues neste mês'
);

select is(
  (public.faturamento_do_mes() ->> 'quantidade')::int, 1,
  'Conta as OS entregues no mês'
);

-- ===== Técnico A =====
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

select throws_ok(
  $$ select public.faturamento_do_mes() $$,
  '42501', 'Apenas administradores veem o faturamento',
  'Técnico não vê o faturamento (RN002)'
);

-- ===== Admin B =====
set local request.jwt.claims to '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}';

select is(
  (public.faturamento_do_mes() ->> 'total')::numeric, 0::numeric,
  'Cada organização só soma as próprias OS'
);

reset role;

select is(
  (select prosecdef from pg_proc where proname = 'faturamento_do_mes'),
  false,
  'A função roda com as permissões de quem chama (security invoker)'
);

select * from finish();
rollback;
