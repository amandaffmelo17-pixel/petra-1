# PETRA — Central de Registros e Acessos

## Objetivo

A Central de Registros e Acessos permite identificar, de forma auditável, quem e o que está conectado ao PETRA.

## Registra

- usuários e seus papéis;
- empresas/tenants associados;
- sessões ativas e encerradas;
- serviços internos, incluindo o MOTOR PETRA;
- agentes de IA;
- integrações externas;
- permissões relevantes;
- conexões e desconexões;
- tentativas negadas;
- alterações de permissões;
- rotação/revogação de tokens;
- data/hora e correlação da operação.

## Regras

1. Todo acesso deve possuir identidade e contexto de empresa quando aplicável.
2. Nenhum acesso é considerado autorizado apenas por estar conectado.
3. A Central de Registros é somente leitura para usuários operacionais; alterações de permissão passam pelo controle de autorização.
4. Dados sensíveis, como segredos e tokens, nunca são exibidos nem gravados em texto puro.
5. Registros devem ser vinculáveis ao audit_log e aos eventos do PETRA.
6. O MOTOR PETRA deve ter acesso mínimo necessário e identificável.
7. Integrações são registradas como integrações, não como usuários.
8. Agentes de IA são identificados separadamente de usuários humanos.

## Tela prevista

- Visão geral de conexões ativas
- Filtros por empresa, tipo, papel, origem, destino e status
- Histórico de acessos
- Permissões
- Integrações conectadas
- Serviços e agentes
- Acessos negados
- Alertas

## Fonte de verdade

O PostgreSQL mantém os registros persistentes. O PETRA apresenta a visão operacional e o MOTOR PETRA pode consultar os registros necessários para governança e diagnóstico, respeitando o Cofre de Privacidade e o princípio do menor privilégio.
