begin;
create extension if not exists pgtap with schema extensions;

select plan(14);

-- Usuários de teste (criados como superusuário)
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'admin.a@teste.com'),
  ('22222222-2222-2222-2222-222222222222', 'tecnico.a@teste.com'),
  ('33333333-3333-3333-3333-333333333333', 'admin.b@teste.com');

  -- ===== Admin A =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select lives_ok(
  $$ select public.criar_organizacao('Assistência A', 'Admin A') $$,
  'Admin A cria a sua organização'
);

select throws_ok(
  $$ select public.criar_organizacao('Outra Assistência', 'Admin A') $$,
  'P0001', 'Usuário já pertence a uma organização',
  'Usuário não pode criar uma segunda organização'
);

-- ===== Admin B =====
set local request.jwt.claims to '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}';

select lives_ok(
  $$ select public.criar_organizacao('Assistência B', 'Admin B') $$,
  'Admin B cria a sua organização'
);

-- Técnico A entra na organização A (direto como superusuário;
-- o fluxo de convite virá com o RF007)
reset role;
insert into public.membros (organizacao_id, usuario_id, nome, papel)
select id, '22222222-2222-2222-2222-222222222222', 'Técnico A', 'tecnico'
from public.organizacoes where nome = 'Assistência A';

-- ===== Admin A =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select results_eq(
  $$ select nome from public.organizacoes $$,
  $$ values ('Assistência A') $$,
  'Admin A vê apenas a própria organização'
);

select is(
  (select count(*)::int from public.membros), 2,
  'Admin A vê os 2 membros da sua organização'
);

select throws_ok(
  $$ update public.organizacoes set plano = 'pro' $$,
  '42501', null,
  'Ninguém altera o plano pelo app'
);

select throws_ok(
  $$ insert into public.organizacoes (nome) values ('Org Invasora') $$,
  '42501', null,
  'Não é possível inserir organização direto na tabela'
);

-- ===== Admin B =====
set local request.jwt.claims to '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}';

select results_eq(
  $$ select nome from public.organizacoes $$,
  $$ values ('Assistência B') $$,
  'Admin B vê apenas a própria organização'
);

select is(
  (select count(*)::int from public.membros), 1,
  'Admin B não vê membros da organização A'
);

-- Tentativa de invasão: B tenta renomear a organização A
update public.organizacoes set nome = 'Hackeado por B' where nome = 'Assistência A';

-- ===== Técnico A =====
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

select is(
  (select count(*)::int from public.membros), 2,
  'Técnico vê os colegas da sua organização'
);

-- Tentativas indevidas do técnico (devem alterar zero linhas)
update public.organizacoes set nome = 'Alterado pelo técnico' where nome = 'Assistência A';
update public.membros set papel = 'administrador'
where usuario_id = '22222222-2222-2222-2222-222222222222';

-- ===== Visitante não logado =====
reset role;
set local role anon;
set local request.jwt.claims to '{"role":"anon"}';

select throws_ok(
  $$ select * from public.organizacoes $$,
  '42501', null,
  'Visitante não lê organizações'
);

select throws_ok(
  $$ select public.criar_organizacao('X', 'Y') $$,
  '42501', null,
  'Visitante não cria organização'
);

-- ===== Conferência como superusuário =====
reset role;

select is(
    (select o.nome from public.organizacoes o
     join public.membros m on m.organizacao_id = o.id
   where m.usuario_id = '11111111-1111-1111-1111-111111111111'),
  'Assistência A',
  'Nem o Admin B nem o técnico conseguiram renomear a organização A'
);

select is(
  (select papel::text from public.membros
   where usuario_id = '22222222-2222-2222-2222-222222222222'),
  'tecnico',
  'Técnico não conseguiu se promover a administrador'
);

select * from finish();
rollback;