# Domínio PETRA

Esta camada concentra as entidades mínimas do fluxo operacional: clientes, orçamentos, pedidos, medição, produção e instalação.

Regras críticas:
- Pedido encerrado não pode ser alterado.
- Ordem de corte só pode ser liberada quando o pedido possui data de medição registrada.

A persistência local adicionada nesta etapa é apenas uma base temporária para a interface. O banco multiempresa definitivo deve substituir o armazenamento local antes de uso produtivo.