-- Cria uma OS digitada numa única transação: o cliente (se for novo),
-- a OS e o item do valor estimado. Ou tudo é gravado, ou nada é.
--
-- security invoker: roda com as permissões de quem chama, então o RLS
-- de clientes, ordens_servico e itens_os vale normalmente em cada insert.
create function public.criar_os_digitada(
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

  -- 3. Valor estimado vira o primeiro item. O total é recalculado
  --    pelo trigger recalcular_valor_os, então relemos a OS.
  if p_valor_estimado is not null and p_valor_estimado > 0 then
    insert into public.itens_os (os_id, tipo, descricao, quantidade, valor_unitario)
    values (v_os.id, 'servico', 'Orçamento inicial', 1, p_valor_estimado);

    select * into v_os from public.ordens_servico where id = v_os.id;
  end if;

  return v_os;
end;
$$;

revoke execute on function public.criar_os_digitada(
  text, text, uuid, text, text, text, text, numeric, date, text
) from public, anon;

grant execute on function public.criar_os_digitada(
  text, text, uuid, text, text, text, text, numeric, date, text
) to authenticated;
