-- Papéis possíveis de um membro
create type public.papel_membro as enum ('administrador', 'tecnico');

-- Organização = cliente do SaaS (a assistência técnica)
create table public.organizacoes (
  id            uuid primary key default gen_random_uuid(),
  nome          text not null check (char_length(trim(nome)) between 2 and 120),
  documento     text,
  telefone      text,
  endereco      text,
  logo_url      text,
  plano         text not null default 'gratuito' check (plano in ('gratuito', 'pro')),
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- Membro = vínculo de um usuário (auth.users) com uma organização
create table public.membros (
  id             uuid primary key default gen_random_uuid(),
  organizacao_id uuid not null references public.organizacoes (id) on delete cascade,
  usuario_id     uuid not null references auth.users (id) on delete cascade,
  nome           text not null check (char_length(trim(nome)) between 2 and 120),
  papel          public.papel_membro not null default 'tecnico',
  ativo          boolean not null default true,
  criado_em      timestamptz not null default now(),
  unique (organizacao_id, usuario_id)
);

create index membros_usuario_id_idx on public.membros (usuario_id);

-- O usuário logado é membro ativo desta organização?
create function public.eh_membro(org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.membros m
    where m.organizacao_id = org_id
      and m.usuario_id = (select auth.uid())
      and m.ativo
  );
$$;

-- O usuário logado é administrador ativo desta organização?
create function public.eh_admin(org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.membros m
    where m.organizacao_id = org_id
      and m.usuario_id = (select auth.uid())
      and m.ativo
      and m.papel = 'administrador'
  );
$$;

revoke execute on function public.eh_membro(uuid) from public, anon;
revoke execute on function public.eh_admin(uuid)  from public, anon;
grant  execute on function public.eh_membro(uuid) to authenticated;
grant  execute on function public.eh_admin(uuid)  to authenticated;

create function public.definir_atualizado_em()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

create trigger organizacoes_atualizado_em
  before update on public.organizacoes
  for each row execute function public.definir_atualizado_em();


alter table public.organizacoes enable row level security;
alter table public.membros      enable row level security;

-- Visitantes não logados não acessam nada
revoke all on public.organizacoes, public.membros from anon;

-- Usuários logados só podem alterar colunas específicas
revoke update on public.organizacoes from authenticated;
grant  update (nome, documento, telefone, endereco, logo_url) on public.organizacoes to authenticated;

revoke update on public.membros from authenticated;
grant  update (nome, papel, ativo) on public.membros to authenticated;

-- ORGANIZAÇÕES
create policy "membros veem a propria organizacao"
  on public.organizacoes for select to authenticated
  using (public.eh_membro(id));

create policy "admin altera a propria organizacao"
  on public.organizacoes for update to authenticated
  using (public.eh_admin(id))
  with check (public.eh_admin(id));

-- MEMBROS
create policy "membros veem colegas da organizacao"
  on public.membros for select to authenticated
  using (public.eh_membro(organizacao_id));

create policy "admin altera membros da organizacao"
  on public.membros for update to authenticated
  using (public.eh_admin(organizacao_id))
  with check (public.eh_admin(organizacao_id));

create function public.criar_organizacao(p_nome_organizacao text, p_nome_membro text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_usuario_id uuid := auth.uid();
  v_org_id     uuid;
begin
  if v_usuario_id is null then
    raise exception 'Usuário não autenticado';
  end if;

  if exists (select 1 from public.membros where usuario_id = v_usuario_id) then
    raise exception 'Usuário já pertence a uma organização';
  end if;

  insert into public.organizacoes (nome)
  values (trim(p_nome_organizacao))
  returning id into v_org_id;

  insert into public.membros (organizacao_id, usuario_id, nome, papel)
  values (v_org_id, v_usuario_id, trim(p_nome_membro), 'administrador');

  return v_org_id;
end;
$$;

revoke execute on function public.criar_organizacao(text, text) from public, anon;
grant  execute on function public.criar_organizacao(text, text) to authenticated;

