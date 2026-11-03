-- Organização do usuário logado
create function public.organizacao_do_usuario()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select m.organizacao_id
  from public.membros m
  where m.usuario_id = (select auth.uid())
    and m.ativo
  order by m.criado_em
  limit 1;
$$;

revoke execute on function public.organizacao_do_usuario() from public, anon;
grant  execute on function public.organizacao_do_usuario() to authenticated;

create extension if not exists pg_trgm with schema extensions;

create table public.clientes (
  id             uuid primary key default gen_random_uuid(),
  organizacao_id uuid not null default public.organizacao_do_usuario()
                 references public.organizacoes (id) on delete cascade,
  nome           text not null check (char_length(trim(nome)) between 2 and 150),
  telefone       text check (telefone ~ '^\+[1-9][0-9]{7,14}$'),
  email          text check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  documento      text check (documento ~ '^([0-9]{11}|[0-9]{14})$'),
  observacoes    text check (char_length(observacoes) <= 1000),
  criado_em      timestamptz not null default now(),
  atualizado_em  timestamptz not null default now(),
  excluido_em    timestamptz,
  constraint clientes_contato_obrigatorio
    check (excluido_em is not null or telefone is not null or email is not null)
);

-- Listagem padrão por organização, em ordem alfabética
create index clientes_organizacao_nome_idx
  on public.clientes (organizacao_id, nome)
  where excluido_em is null;

-- Busca por telefone (usada pela IA para reconhecer clientes já cadastrados)
create index clientes_organizacao_telefone_idx
  on public.clientes (organizacao_id, telefone);

-- Busca por trecho do nome: "mari" encontra "Maria Souza"
create index clientes_nome_trgm_idx
  on public.clientes using gin (nome extensions.gin_trgm_ops)
  where excluido_em is null;

alter table public.clientes enable row level security;

revoke all    on public.clientes from anon;
revoke delete on public.clientes from authenticated;
revoke update on public.clientes from authenticated;
grant  update (nome, telefone, email, documento, observacoes, excluido_em)
  on public.clientes to authenticated;

create policy "membros veem clientes da organizacao"
  on public.clientes for select to authenticated
  using (public.eh_membro(organizacao_id));

create policy "membros cadastram clientes na organizacao"
  on public.clientes for insert to authenticated
  with check (public.eh_membro(organizacao_id));

create policy "membros alteram clientes da organizacao"
  on public.clientes for update to authenticated
  using (public.eh_membro(organizacao_id))
  with check (public.eh_membro(organizacao_id));

create trigger clientes_atualizado_em
  before update on public.clientes
  for each row execute function public.definir_atualizado_em();

