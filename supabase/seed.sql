-- Dados de exemplo para o ambiente LOCAL.
-- Executado automaticamente após as migrations em `supabase db reset`.
-- Nunca vai para a nuvem: o `db push` envia só as migrations.
--
-- Login: dev@geraos.local / Geraos2026

-- ===== 1. Usuário de desenvolvimento (já com o e-mail confirmado) =====
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
) values (
  '00000000-0000-0000-0000-000000000000',
  'eeeeeeee-0000-0000-0000-000000000001',
  'authenticated', 'authenticated',
  'dev@geraos.local',
  extensions.crypt('Geraos2026', extensions.gen_salt('bf')),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"nome": "Euzébio Souza", "nome_organizacao": "TecFix Assistência"}',
  now(), now(),
  '', '', '', ''
);

insert into auth.identities (
  id, user_id, provider_id, identity_data, provider,
  last_sign_in_at, created_at, updated_at
) values (
  gen_random_uuid(),
  'eeeeeeee-0000-0000-0000-000000000001',
  'eeeeeeee-0000-0000-0000-000000000001',
  '{"sub": "eeeeeeee-0000-0000-0000-000000000001", "email": "dev@geraos.local"}',
  'email',
  now(), now(), now()
);

-- ===== 2. Empresa e membro administrador =====
insert into public.organizacoes (id, nome, telefone) values
  ('0a0a0a0a-0000-0000-0000-000000000001', 'TecFix Assistência', '+557132341180');

insert into public.membros (organizacao_id, usuario_id, nome, papel) values
  ('0a0a0a0a-0000-0000-0000-000000000001',
   'eeeeeeee-0000-0000-0000-000000000001',
   'Euzébio Souza', 'administrador');

-- ===== 3. Clientes =====
insert into public.clientes (id, organizacao_id, nome, telefone, email) values
  ('0b0b0b0b-0000-0000-0000-000000000001', '0a0a0a0a-0000-0000-0000-000000000001', 'Vanessa Teixeira',  '+5571998761203', null),
  ('0b0b0b0b-0000-0000-0000-000000000002', '0a0a0a0a-0000-0000-0000-000000000001', 'Roberto Alves',     '+5571982307781', null),
  ('0b0b0b0b-0000-0000-0000-000000000003', '0a0a0a0a-0000-0000-0000-000000000001', 'Paulo Sérgio Dias', '+5575991023344', 'paulo.dias@exemplo.com'),
  ('0b0b0b0b-0000-0000-0000-000000000004', '0a0a0a0a-0000-0000-0000-000000000001', 'Ana Beatriz Lima',  '+5571987012234', null),
  ('0b0b0b0b-0000-0000-0000-000000000005', '0a0a0a0a-0000-0000-0000-000000000001', 'Carlos Menezes',    '+5571991205567', null),
  ('0b0b0b0b-0000-0000-0000-000000000006', '0a0a0a0a-0000-0000-0000-000000000001', 'Fernanda Rocha',    '+5571984550912', null),
  ('0b0b0b0b-0000-0000-0000-000000000007', '0a0a0a0a-0000-0000-0000-000000000001', 'Marina Costa',      '+5571992341180', 'marina.costa@exemplo.com'),
  ('0b0b0b0b-0000-0000-0000-000000000008', '0a0a0a0a-0000-0000-0000-000000000001', 'João Pereira',      '+5571988124410', null);

-- ===== 4. Ordens de serviço =====
-- Inseridas da mais antiga para a mais recente: o trigger numera na ordem.
insert into public.ordens_servico
  (id, organizacao_id, cliente_id, equipamento, descricao_problema, acessorios, criado_em)
