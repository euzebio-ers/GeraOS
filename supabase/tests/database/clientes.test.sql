begin;
create extension if not exists pgtap with schema extensions;

select plan(10);

-- Preparação (superusuário): duas organizações, um membro em cada
insert into auth.users (id, email) values
  ('22222222-2222-2222-2222-222222222222', 'tecnico.a@teste.com'),
  ('33333333-3333-3333-3333-333333333333', 'admin.b@teste.com');

insert into public.organizacoes (id, nome) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Assistência A'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Assistência B');

insert into public.membros (organizacao_id, usuario_id, nome, papel) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Técnico A', 'tecnico'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', 'Admin B', 'administrador');

-- ===== Técnico A =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

select lives_ok(
  $$ insert into public.clientes (nome, telefone) values ('Maria Souza', '+5575999990000') $$,
  'Técnico cadastra cliente sem informar a organização'
);

select results_eq(
  $$ select organizacao_id from public.clientes $$,
  $$ values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid) $$,
  'Cliente fica vinculado automaticamente à organização do técnico'
);

select throws_ok(
  $$ insert into public.clientes (nome) values ('Sem Contato') $$,
  '23514', null,
  'Cliente precisa de telefone ou e-mail (RN003)'
);

select throws_ok(
  $$ insert into public.clientes (nome, telefone) values ('Fulano', '75 99999-0000') $$,
  '23514', null,
  'Telefone fora do padrão E.164 é recusado'
);

select throws_ok(
  $$ update public.clientes set organizacao_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb' $$,
  '42501', null,
  'Cliente não pode mudar de organização'
);

select throws_ok(
  $$ delete from public.clientes $$,
  '42501', null,
  'Cliente não pode ser apagado fisicamente'
);

-- ===== Admin B =====
set local request.jwt.claims to '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}';

select is(
  (select count(*)::int from public.clientes), 0,
  'Admin B não vê clientes da organização A'
);

select throws_ok(
  $$ insert into public.clientes (organizacao_id, nome, telefone)
     values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Infiltrado', '+5575988887777') $$,
  '42501', null,
  'Admin B não consegue cadastrar cliente na organização A'
);

-- Tentativa de alterar cliente de A (deve afetar zero linhas)
update public.clientes set nome = 'Hackeado' where nome = 'Maria Souza';

-- ===== Visitante =====
reset role;
set local role anon;
set local request.jwt.claims to '{"role":"anon"}';

select throws_ok(
  $$ select * from public.clientes $$,
  '42501', null,
  'Visitante não lê clientes'
);

-- ===== Conferência =====
reset role;

select is(
  (select nome from public.clientes where telefone = '+5575999990000'),
  'Maria Souza',
  'Admin B não conseguiu alterar cliente da organização A'
);

select * from finish();
rollback;