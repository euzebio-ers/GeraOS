begin;
create extension if not exists pgtap with schema extensions;

select plan(8);

insert into auth.users (id, email) values
  ('22222222-2222-2222-2222-222222222222', 'tecnico.a@teste.com');

insert into public.organizacoes (id, nome) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Assistência A');

insert into public.membros (organizacao_id, usuario_id, nome, papel) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Técnico A', 'tecnico');

insert into public.clientes (id, organizacao_id, nome, telefone) values
  ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Maria Souza', '+5575999990000');

set local role authenticated;
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

insert into public.ordens_servico (id, cliente_id, equipamento, descricao_problema)
values ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'iPhone 12', 'Tela quebrada');

insert into public.itens_os (os_id, descricao, valor_unitario)
values ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'Tela', 300);

select lives_ok(
  $$ update public.ordens_servico set desconto_percentual = 10
     where id = 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1' $$,
  'Técnico dá desconto em porcentagem'
);

select results_eq(
  $$ select desconto, valor_total from public.ordens_servico $$,
  $$ values (30::numeric, 270::numeric) $$,
  '10% de R$ 300 vira R$ 30 de desconto'
);

insert into public.itens_os (os_id, descricao, valor_unitario)
values ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'Bateria', 200);

select results_eq(
  $$ select desconto, valor_total from public.ordens_servico $$,
  $$ values (50::numeric, 450::numeric) $$,
  'Com um item novo, o desconto acompanha o subtotal'
);

delete from public.itens_os where descricao = 'Bateria';

select results_eq(
  $$ select desconto, valor_total from public.ordens_servico $$,
  $$ values (30::numeric, 270::numeric) $$,
  'Removendo um item, o desconto também é refeito'
);

update public.ordens_servico set desconto_percentual = null, desconto = 20
where id = 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1';

insert into public.itens_os (os_id, descricao, valor_unitario)
values ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'Película', 30);

select results_eq(
  $$ select desconto, valor_total from public.ordens_servico $$,
  $$ values (20::numeric, 310::numeric) $$,
  'Desconto em reais continua fixo quando os itens mudam'
);

select throws_ok(
  $$ update public.ordens_servico set desconto_percentual = 150
     where id = 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1' $$,
  '23514', null,
  'Porcentagem acima de 100% é recusada'
);

update public.ordens_servico set desconto_percentual = 12.5
where id = 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1';

select is(
  (public.detalhe_os('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1') ->> 'desconto_percentual')::numeric,
  12.5,
  'O detalhe da OS traz a porcentagem'
);

select is(
  (select desconto from public.ordens_servico),
  41.25::numeric(12,2),
  '12,5% de R$ 330 arredonda para R$ 41,25'
);

select * from finish();
rollback;
