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
- [x] API operacional inicial para dashboard, clientes, pedidos e medições
- [x] Liberação de produção via API com validação do banco
- [x] Controle inicial de tenant e papéis em desenvolvimento
- [x] Documentação da API e contrato de publicação

## Ainda necessário antes de chamar o PETRA de produção

Estes itens dependem de infraestrutura/credenciais e execução real; não serão marcados como concluídos apenas por existir código:

- [ ] Executar migrations em PostgreSQL real
- [ ] Configurar `PETRA_DATABASE_URL` no ambiente de execução
- [ ] CRUD completo dos módulos restantes
- [ ] Autenticação real e RBAC aplicado a cada rota/consulta
- [ ] Isolamento de tenant reforçado por mecanismo de autenticação e RLS quando preparado
- [ ] Storage documental real e upload/download de anexos
- [ ] Geração real de PDFs
- [ ] Editor de desenho técnico funcional
- [ ] Integrações Trello/WhatsApp com credenciais reais
- [ ] Assistente conectado aos dados do tenant e permissões do usuário
- [ ] Testes automatizados executados contra banco de teste
- [ ] Deploy público e validação da URL de produção

## Arquitetura de execução

O aplicativo executado pelos usuários será o `porcelane.operacional`. O PETRA fornece o motor/API de gestão para esse aplicativo. O Porcelane antigo permanece separado e não deve ser alterado.

## Regra de conclusão

O PETRA só será considerado produto de produção quando infraestrutura, autenticação, publicação e testes reais forem executados e validados. O código atual já contém uma fundação operacional e as regras críticas de banco, mas ainda não é correto declarar produção concluída sem esses passos externos.
