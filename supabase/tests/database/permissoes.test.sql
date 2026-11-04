begin;
create extension if not exists pgtap with schema extensions;

select plan(10);

-- table_privs_are confere a lista EXATA de permissões de tabela:
-- falha se faltar alguma ou se sobrar alguma.
select table_privs_are('public', 'organizacoes', 'authenticated',
  array['SELECT'], 'Logado só lê organizações (alteração é por coluna)');

select table_privs_are('public', 'membros', 'authenticated',
  array['SELECT'], 'Logado só lê membros (alteração é por coluna)');

select table_privs_are('public', 'clientes', 'authenticated',
  array['SELECT', 'INSERT'], 'Logado lê e cadastra clientes, sem apagar');

select table_privs_are('public', 'ordens_servico', 'authenticated',
  array['SELECT', 'INSERT'], 'Logado lê e cria OS, sem apagar');

select table_privs_are('public', 'itens_os', 'authenticated',
  array['SELECT', 'INSERT', 'DELETE'], 'Logado lê, inclui e remove itens');

select table_privs_are('public', 'historico_status_os', 'authenticated',
  array['SELECT'], 'Histórico é somente leitura');

select table_privs_are('public', 'contadores_os', 'authenticated',
  array[]::text[], 'Contador é inacessível para o app');

select table_privs_are('public', 'clientes', 'anon',
  array[]::text[], 'Visitante não tem nenhuma permissão');

select table_privs_are('public', 'ordens_servico_resumo', 'authenticated',
  array['SELECT'], 'Logado só lê o resumo de OS');

select table_privs_are('public', 'clientes_resumo', 'authenticated',
  array['SELECT'], 'Logado só lê o resumo de clientes');

select * from finish();
rollback;