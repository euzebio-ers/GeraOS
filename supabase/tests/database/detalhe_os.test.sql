begin;
create extension if not exists pgtap with schema extensions;

select plan(5);

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
  ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Maria Souza', '+5575999990000');

-- ===== Técnico A cria e trabalha numa OS =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

insert into public.ordens_servico (id, cliente_id, equipamento, descricao_problema)
values ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'iPhone 12', 'Tela quebrada');

insert into public.itens_os (os_id, descricao, valor_unitario)
values ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'Tela (conjunto)', 320);

select public.alterar_status_os('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'em_analise');

select is(
  public.detalhe_os('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1') -> 'cliente' ->> 'nome',
  'Maria Souza',
  'O detalhe traz o cliente da OS'
);

select is(
  jsonb_array_length(public.detalhe_os('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1') -> 'itens'),
  1,
  'O detalhe traz os itens'
);

select is(
  public.detalhe_os('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1') -> 'historico' -> 0 ->> 'alterado_por_nome',
  'Técnico A',
  'O histórico vem do mais recente, com o nome de quem alterou'
);

-- ===== Admin B não vê a OS de A =====
set local request.jwt.claims to '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}';

select is(
  public.detalhe_os('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1'),
  null,
  'OS de outra organização não é encontrada'
);

reset role;

select is(
  (select prosecdef from pg_proc where proname = 'detalhe_os'),
  false,
  'A função roda com as permissões de quem chama (security invoker)'
);

select * from finish();
rollback;
