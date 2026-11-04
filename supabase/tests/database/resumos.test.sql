begin;
create extension if not exists pgtap with schema extensions;

select plan(8);

-- ===== Preparação (superusuário) =====
insert into auth.users (id, email) values
  ('22222222-2222-2222-2222-222222222222', 'tecnico.a@teste.com'),
  ('33333333-3333-3333-3333-333333333333', 'admin.b@teste.com');

insert into public.organizacoes (id, nome) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Assistência A'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Assistência B');

insert into public.membros (organizacao_id, usuario_id, nome, papel) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Técnico A', 'tecnico'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', 'Admin B',   'administrador');

insert into public.clientes (id, organizacao_id, nome, telefone) values
  ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Maria Souza', '+5575999990000'),
  ('c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'João Lima',   '+5575988880000');

insert into public.ordens_servico (id, organizacao_id, cliente_id, equipamento, descricao_problema) values
  ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'Notebook Dell', 'Não liga'),
  ('d2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'iPhone 12',     'Tela quebrada'),
  ('d3d3d3d3-d3d3-d3d3-d3d3-d3d3d3d3d3d3', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2', 'Impressora HP', 'Atolando');

insert into public.itens_os (organizacao_id, os_id, descricao, valor_unitario) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'd2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2', 'Troca de tela', 320);

-- ===== Técnico A =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

select results_eq(
  $$ select cliente_nome from public.ordens_servico_resumo order by numero $$,
  $$ values ('Maria Souza'), ('Maria Souza') $$,
  'Resumo traz as OS da organização com o nome do cliente'
);

select results_eq(
  $$ select quantidade_itens from public.ordens_servico_resumo order by numero $$,
  $$ values (0), (1) $$,
  'Resumo indica quais OS ainda não têm itens ("a orçar")'
);

select is(
  (select quantidade_os from public.clientes_resumo where nome = 'Maria Souza'),
  2,
  'Resumo de clientes conta as OS de cada cliente'
);

select lives_ok(
  $$ update public.ordens_servico set acessorios = 'Carregador e capinha'
     where id = 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1' $$,
  'Técnico registra os acessórios deixados'
);

select throws_ok(
  $$ update public.ordens_servico set acessorios = repeat('x', 501)
     where id = 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1' $$,
  '23514', null,
  'Acessórios têm no máximo 500 caracteres'
);

-- ===== Admin B: as views respeitam o RLS =====
set local request.jwt.claims to '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}';

select is(
  (select count(*)::int from public.ordens_servico_resumo), 1,
  'Admin B só vê a própria OS no resumo'
);

select is(
  (select count(*)::int from public.clientes_resumo), 1,
  'Admin B só vê o próprio cliente no resumo'
);

-- ===== Visitante =====
reset role;
set local role anon;
set local request.jwt.claims to '{"role":"anon"}';

select throws_ok(
  $$ select * from public.ordens_servico_resumo $$,
  '42501', null,
  'Visitante não lê o resumo de OS'
);

select * from finish();
rollback;