values
  ('0c0c0c0c-0000-0000-0000-000000000001', '0a0a0a0a-0000-0000-0000-000000000001', '0b0b0b0b-0000-0000-0000-000000000001',
   'Micro-ondas Electrolux', 'Não esquenta', null, now() - interval '10 days'),
  ('0c0c0c0c-0000-0000-0000-000000000002', '0a0a0a0a-0000-0000-0000-000000000001', '0b0b0b0b-0000-0000-0000-000000000002',
   'Galaxy A54', 'Não carrega', 'Carregador', now() - interval '7 days'),
  ('0c0c0c0c-0000-0000-0000-000000000003', '0a0a0a0a-0000-0000-0000-000000000001', '0b0b0b0b-0000-0000-0000-000000000003',
   'Notebook Lenovo IdeaPad', 'Muito lento para ligar', 'Carregador', now() - interval '6 days'),
  ('0c0c0c0c-0000-0000-0000-000000000004', '0a0a0a0a-0000-0000-0000-000000000001', '0b0b0b0b-0000-0000-0000-000000000004',
   'Impressora HP 2774', 'Atolando papel', null, now() - interval '2 days'),
  ('0c0c0c0c-0000-0000-0000-000000000005', '0a0a0a0a-0000-0000-0000-000000000001', '0b0b0b0b-0000-0000-0000-000000000005',
   'Smart TV LG 50"', 'Liga, mas fica sem imagem', 'Controle remoto', now() - interval '1 day 4 hours'),
  ('0c0c0c0c-0000-0000-0000-000000000006', '0a0a0a0a-0000-0000-0000-000000000001', '0b0b0b0b-0000-0000-0000-000000000006',
   'Tablet Samsung Tab A', 'Tela não responde ao toque', 'Capinha', now() - interval '1 day'),
  ('0c0c0c0c-0000-0000-0000-000000000007', '0a0a0a0a-0000-0000-0000-000000000001', '0b0b0b0b-0000-0000-0000-000000000007',
   'iPhone 12 · 128 GB · preto', 'Tela trincada após queda. Touch falhando no canto inferior.', 'Capinha', now() - interval '3 hours'),
  ('0c0c0c0c-0000-0000-0000-000000000008', '0a0a0a0a-0000-0000-0000-000000000001', '0b0b0b0b-0000-0000-0000-000000000008',
   'Notebook Dell Inspiron 15', 'Não liga', 'Carregador', now() - interval '30 minutes');

-- ===== 5. Itens (o total de cada OS é calculado pelo trigger) =====
insert into public.itens_os (organizacao_id, os_id, tipo, descricao, quantidade, valor_unitario) values
  ('0a0a0a0a-0000-0000-0000-000000000001', '0c0c0c0c-0000-0000-0000-000000000002', 'peca',    'Conector de carga',  1, 180),
  ('0a0a0a0a-0000-0000-0000-000000000001', '0c0c0c0c-0000-0000-0000-000000000002', 'servico', 'Mão de obra',        1,  40),
  ('0a0a0a0a-0000-0000-0000-000000000001', '0c0c0c0c-0000-0000-0000-000000000003', 'peca',    'SSD 480 GB',         1, 200),
  ('0a0a0a0a-0000-0000-0000-000000000001', '0c0c0c0c-0000-0000-0000-000000000003', 'servico', 'Instalação e backup', 1, 50),
  ('0a0a0a0a-0000-0000-0000-000000000001', '0c0c0c0c-0000-0000-0000-000000000004', 'servico', 'Limpeza e ajuste do tracionador', 1, 150),
  ('0a0a0a0a-0000-0000-0000-000000000001', '0c0c0c0c-0000-0000-0000-000000000005', 'peca',    'Placa T-CON',        1, 380),
  ('0a0a0a0a-0000-0000-0000-000000000001', '0c0c0c0c-0000-0000-0000-000000000005', 'servico', 'Mão de obra',        1,  70),
  ('0a0a0a0a-0000-0000-0000-000000000001', '0c0c0c0c-0000-0000-0000-000000000007', 'peca',    'Tela (conjunto)',    1, 320),
  ('0a0a0a0a-0000-0000-0000-000000000001', '0c0c0c0c-0000-0000-0000-000000000007', 'servico', 'Mão de obra',        1,  60);

-- ===== 6. Status de cada OS =====
-- Direto na tabela, só para montar o cenário. No app, o status muda
-- pela função alterar_status_os, que também registra o histórico.
update public.ordens_servico set status = 'cancelada'
  where id = '0c0c0c0c-0000-0000-0000-000000000001';
update public.ordens_servico set status = 'pronta'
  where id = '0c0c0c0c-0000-0000-0000-000000000002';
update public.ordens_servico set status = 'aguardando_aprovacao'
  where id = '0c0c0c0c-0000-0000-0000-000000000003';
update public.ordens_servico set status = 'entregue', entregue_em = now() - interval '1 day'
  where id = '0c0c0c0c-0000-0000-0000-000000000004';
update public.ordens_servico set status = 'em_andamento'
  where id in ('0c0c0c0c-0000-0000-0000-000000000005', '0c0c0c0c-0000-0000-0000-000000000007');
update public.ordens_servico set status = 'em_analise'
  where id = '0c0c0c0c-0000-0000-0000-000000000006';
