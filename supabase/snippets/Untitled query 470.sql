select public.criar_os_digitada(
  p_equipamento        => 'Aparelho de teste ' || n,
  p_descricao_problema => 'Teste da lista',
  p_cliente_nome       => 'Cliente ' || n,
  p_cliente_telefone   => '+557199' || lpad(n::text, 7, '0')
)
from generate_series(1, 70) as n,
lateral (
  select set_config('request.jwt.claims',
    json_build_object('sub', (select id from auth.users where email = 'dev@geraos.local'),
                      'role', 'authenticated')::text, true)
) as login;