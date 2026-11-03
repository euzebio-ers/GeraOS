create type public.status_os as enum (
  'aberta', 'em_analise', 'aguardando_aprovacao',
  'em_andamento', 'pronta', 'entregue', 'cancelada'
);

create type public.tipo_item_os as enum ('servico', 'peca');

-- Permitem chaves estrangeiras que conferem também a organização
alter table public.clientes
  add constraint clientes_organizacao_id_id_key unique (organizacao_id, id);
alter table public.membros
  add constraint membros_organizacao_id_id_key unique (organizacao_id, id);

-- Último número de OS usado por cada organização (RN005)
create table public.contadores_os (
  organizacao_id uuid primary key references public.organizacoes (id) on delete cascade,
  ultimo_numero  integer not null default 0
);

create table public.ordens_servico (
  id                 uuid primary key default gen_random_uuid(),
  organizacao_id     uuid not null default public.organizacao_do_usuario()
                     references public.organizacoes (id) on delete cascade,
  numero             integer not null,
  cliente_id         uuid not null,
  responsavel_id     uuid,
  equipamento        text not null check (char_length(trim(equipamento)) between 2 and 200),
  descricao_problema text not null check (char_length(trim(descricao_problema)) between 3 and 2000),
  diagnostico        text check (char_length(diagnostico) <= 4000),
  status             public.status_os not null default 'aberta',
  desconto           numeric(12,2) not null default 0 check (desconto >= 0),
  valor_total        numeric(12,2) not null default 0 check (valor_total >= 0),
  previsao_entrega   date,
  origem             text not null default 'manual' check (origem in ('manual', 'audio')),
  token_publico      text not null unique,
  entregue_em        timestamptz,
  criado_por         uuid references auth.users (id) on delete set null,
  criado_em          timestamptz not null default now(),
  atualizado_em      timestamptz not null default now(),
  unique (organizacao_id, numero),
  unique (organizacao_id, id),
  foreign key (organizacao_id, cliente_id)
    references public.clientes (organizacao_id, id),
  foreign key (organizacao_id, responsavel_id)
    references public.membros (organizacao_id, id)
);

create index ordens_servico_listagem_idx
  on public.ordens_servico (organizacao_id, status, criado_em desc);
create index ordens_servico_cliente_idx
  on public.ordens_servico (organizacao_id, cliente_id);
create index ordens_servico_equipamento_trgm_idx
  on public.ordens_servico using gin (equipamento extensions.gin_trgm_ops);

create table public.itens_os (
  id             uuid primary key default gen_random_uuid(),
  organizacao_id uuid not null default public.organizacao_do_usuario(),
  os_id          uuid not null,
  tipo           public.tipo_item_os not null default 'servico',
  descricao      text not null check (char_length(trim(descricao)) between 2 and 300),
  quantidade     numeric(10,2) not null default 1 check (quantidade > 0),
  valor_unitario numeric(12,2) not null default 0 check (valor_unitario >= 0),
  criado_em      timestamptz not null default now(),
  foreign key (organizacao_id, os_id)
    references public.ordens_servico (organizacao_id, id) on delete cascade
);

create index itens_os_os_id_idx on public.itens_os (os_id);

create table public.historico_status_os (
  id              uuid primary key default gen_random_uuid(),
  organizacao_id  uuid not null,
  os_id           uuid not null,
  status_anterior public.status_os,
  status_novo     public.status_os not null,
  alterado_por    uuid references auth.users (id) on delete set null,
  observacao      text,
  alterado_em     timestamptz not null default now(),
  foreign key (organizacao_id, os_id)
    references public.ordens_servico (organizacao_id, id) on delete cascade
);

create index historico_status_os_os_idx on public.historico_status_os (os_id, alterado_em);

-- Toda organização nova ganha seu contador de OS
create function public.criar_contador_os()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.contadores_os (organizacao_id) values (new.id);
  return null;
end;
$$;

