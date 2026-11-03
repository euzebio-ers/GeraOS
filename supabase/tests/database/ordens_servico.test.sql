begin;
create extension if not exists pgtap with schema extensions;

select plan(27);

-- ===== Preparação (superusuário) =====
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
  ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Maria Souza', '+5575999990000'),
  ('c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'João Lima',   '+5575988880000');

-- ===== Técnico A: criação, numeração e valores =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

select lives_ok(
  $$ insert into public.ordens_servico (id, cliente_id, equipamento, descricao_problema)
     values ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1',
             'Notebook Dell', 'Não liga') $$,
  'Técnico cria a primeira OS'
);

select lives_ok(
  $$ insert into public.ordens_servico (cliente_id, equipamento, descricao_problema)
     values ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'Celular Moto G', 'Tela quebrada') $$,
  'Técnico cria a segunda OS'
);

select results_eq(
  $$ select numero from public.ordens_servico order by numero $$,
  $$ values (1), (2) $$,
  'Numeração sequencial começa em 1 (RN005)'
);

select is(
  (select count(*)::int from public.historico_status_os), 2,
  'Cada OS nasce com um registro no histórico'
);

select throws_ok(
  $$ insert into public.ordens_servico (cliente_id, equipamento, descricao_problema)
     values ('c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2', 'Tablet', 'Não carrega') $$,
  '23503', null,
  'OS não pode usar cliente de outra organização'
);

select lives_ok(
  $$ insert into public.itens_os (os_id, descricao, quantidade, valor_unitario)
     values ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Troca de tela', 1, 350),
            ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Mão de obra',   1, 100) $$,
  'Técnico adiciona itens à OS'
);

select is(
  (select valor_total from public.ordens_servico where id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'),
  450::numeric,
  'Valor total é a soma dos itens (RN008)'
);

update public.ordens_servico set desconto = 50
where id = 'dddddddd-dddd-dddd-dddd-dddddddddddd';

select is(
  (select valor_total from public.ordens_servico where id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'),
  400::numeric,
  'Desconto é abatido do valor total (RN008)'
);

-- ===== Técnico A: status =====
select throws_ok(
  $$ update public.ordens_servico set status = 'pronta'
     where id = 'dddddddd-dddd-dddd-dddd-dddddddddddd' $$,
  '42501', null,
  'Status não pode ser alterado diretamente na tabela'
);

select throws_ok(
  $$ select public.alterar_status_os('dddddddd-dddd-dddd-dddd-dddddddddddd', 'pronta') $$,
  'P0001', null,
  'Não é possível pular de aberta para pronta (RN007)'
);

select lives_ok(
  $$ select public.alterar_status_os('dddddddd-dddd-dddd-dddd-dddddddddddd', 'em_analise') $$,
  'aberta → em_analise'
);

select lives_ok(
  $$ select public.alterar_status_os('dddddddd-dddd-dddd-dddd-dddddddddddd', 'em_andamento') $$,
  'em_analise → em_andamento'
);

select lives_ok(
  $$ select public.alterar_status_os('dddddddd-dddd-dddd-dddd-dddddddddddd', 'pronta') $$,
  'em_andamento → pronta'
);

select lives_ok(
  $$ select public.alterar_status_os('dddddddd-dddd-dddd-dddd-dddddddddddd', 'entregue') $$,
  'pronta → entregue'
);

select throws_ok(
  $$ insert into public.itens_os (os_id, descricao, valor_unitario)
     values ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Item extra', 10) $$,
  '42501', null,
  'OS entregue não aceita novos itens'
);

select throws_ok(
  $$ select public.alterar_status_os('dddddddd-dddd-dddd-dddd-dddddddddddd', 'em_analise', 'Voltou com defeito') $$,
  '42501', null,
  'Técnico não pode reabrir OS entregue'
);

select throws_ok(
  $$ select public.alterar_status_os(id, 'cancelada') from public.ordens_servico where numero = 2 $$,
  'P0001', null,
  'Cancelamento exige motivo (RN011)'
);

select lives_ok(
  $$ select public.alterar_status_os(id, 'cancelada', 'Cliente desistiu do reparo')
     from public.ordens_servico where numero = 2 $$,
  'Cancelamento com motivo é aceito'
);

select throws_ok(
  $$ delete from public.ordens_servico $$,
  '42501', null,
  'OS não pode ser apagada (RN011)'
);

select throws_ok(
  $$ insert into public.historico_status_os (organizacao_id, os_id, status_novo)
     values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'pronta') $$,
  '42501', null,
  'Histórico não aceita registros manuais (RN006)'
);

-- ===== Admin A: reabertura em garantia =====
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select lives_ok(
  $$ select public.alterar_status_os('dddddddd-dddd-dddd-dddd-dddddddddddd', 'em_analise', 'Retorno em garantia') $$,
  'Administrador reabre OS entregue com motivo'
);

select is(
  (select count(*)::int from public.historico_status_os
   where os_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'),
  6,
  'Histórico registra todas as mudanças da OS (RN006)'
);

-- ===== Admin B: isolamento =====
set local request.jwt.claims to '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}';

select is(
  (select count(*)::int from public.ordens_servico), 0,
  'Admin B não vê OS da organização A'
);

select throws_ok(
  $$ select public.alterar_status_os('dddddddd-dddd-dddd-dddd-dddddddddddd', 'cancelada', 'Invasão') $$,
  'P0002', null,
  'Admin B não altera status de OS da organização A'
);

select lives_ok(
  $$ insert into public.ordens_servico (cliente_id, equipamento, descricao_problema)
     values ('c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2', 'Impressora HP', 'Atolando papel') $$,
  'Admin B cria OS na própria organização'
);

select is(
  (select numero from public.ordens_servico), 1,
  'Numeração da organização B é independente da A (RN005)'
);

-- ===== Visitante =====
reset role;
set local role anon;
set local request.jwt.claims to '{"role":"anon"}';

select throws_ok(
  $$ select * from public.ordens_servico $$,
  '42501', null,
  'Visitante não lê OS'
);

select * from finish();
rollback;