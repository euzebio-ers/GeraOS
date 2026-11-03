-- Funções de trigger não devem ser chamáveis pela API.
-- Os triggers continuam funcionando: a permissão de execução
-- só é verificada quando o trigger é criado.
revoke execute on function public.criar_contador_os()     from public, anon, authenticated;
revoke execute on function public.preparar_nova_os()      from public, anon, authenticated;
revoke execute on function public.registrar_criacao_os()  from public, anon, authenticated;
revoke execute on function public.recalcular_valor_os()   from public, anon, authenticated;
revoke execute on function public.aplicar_desconto_os()   from public, anon, authenticated;
revoke execute on function public.definir_atualizado_em() from public, anon, authenticated;