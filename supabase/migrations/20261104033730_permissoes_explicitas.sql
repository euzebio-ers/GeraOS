-- Permissões declaradas explicitamente, sem depender dos padrões do ambiente.
-- O RLS decide QUAIS linhas cada pessoa vê; 
-- QUAIS operações cada papel pode tentar.

-- 1. Começa do zero para visitantes e usuários logados
--    (revogar na tabela também revoga as permissões por coluna)
revoke all on all tables in schema public from anon, authenticated;

-- 2. Leitura
grant select on
  public.organizacoes,
  public.membros,
  public.clientes,
  public.ordens_servico,
  public.itens_os,
  public.historico_status_os
to authenticated;

-- 3. Inclusão
grant insert on public.clientes, public.ordens_servico, public.itens_os
to authenticated;

-- 4. Exclusão (só itens de OS ainda em aberto, conforme o RLS)
grant delete on public.itens_os to authenticated;

-- 5. Alteração, apenas nas colunas permitidas (as mesmas de antes)
grant update (nome, documento, telefone, endereco, logo_url)
  on public.organizacoes to authenticated;
grant update (nome, papel, ativo)
  on public.membros to authenticated;
grant update (nome, telefone, email, documento, observacoes, excluido_em)
  on public.clientes to authenticated;
grant update (cliente_id, responsavel_id, equipamento, descricao_problema,
              diagnostico, desconto, previsao_entrega)
  on public.ordens_servico to authenticated;
grant update (tipo, descricao, quantidade, valor_unitario)
  on public.itens_os to authenticated;

-- 6. As Edge Functions usam o service_role, que ignora o RLS,
--    mas ainda precisa das permissões de tabela
grant select, insert, update, delete on all tables in schema public
to service_role;