# PETRA — Etapa 03: Empresas, módulos e permissões

## Objetivo

Estabelecer a base de identidade e autorização para múltiplas empresas sem misturar dados.

## Concluído nesta etapa

- Roles são vinculadas a uma única empresa.
- Permissões são definidas por módulo + ação.
- Usuários podem possuir múltiplas roles.
- A atribuição usuário → role é bloqueada quando as empresas são diferentes.
- Módulos ativos são configurados por empresa em `petra.company_modules`.
- A autorização em código exige que o tenant do contexto seja o mesmo tenant do usuário autorizado.
- A personalização continua sendo feita por configuração, nunca por fork de código.

## Próxima etapa

Conectar essa base a uma camada real de persistência no runtime e criar o fluxo de autenticação/sessão.

## Critério de conclusão

A etapa só será considerada operacionalmente concluída quando o banco estiver executando a migration e o fluxo de autenticação/RBAC estiver testado de ponta a ponta.
