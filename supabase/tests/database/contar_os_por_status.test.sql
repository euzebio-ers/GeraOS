begin;
create extension if not exists pgtap with schema extensions;

select plan(4);

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

-- Superusuário pode mudar o status direto, só para preparar o cenário.
update public.ordens_servico set status = 'pronta'
where id = 'd2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2';

-- ===== Técnico A =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

select results_eq(
  $$ select status::text, quantidade from public.contar_os_por_status() order by 1 $$,
  $$ values ('aberta', 1), ('pronta', 1) $$,
  'Conta as OS da organização em cada status'
);

-- ===== Admin B =====
set local request.jwt.claims to '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}';

select results_eq(
  $$ select status::text, quantidade from public.contar_os_por_status() $$,
  $$ values ('aberta', 1) $$,
  'Cada organização só conta as próprias OS'
);

-- ===== Visitante =====
reset role;
set local role anon;
set local request.jwt.claims to '{"role":"anon"}';

select throws_ok(
  $$ select * from public.contar_os_por_status() $$,
  '42501', null,
  'Visitante não conta OS'
);

reset role;

select is(
  (select prosecdef from pg_proc where proname = 'contar_os_por_status'),
  false,
  'A função roda com as permissões de quem chama (security invoker)'
);

select * from finish();
rollback;