create trigger organizacoes_criar_contador
  after insert on public.organizacoes
  for each row execute function public.criar_contador_os();

-- Antes de gravar uma OS nova: número, status inicial, token e autor
create function public.preparar_nova_os()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.contadores_os
     set ultimo_numero = ultimo_numero + 1
   where organizacao_id = new.organizacao_id
  returning ultimo_numero into new.numero;

  if new.numero is null then
    raise exception 'Organização sem contador de OS';
  end if;

  new.status        := 'aberta';
  new.valor_total   := 0;
  new.entregue_em   := null;
  new.token_publico := encode(extensions.gen_random_bytes(16), 'hex');
  new.criado_por    := auth.uid();
  return new;
end;
$$;

create trigger ordens_servico_preparar
  before insert on public.ordens_servico
  for each row execute function public.preparar_nova_os();

-- Depois de criar a OS: primeiro registro do histórico
create function public.registrar_criacao_os()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.historico_status_os
    (organizacao_id, os_id, status_anterior, status_novo, alterado_por)
  values
    (new.organizacao_id, new.id, null, new.status, auth.uid());
  return null;
end;
$$;

create trigger ordens_servico_historico_inicial
  after insert on public.ordens_servico
  for each row execute function public.registrar_criacao_os();

create trigger ordens_servico_atualizado_em
  before update on public.ordens_servico
  for each row execute function public.definir_atualizado_em();

-- Recalcula o total quando itens entram, mudam ou saem
create function public.recalcular_valor_os()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_os_id uuid;
begin
  if tg_op = 'DELETE' then
    v_os_id := old.os_id;
  else
    v_os_id := new.os_id;
  end if;

  update public.ordens_servico o
     set valor_total = greatest(
           coalesce((select sum(i.quantidade * i.valor_unitario)
                     from public.itens_os i
                     where i.os_id = v_os_id), 0) - o.desconto,
           0)
   where o.id = v_os_id;

  return null;
end;
$$;

create trigger itens_os_recalcular_valor
  after insert or update or delete on public.itens_os
  for each row execute function public.recalcular_valor_os();

-- Recalcula o total quando o desconto muda
create function public.aplicar_desconto_os()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.valor_total := greatest(
    coalesce((select sum(i.quantidade * i.valor_unitario)
              from public.itens_os i
              where i.os_id = new.id), 0) - new.desconto,
    0);
  return new;
end;
$$;

create trigger ordens_servico_aplicar_desconto
  before update of desconto on public.ordens_servico
  for each row execute function public.aplicar_desconto_os();

create function public.transicao_status_valida(p_de public.status_os, p_para public.status_os)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select (p_de::text || '>' || p_para::text) in (
    'aberta>em_analise',            'aberta>cancelada',
    'em_analise>aguardando_aprovacao', 'em_analise>em_andamento', 'em_analise>cancelada',
    'aguardando_aprovacao>em_andamento', 'aguardando_aprovacao>cancelada',
    'em_andamento>pronta',          'em_andamento>cancelada',
    'pronta>entregue'
  );
$$;

create function public.alterar_status_os(
  p_os_id       uuid,
  p_novo_status public.status_os,
  p_observacao  text default null
)
returns public.ordens_servico
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_os         public.ordens_servico;
  v_anterior   public.status_os;
  v_observacao text := nullif(trim(p_observacao), '');
