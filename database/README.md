# Banco de Dados PETRA

O banco oficial do PETRA é PostgreSQL padrão, independente de provedor.

- `migrations/001_initial_petra.sql`: núcleo inicial multiempresa.
- O banco é a fonte de verdade dos dados operacionais.
- OneDrive/SharePoint é armazenamento de arquivos, não banco operacional.
- A aplicação deve acessar o banco através de uma camada de dados, sem espalhar SQL pelos módulos.
- Toda entidade operacional deve carregar `company_id` para isolamento por empresa.
- Alterações em Pedido fechado são bloqueadas no banco.

## Núcleo inicial

Empresas, usuários, clientes, obras, ambientes, orçamentos, itens de orçamento, pedidos, itens de pedido, documentos, eventos e auditoria.

## Próximas migrações

1. RLS/controle de acesso conforme o mecanismo de autenticação escolhido.
2. Catálogos de materiais, acabamentos e preços.
3. Medição e conferência.
4. Desenho técnico e revisões.
5. Produção, acabamento, logística e instalação.
6. Financeiro, estoque e comissões.
7. Notificações, automações e observabilidade.
8. Dados de integração com armazenamento e sistemas externos.
