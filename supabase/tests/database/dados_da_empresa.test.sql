begin;
create extension if not exists pgtap with schema extensions;

select plan(5);

insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'admin.a@teste.com'),
  ('22222222-2222-2222-2222-222222222222', 'tecnico.a@teste.com');

insert into public.organizacoes (id, nome) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Assistência A');

insert into public.membros (organizacao_id, usuario_id, nome, papel) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Admin A',   'administrador'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Técnico A', 'tecnico');

-- ===== Admin A =====
set local role authenticated;
set local request.jwt.claims to '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}';

select lives_ok(
  $$ update public.organizacoes
     set telefone = '+557132341180', termos_garantia = 'Garantia de 90 dias.'
     where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' $$,
  'Admin atualiza os dados da empresa'
);

select throws_ok(
  $$ update public.organizacoes set telefone = '71 3234-1180'
     where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' $$,
  '23514', null,
  'Telefone fora do formato internacional é recusado'
);

select throws_ok(
  $$ update public.organizacoes set documento = '12345'
     where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' $$,
  '23514', null,
  'CNPJ ou CPF com a quantidade errada de dígitos é recusado'
);

-- ===== Técnico A =====
set local request.jwt.claims to '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}';

update public.organizacoes set termos_garantia = 'Sem garantia'
where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

select is(
  (select termos_garantia from public.organizacoes
   where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'Garantia de 90 dias.',
  'Técnico não altera os dados da empresa (o RLS ignora a alteração)'
);

select is(
  (select telefone from public.organizacoes
   where id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  '+557132341180',
  'Técnico lê os dados da empresa, que vão no PDF da OS'
);

select * from finish();
rollback;
