begin;
create extension if not exists pgtap with schema extensions;

select plan(11);

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

-- ===== Técnico A =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

select lives_ok(
  $$ select public.criar_os_digitada(
       p_equipamento        => 'Notebook Dell Inspiron 15',
       p_descricao_problema => 'Não liga',
       p_cliente_nome       => 'Fernanda Rocha',
       p_cliente_telefone   => '+5571984550912',
       p_acessorios         => 'Carregador',
       p_valor_estimado     => 150
     ) $$,
  'Cria OS com cliente novo e valor estimado'
);

select is(
  (select count(*)::int from public.clientes), 2,
  'O cliente novo foi cadastrado na organização'
);

select results_eq(
  $$ select numero, valor_total from public.ordens_servico $$,
  $$ values (1, 150::numeric) $$,
  'A OS recebe o número 1 e o total vem do valor estimado'
);

select is(
  (select descricao from public.itens_os), 'Orçamento inicial',
  'O valor estimado vira o item "Orçamento inicial"'
);

select lives_ok(
  $$ select public.criar_os_digitada(
       p_equipamento        => 'iPhone 12',
       p_descricao_problema => 'Tela quebrada',
       p_cliente_id         => 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1'
     ) $$,
  'Cria OS para um cliente já cadastrado, sem valor estimado'
);

-- Atomicidade: o cliente seria válido, mas a OS não (equipamento curto).
select throws_ok(
  $$ select public.criar_os_digitada(
       p_equipamento        => 'x',
       p_descricao_problema => 'Não carrega',
       p_cliente_nome       => 'Gabriel Nunes',
       p_cliente_telefone   => '+5571988887777'
     ) $$,
  '23514', null,
  'OS inválida é recusada'
);

select is(
  (select count(*)::int from public.clientes), 2,
  'Com a OS recusada, o cliente novo também não ficou gravado'
);

select throws_ok(
  $$ select public.criar_os_digitada(
       p_equipamento        => 'Impressora HP',
       p_descricao_problema => 'Atolando papel',
       p_cliente_id         => 'c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2'
     ) $$,
  '23503', null,
  'Não é possível usar um cliente de outra organização'
);

select throws_ok(
  $$ select public.criar_os_digitada(
       p_equipamento        => 'Impressora HP',
       p_descricao_problema => 'Atolando papel'
     ) $$,
  'P0001', 'Informe o cliente da OS',
  'OS sem cliente é recusada'
);

-- ===== Visitante =====
reset role;
set local role anon;
set local request.jwt.claims to '{"role":"anon"}';

select throws_ok(
  $$ select public.criar_os_digitada(
       p_equipamento        => 'Notebook',
       p_descricao_problema => 'Não liga',
       p_cliente_nome       => 'Invasor',
       p_cliente_telefone   => '+5571900000000'
     ) $$,
  '42501', null,
  'Visitante não cria OS'
);

-- ===== Conferência =====
reset role;

select is(
  (select prosecdef from pg_proc where proname = 'criar_os_digitada'),
  false,
  'A função roda com as permissões de quem chama (security invoker)'
);

select * from finish();
rollback;
