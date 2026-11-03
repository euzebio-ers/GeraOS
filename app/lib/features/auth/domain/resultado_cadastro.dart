/// O que acontece depois que a conta é criada.
enum ResultadoCadastro {
  /// A conta já está ativa e o usuário entrou automaticamente.
  logado,

  /// O usuário precisa clicar no link enviado por e-mail antes de entrar.
  confirmarEmail,
}
