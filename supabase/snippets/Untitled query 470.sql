insert into public.clientes (organizacao_id, nome, telefone)
select m.organizacao_id, c.nome, c.telefone
from public.membros m
cross join (values
  ('Marina Costa',      '+5571992341180'),
  ('Carlos Menezes',    '+5571991205567'),
  ('Ana Beatriz Lima',  '+5571987012234'),
  ('Paulo Sérgio Dias', '+5575991023344')
) as c(nome, telefone)
where m.usuario_id = (select id from auth.users where email = 'kemano2040@emailkeep.com');