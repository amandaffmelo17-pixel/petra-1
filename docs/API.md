# API do PETRA

A API do PETRA é consumida pelo aplicativo operacional da Porcelane. O PETRA permanece como motor de gestão; o Porcelane Operacional é a aplicação que será executada pelos usuários.

## Contexto de empresa

Durante desenvolvimento, as rotas `api/v1` aceitam `x-petra-company-id` e `x-petra-role`. Esse mecanismo é **somente de desenvolvimento**. Em produção, o contexto deverá vir do provedor real de autenticação/RBAC; o header de desenvolvimento é rejeitado.

## Rotas disponíveis

- `GET /api/v1/dashboard` — indicadores da empresa.
- `GET /api/v1/clients` — lista clientes.
- `POST /api/v1/clients` — cria cliente (`admin`, `commercial`).
- `GET /api/v1/orders` — lista pedidos.
- `POST /api/v1/orders` — cria pedido (`admin`, `commercial`).
- `GET /api/v1/orders/:id` — pedido com medições e liberação de produção.
- `POST /api/v1/orders/:id/measurements` — registra medição (`admin`, `technical`).
- `POST /api/v1/orders/:id/production-release` — libera produção (`admin`, `technical`, `production`).
- `PATCH /api/v1/orders/:id/status` — altera etapa do pedido conforme as regras do banco.

## Regra crítica

A aplicação não deve contornar a liberação de produção. O banco PETRA valida que uma liberação só existe quando há uma medição da mesma empresa e do mesmo pedido, com data e status `approved`. Também bloqueia a entrada do pedido nas etapas de produção ou posteriores quando não existe liberação válida.

## Próxima integração

O `porcelane.operacional` deve consumir estas rotas. O app antigo da Porcelane não faz parte desta integração e não deve ser alterado.
