# PETRA — Base de Implementação

Esta pasta marca o início do aplicativo executável sem apagar ou reconstruir estruturas futuras desnecessariamente.

## Camadas obrigatórias

```text
src/
├── core/           # contexto, contratos e regras transversais
├── contracts/      # contratos externos e internos versionados
├── integrations/   # adaptadores externos
├── modules/        # domínios do PETRA
├── infrastructure/ # banco, armazenamento, filas e serviços
└── interface/      # web/mobile/API quando a camada visual for adicionada
```

## Domínios

Cada domínio deve ser dono de seus dados e regras. A comunicação entre domínios ocorre por serviços/contratos/eventos oficiais.

### Ordem de construção

1. Identidade e tenant
2. Empresas/configuração
3. Clientes
4. Comercial
5. Orçamentos
6. Pedidos
7. Medição/Conferência
8. Desenho Técnico
9. Produção
10. Acabamento
11. Logística/Instalação
12. Financeiro
13. Estoque
14. Documentos/Central de Arquivos
15. Relatórios
16. Automações
17. Marketing
18. Pedra Assistente

## Critério de pronto

Um módulo só é considerado pronto quando tiver regra, persistência, permissões, tenant isolation, auditoria, documentos/eventos necessários, testes e integração com o fluxo oficial.

## Regra de custo/retrabalho

Não criar módulos paralelos nem reescrever uma funcionalidade existente sem auditoria prévia. Consolidar alterações em blocos, testar e só depois fazer acabamento visual.