begin
  select * into v_os
  from public.ordens_servico
  where id = p_os_id
  for update;

  if not found or not public.eh_membro(v_os.organizacao_id) then
    raise exception 'OS não encontrada' using errcode = 'P0002';
  end if;

  v_anterior := v_os.status;

  if v_anterior = 'entregue' and p_novo_status = 'em_analise' then
    -- Reabertura (retorno em garantia): só administrador, com motivo
    if not public.eh_admin(v_os.organizacao_id) then
      raise exception 'Apenas administradores podem reabrir uma OS entregue'
        using errcode = '42501';
    end if;
    if v_observacao is null then
      raise exception 'Informe o motivo da reabertura';
    end if;
  elsif not public.transicao_status_valida(v_anterior, p_novo_status) then
    raise exception 'Transição de status não permitida: % para %', v_anterior, p_novo_status;
  end if;

  if p_novo_status = 'cancelada' and v_observacao is null then
    raise exception 'Informe o motivo do cancelamento';
  end if;

  update public.ordens_servico
     set status = p_novo_status,
         entregue_em = case
           when p_novo_status = 'entregue'   then now()
           when p_novo_status = 'em_analise' then null
           else entregue_em
         end
   where id = p_os_id
  returning * into v_os;

  insert into public.historico_status_os
    (organizacao_id, os_id, status_anterior, status_novo, alterado_por, observacao)
  values
    (v_os.organizacao_id, v_os.id, v_anterior, p_novo_status, auth.uid(), v_observacao);

  return v_os;
end;
$$;

revoke execute on function public.alterar_status_os(uuid, public.status_os, text) from public, anon;
grant  execute on function public.alterar_status_os(uuid, public.status_os, text) to authenticated;


alter table public.contadores_os       enable row level security;
alter table public.ordens_servico      enable row level security;
alter table public.itens_os            enable row level security;
alter table public.historico_status_os enable row level security;

revoke all on public.contadores_os, public.ordens_servico,
              public.itens_os, public.historico_status_os from anon;

-- Contador: acessível apenas pelas funções internas
revoke all on public.contadores_os from authenticated;

-- Histórico: somente leitura (RN006)
revoke all    on public.historico_status_os from authenticated;
grant  select on public.historico_status_os to authenticated;

-- OS: sem exclusão (RN011); status e valores só pelo banco
revoke update, delete on public.ordens_servico from authenticated;
grant  update (cliente_id, responsavel_id, equipamento, descricao_problema,
               diagnostico, desconto, previsao_entrega)
  on public.ordens_servico to authenticated;

-- Itens: não mudam de OS nem de organização
revoke update on public.itens_os from authenticated;
grant  update (tipo, descricao, quantidade, valor_unitario)
  on public.itens_os to authenticated;

-- ORDENS DE SERVIÇO
create policy "membros veem OS da organizacao"
  on public.ordens_servico for select to authenticated
  using (public.eh_membro(organizacao_id));

create policy "membros criam OS na organizacao"
  on public.ordens_servico for insert to authenticated
  with check (public.eh_membro(organizacao_id));

create policy "membros alteram OS da organizacao"
  on public.ordens_servico for update to authenticated
  using (public.eh_membro(organizacao_id))
  with check (public.eh_membro(organizacao_id));

-- ITENS (só alteráveis enquanto a OS não foi entregue nem cancelada)
create policy "membros veem itens da organizacao"
  on public.itens_os for select to authenticated
  using (public.eh_membro(organizacao_id));

create policy "membros incluem itens em OS em aberto"
  on public.itens_os for insert to authenticated
  with check (
    public.eh_membro(organizacao_id)
    and exists (select 1 from public.ordens_servico o
                where o.id = os_id and o.status not in ('entregue', 'cancelada'))
  );

create policy "membros alteram itens de OS em aberto"
  on public.itens_os for update to authenticated
  using (
    public.eh_membro(organizacao_id)
    and exists (select 1 from public.ordens_servico o
                where o.id = os_id and o.status not in ('entregue', 'cancelada'))
  )
  with check (public.eh_membro(organizacao_id));

create policy "membros removem itens de OS em aberto"
  on public.itens_os for delete to authenticated
  using (
    public.eh_membro(organizacao_id)
    and exists (select 1 from public.ordens_servico o
                where o.id = os_id and o.status not in ('entregue', 'cancelada'))
  );

-- HISTÓRICO
create policy "membros veem historico da organizacao"
  on public.historico_status_os for select to authenticated
  using (public.eh_membro(organizacao_id));


