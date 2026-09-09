# Status de Implementação do PETRA

## Concluído no repositório

- [x] README oficial e arquitetura PETRA ↔ MOTOR PETRA
- [x] Cliente/adaptador do MOTOR PETRA
- [x] Configuração por ambiente sem secrets no código
- [x] Runtime Node executável (`src/server.ts`)
- [x] Endpoint de saúde (`GET /health`)
- [x] Endpoint de catálogo da API (`GET /api`)
- [x] Handshake opcional com o MOTOR PETRA
- [x] Interface inicial do painel PETRA
- [x] Proteção de arquivos de ambiente no Git
- [x] Remoção da credencial de desenvolvimento que estava versionada
- [x] Dependência PostgreSQL e adaptador de banco (`src/core/database.ts`)
- [x] Configuração `PETRA_DATABASE_URL`
- [x] Schema inicial multiempresa
- [x] Clientes, obras, ambientes, orçamentos, pedidos, itens e documentos
- [x] Eventos e auditoria estruturados
- [x] Medição/conferência com status, data, checklist e evidências
- [x] Liberação de produção auditável
- [x] Regra de banco: produção exige medição aprovada com data
- [x] Regra de banco: pedido não entra em produção ou etapas posteriores sem liberação
- [x] Imutabilidade de pedido encerrado na camada de banco
- [x] Desenho técnico com A4, escala, dados do desenho e aprovação
- [x] Ordem de produção e itens de produção
- [x] Acabamento
- [x] Logística/carregamento
- [x] Instalação com equipe, checklist, evidências e aceite
- [x] Estoque e movimentos de estoque
- [x] Financeiro e status de pagamento
- [x] Comissões
- [x] Fila de automações/integradores
- [x] Sessões e mensagens do Assistente

## Ainda necessário antes de chamar o PETRA de produção

Estes itens dependem de infraestrutura/credenciais e execução real; não serão marcados como concluídos apenas por existir código:

- [ ] Executar as migrations `001_initial_petra.sql` e `002_operational_completion.sql` em um PostgreSQL real
- [ ] Configurar `PETRA_DATABASE_URL` no ambiente de execução
- [ ] Ligar os endpoints do runtime às tabelas reais e implementar CRUD completo por módulo
- [ ] Autenticação real e RBAC aplicado a cada rota/consulta
- [ ] Isolamento de tenant aplicado em runtime e, quando o ambiente estiver preparado, reforçado por RLS
- [ ] Storage documental real e upload/download de anexos
- [ ] Geração real de PDFs de orçamento, pedido, medição, produção, carregamento e instalação
- [ ] Editor de desenho técnico funcional (A4, escala, cotas, biblioteca, aprovação e exportação)
- [ ] Trello/WhatsApp e demais integrações com credenciais reais
- [ ] Assistente conectado aos dados do tenant e às permissões do usuário
- [ ] Testes automatizados executados contra banco de teste
- [ ] Deploy público e validação da URL de produção

## Regra de conclusão

O PETRA só será considerado produto de produção quando os itens acima forem executados e validados em ambiente real. O repositório agora contém a fundação operacional e as regras críticas de banco; isso não equivale, sozinho, a um deploy de produção.
