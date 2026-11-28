/// Assuntos da ajuda do app (o botão "i"). Os textos ficam todos aqui,
/// num lugar só, para serem revisados juntos e reaproveitados pelo tutorial.
enum TopicoAjuda {
  statusOs('Etapas da OS', [
    'Toda OS passa pelas etapas Pendente, Em andamento, Pronta para retirar '
        'e Concluída. Use "Mudar status" para avançar: o app mostra só os '
        'próximos passos possíveis.',
    'Pendente reúne a OS recém-aberta e a que está em análise. Quando o '
        'orçamento precisa do "sim" do cliente, use "Aguardando aprovação" '
        'antes de começar o conserto.',
    'Para cancelar, é preciso informar o motivo. Uma OS concluída só pode '
        'ser reaberta por um administrador, em caso de retorno na garantia.',
    'Cada mudança fica registrada no histórico, com quem fez e quando.',
  ]),
  orcamento('Orçamento', [
    'O orçamento é a lista de peças e serviços da OS. O total é a soma dos '
        'itens, menos o desconto.',
    'Toque num item para editar ou remover. Em "Dar desconto", escolha entre '
        'reais e porcentagem: em porcentagem, o desconto acompanha o '
        'orçamento se itens mudarem; em reais, fica fixo.',
    'O valor estimado informado ao criar a OS aparece como "Orçamento '
        'inicial" e sai sozinho quando você adiciona a primeira peça ou '
        'serviço.',
    'Depois que a OS é concluída ou cancelada, o orçamento não pode mais '
        'ser alterado.',
  ]),
  bancada('Hoje na bancada', [
    'Mostra quantas OS estão em cada etapa agora: Pendentes (abertas ou em '
        'análise), Em andamento (em conserto) e Prontas para retirar '
        '(esperando o cliente).',
    'Toque em um dos números para abrir a lista de OS já filtrada.',
  ]),
  faturamento('Faturamento do mês', [
    'Soma das OS concluídas (entregues ao cliente) neste mês, contando pela '
        'data de entrega.',
    'OS prontas que o cliente ainda não retirou não entram, porque o valor '
        'ainda não foi recebido.',
    'Só administradores veem o faturamento.',
  ]),
  valorEstimado('Valor estimado', [
    'Um valor aproximado, combinado com o cliente na entrada do aparelho. '
        'É opcional: vazio, a OS aparece como "a orçar".',
    'Ele entra no orçamento como "Orçamento inicial" e sai sozinho quando '
        'você adiciona a primeira peça ou serviço de verdade.',
  ]);

  const TopicoAjuda(this.titulo, this.paragrafos);

  final String titulo;
  final List<String> paragrafos;
}
