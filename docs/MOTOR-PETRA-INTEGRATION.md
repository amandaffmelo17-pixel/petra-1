# Integração PETRA ↔ MOTOR PETRA

O PETRA é o sistema operacional das empresas. O MOTOR PETRA é o serviço central que governa tenants, módulos, configurações, segurança e ciclo de vida.

## Contrato

A comunicação inicial usa o contrato `1.0` e a rota:

`POST /api/v1/handshake`

Toda chamada futura deve carregar:

- `contractVersion`
- `requestId`
- `correlationId`
- `source`
- `target`
- `tenantId`
- `actor`
- `payload`

## Regra de segurança

Nenhuma operação específica de empresa pode ser enviada sem `tenantId` e identidade do ator. O token de serviço deve existir somente no ambiente seguro e nunca no código-fonte.

## Estado desta etapa

O contrato e o endpoint foram criados no MOTOR PETRA. A próxima implementação no aplicativo PETRA deve consumir esse endpoint através de um adaptador interno, usando `MOTOR_PETRA_URL` e `MOTOR_PETRA_SERVICE_TOKEN` como configuração de ambiente.

Porcelane não recebe código específico nesta integração; ela será tratada como um tenant/configuração do PETRA.
