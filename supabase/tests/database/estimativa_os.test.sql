begin;
create extension if not exists pgtap with schema extensions;

select plan(14);

-- ===== Preparação (superusuário) =====
insert into auth.users (id, email) values
  ('22222222-2222-2222-2222-222222222222', 'tecnico.a@teste.com');

insert into public.organizacoes (id, nome) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Assistência A');

insert into public.membros (organizacao_id, usuario_id, nome, papel) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Técnico A', 'tecnico');

insert into public.clientes (id, organizacao_id, nome, telefone) values
  ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Maria Souza', '+5575999990000');

-- ===== Técnico A =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

select lives_ok(
  $$ select public.criar_os_digitada(
       p_equipamento        => 'Notebook Dell Inspiron 15',
       p_descricao_problema => 'Não liga',
       p_cliente_id         => 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1',
       p_valor_estimado     => 150
     ) $$,
  'Cria OS com valor estimado'
);

select is(
  (select estimativa from public.itens_os), true,
  'O valor estimado nasce marcado como estimativa'
);

select lives_ok(
  $$ insert into public.itens_os (os_id, tipo, descricao, quantidade, valor_unitario)
     select id, 'peca', 'Tela (conjunto)', 1, 320
       from public.ordens_servico
      where equipamento = 'Notebook Dell Inspiron 15' $$,
  'Adiciona o primeiro item de verdade'
);

select is(
  (select count(*)::int from public.itens_os i
     join public.ordens_servico o on o.id = i.os_id
    where o.equipamento = 'Notebook Dell Inspiron 15'),
  1,
  'A estimativa saiu quando entrou o primeiro item de verdade'
);

select is(
  (select descricao from public.itens_os i
     join public.ordens_servico o on o.id = i.os_id
    where o.equipamento = 'Notebook Dell Inspiron 15'),
  'Tela (conjunto)',
  'Ficou só o item de verdade'
);

select is(
  (select valor_total from public.ordens_servico
    where equipamento = 'Notebook Dell Inspiron 15'),
  320::numeric,
  'O total não soma mais a estimativa'
);

select lives_ok(
  $$ insert into public.itens_os (os_id, tipo, descricao, quantidade, valor_unitario)
     select id, 'servico', 'Mão de obra', 1, 60
       from public.ordens_servico
      where equipamento = 'Notebook Dell Inspiron 15' $$,
  'Adiciona o segundo item de verdade'
);

select is(
  (select count(*)::int from public.itens_os i
     join public.ordens_servico o on o.id = i.os_id
    where o.equipamento = 'Notebook Dell Inspiron 15'),
  2,
  'Um item de verdade não apaga outro item de verdade'
);

select is(
  (select valor_total from public.ordens_servico
    where equipamento = 'Notebook Dell Inspiron 15'),
  380::numeric,
  'O total soma os dois itens de verdade'
);

-- A estimativa de outra OS não é mexida.
select lives_ok(
  $$ select public.criar_os_digitada(
       p_equipamento        => 'iPhone 12',
       p_descricao_problema => 'Tela quebrada',
       p_cliente_id         => 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1',
       p_valor_estimado     => 100
     ) $$,
  'Cria uma segunda OS com valor estimado'
);

select lives_ok(
  $$ insert into public.itens_os (os_id, tipo, descricao, quantidade, valor_unitario)
     select id, 'peca', 'Película', 1, 30
       from public.ordens_servico
      where equipamento = 'Notebook Dell Inspiron 15' $$,
  'Adiciona um item na primeira OS'
);

select is(
  (select count(*)::int from public.itens_os i
     join public.ordens_servico o on o.id = i.os_id
    where o.equipamento = 'iPhone 12'),
  1,
  'A estimativa da segunda OS continua lá'
);

select throws_ok(
  $$ update public.itens_os set estimativa = true $$,
  '42501', null,
  'Ninguém muda a marca de estimativa depois de criada'
);

-- ===== Conferência =====
reset role;

select is(
  has_function_privilege('authenticated', 'public.remover_estimativa_os()', 'execute'),
  false,
  'A função do trigger não é chamável pela API'
);

select * from finish();
rollback;
