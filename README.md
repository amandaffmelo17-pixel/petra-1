# PETRA

Sistema operacional de gestão para marmorarias e negócios de acabamento.

## Arquitetura

O PETRA é o produto operacional. O MOTOR PETRA (`gestaopetra`) é o serviço central de governança, provisionamento, configuração, segurança e diagnóstico.

A Porcelane é o primeiro ambiente piloto e deve ser configurada como tenant, sem código específico de cliente.

## Fluxo oficial

Cliente → Comercial → Orçamento → Aprovação → Pedido → Medição/Conferência → Desenho Técnico → Liberação Técnica → Produção → Acabamento → Romaneio/Carregamento → Instalação → Finalizado → Pós-venda.

## Princípios

- Multi-tenant com isolamento obrigatório.
- Personalização por configuração, não por forks de código.
- Contratos oficiais entre módulos e entre PETRA/MOTOR.
- Uma fonte de verdade por domínio.
- Central de arquivos única.
- Auditoria e rastreabilidade.
- Segurança e privacidade por padrão.
- Integrações externas por adaptadores.
- IA subordinada a permissões, regras e contexto da empresa.

## Desenvolvimento

O código deve ser organizado em módulos de domínio, serviços, contratos, infraestrutura e interface. Nenhum módulo deve contornar os contratos de comunicação ou acessar dados de outro domínio sem uma interface aprovada.

Consulte `docs/PETRA-ARQUITETURA-MESTRA.md` e `docs/MOTOR-PETRA-INTEGRATION.md` antes de qualquer implementação.
