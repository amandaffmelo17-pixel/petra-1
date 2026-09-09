# Publicação PETRA + Porcelane Operacional

## Arquitetura

- `porcelane.operacional`: aplicativo que será executado pelos usuários.
- `petra-1`: motor/API de gestão.
- Porcelane antigo: permanece separado e intocado.
- PostgreSQL: banco operacional do PETRA.

## Variáveis obrigatórias do PETRA

- `PETRA_ENVIRONMENT=production`
- `PETRA_VERSION`
- `PETRA_DATABASE_URL`
- `MOTOR_PETRA_URL` e `MOTOR_PETRA_SERVICE_TOKEN` quando o MOTOR PETRA estiver publicado.

## Antes de produção

1. Executar `npm install`.
2. Executar `npm run build`.
3. Executar `npm run migrate` com o PostgreSQL real.
4. Executar `npm test` com a variável `PETRA_DATABASE_URL` apontando para um banco de teste.
5. Configurar autenticação/RBAC real e remover qualquer dependência de headers de desenvolvimento.
6. Publicar o PETRA e configurar a URL no aplicativo `porcelane.operacional`.
7. Testar o fluxo completo: orçamento → pedido → medição → desenho → produção → instalação → finalização.

O repositório não declara produção concluída até que o banco real, autenticação, publicação e testes tenham sido executados.
