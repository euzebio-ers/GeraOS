-- O "Orçamento inicial" é só uma estimativa. Quando entra o primeiro item
-- de verdade, ele sai, para não continuar somando no total.

-- 1. Marca o item que nasce do valor estimado. A coluna não entra no
--    "grant update", então a marca não muda depois de criada.
alter table public.itens_os
  add column estimativa boolean not null default false;

-- 2. Nas OS que já existem, o "Orçamento inicial" também é uma estimativa.
update public.itens_os
   set estimativa = true
 where descricao = 'Orçamento inicial'
   and tipo = 'servico';

-- 3. criar_os_digitada passa a marcar o item como estimativa.
--    "create or replace" mantém as permissões que a função já tinha.
create or replace function public.criar_os_digitada(
  p_equipamento        text,
  p_descricao_problema text,
  p_cliente_id         uuid    default null,
  p_cliente_nome       text    default null,
  p_cliente_telefone   text    default null,
  p_cliente_email      text    default null,
  p_acessorios         text    default null,
  p_valor_estimado     numeric default null,
  p_previsao_entrega   date    default null,
  p_origem             text    default 'manual'
)
returns public.ordens_servico
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_cliente_id uuid := p_cliente_id;
  v_os         public.ordens_servico;
begin
  -- 1. Cliente: o escolhido na busca ou um novo.
  if v_cliente_id is null then
    if nullif(trim(p_cliente_nome), '') is null then
      raise exception 'Informe o cliente da OS';
    end if;

    insert into public.clientes (nome, telefone, email)
    values (
      trim(p_cliente_nome),
      nullif(trim(p_cliente_telefone), ''),
      nullif(trim(p_cliente_email), '')
    )
    returning id into v_cliente_id;
  end if;

  -- 2. A OS. Número, status e token vêm do trigger preparar_nova_os.
  insert into public.ordens_servico
    (cliente_id, equipamento, descricao_problema, acessorios,
     previsao_entrega, origem)
  values (
    v_cliente_id,
    trim(p_equipamento),
    trim(p_descricao_problema),
    nullif(trim(p_acessorios), ''),
    p_previsao_entrega,
    p_origem
  )
  returning * into v_os;

  -- 3. Valor estimado vira o primeiro item, marcado como estimativa.
  --    O total é recalculado pelo trigger recalcular_valor_os,
  --    então relemos a OS.
  if p_valor_estimado is not null and p_valor_estimado > 0 then
    insert into public.itens_os
      (os_id, tipo, descricao, quantidade, valor_unitario, estimativa)
    values (v_os.id, 'servico', 'Orçamento inicial', 1, p_valor_estimado, true);

    select * into v_os from public.ordens_servico where id = v_os.id;
  end if;

  return v_os;
end;
$$;

-- 4. Quando entra um item de verdade, a estimativa da mesma OS sai.
--    security invoker: o RLS vale, então só apaga em OS ainda em aberto.
create function public.remover_estimativa_os()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not new.estimativa then
    delete from public.itens_os
     where os_id = new.os_id
       and estimativa;
  end if;

  return null;
end;
$$;

-- Função de trigger não deve ser chamável pela API (igual às outras).
revoke execute on function public.remover_estimativa_os()
  from public, anon, authenticated;

create trigger itens_os_remover_estimativa
  after insert on public.itens_os
  for each row execute function public.remover_estimativa_os();
