# PETRA — Integração com Bolt

## Objetivo
O Bolt deve atuar como camada de aplicação/interface do PETRA, consumindo a API e respeitando as regras do banco. Não duplicar regras críticas no frontend.

## Fonte de verdade
- Banco: `petra` PostgreSQL.
- API: `/api/v1/*`.
- Automações: `petra.automation_jobs`.
- Auditoria: `petra.events` e `petra.audit_log`.
- Por empresa: toda consulta e gravação deve carregar o contexto autenticado da empresa.

## Fluxo principal
1. Cliente/obra/ambiente
2. Orçamento
3. Orçamento aprovado
4. Pedido
5. Pagamento reconhecido
6. Conferência/medição
7. Medição aprovada com data
8. Desenho técnico/compatibilização
9. Liberação de produção
10. Produção
11. Acabamento
12. Carregamento/expedição
13. Instalação
14. Finalização
15. Pós-venda

## Gates obrigatórios
- Pedido encerrado é imutável.
- Nenhuma ordem de produção pode ser liberada sem medição aprovada e com data.
- Produção e etapas posteriores exigem uma liberação de produção válida.
- O contexto de empresa não pode ser escolhido pelo cliente em produção; deve vir da autenticação.

## Automações implementadas no banco
- `quote.approved` → `order.create`
- `measurement.approved` → `technical.ready`
- `production.released` → `production.prepare`
- `installation.scheduled` → `customer.notify`
- `installation.completed` → `post_sale.start`
- `order.finished` → `trello.card.create` com título `PEDIDO`
- `order.finished` → `customer.post_sale`
- `payment.recognized` → `order.payment-confirmed`

Os jobs são persistidos e podem ser processados por um worker/adaptador. Credenciais de Trello, WhatsApp ou outros provedores nunca devem ser gravadas no frontend ou no repositório.

## Variáveis mínimas
`PETRA_DATABASE_URL` é obrigatória para persistência real. `PETRA_ENVIRONMENT` define o ambiente. `MOTOR_PETRA_URL` e `MOTOR_PETRA_SERVICE_TOKEN` são opcionais para integração com o MOTOR PETRA.

## Checklist do Bolt
- [ ] Conectar ao endpoint publicado do PETRA.
- [ ] Configurar `PETRA_DATABASE_URL` no backend/ambiente seguro.
- [ ] Executar migrations 001 → 004.
- [ ] Implementar login real e obter empresa/usuário pelo contexto autenticado.
- [ ] Consumir `/api/v1/dashboard`, `/clients`, `/orders` e demais rotas à medida que forem disponibilizadas.
- [ ] Exibir estado dos jobs de automação sem permitir edição manual das regras.
- [ ] Nunca liberar produção diretamente pelo frontend sem chamar o endpoint do PETRA.
- [ ] Não alterar o app antigo da Porcelane.

## Sem créditos
A migration e a lógica de automação acima são código próprio e não dependem de créditos do Bolt. O que depende de configuração externa é banco, autenticação e credenciais dos provedores de integração.
