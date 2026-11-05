-- Dados da empresa que vão no PDF da OS (RF006): e-mail e termos de
-- garantia, e a validação do formato dos campos que já existiam.

alter table public.organizacoes
  add column email text
    check (email is null or email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  add column termos_garantia text
    check (termos_garantia is null or char_length(termos_garantia) <= 2000);

alter table public.organizacoes
  add constraint organizacoes_telefone_formato
    check (telefone is null or telefone ~ '^\+[1-9][0-9]{7,14}$'),
  add constraint organizacoes_documento_formato
    check (documento is null or documento ~ '^([0-9]{11}|[0-9]{14})$'),
  add constraint organizacoes_endereco_tamanho
    check (endereco is null or char_length(endereco) <= 300);

-- As colunas novas também podem ser alteradas (o RLS limita ao administrador).
grant update (email, termos_garantia) on public.organizacoes to authenticated;
