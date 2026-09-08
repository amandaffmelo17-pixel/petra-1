# PETRA — ORGANIZAÇÃO OFICIAL DO PRODUTO

## 1. Definição oficial

**PETRA é um único produto.**

Os nomes Gestão PETRA, Motor PETRA, Aplicativo PETRA e Pedra Assistente representam componentes do mesmo sistema, e não produtos independentes.

### Estrutura oficial

```text
PETRA
├── Aplicativo PETRA
│   ├── Comercial
│   ├── Orçamentos
│   ├── Pedidos
│   ├── Medição/Conferência
│   ├── Desenho Técnico
│   ├── Produção
│   ├── Acabamento
│   ├── Romaneio/Carregamento
│   ├── Instalação
│   ├── Financeiro
│   ├── Estoque
│   ├── Clientes
│   ├── Documentos
│   ├── Marketing/Agência
│   └── Pós-venda
│
├── Motor PETRA (Gestão PETRA)
│   ├── Empresas/Tenants
│   ├── Configurações
│   ├── Módulos e permissões
│   ├── Segurança
│   ├── Auditoria
│   ├── Provisionamento
│   └── Diagnóstico
│
└── Pedra Assistente
    └── IA integrada ao PETRA
```

## 2. Repositório canônico

O repositório canônico do produto, nesta fase, é:

`amandaffmelo17-pixel/petra-1`

Ele deve ser tratado como a referência principal do PETRA.

O repositório `gestaopetra` continua preservado porque contém o Motor PETRA e seu histórico. Não deve ser apagado nem alterado destrutivamente durante a organização.

## 3. Relação entre os repositórios

| Repositório | Papel | Situação |
|---|---|---|
| `petra-1` | Aplicativo/produto PETRA e documentação principal | Canônico |
| `gestaopetra` | Motor PETRA / governança central | Preservado e integrado por arquitetura |
| `porcelane.operacional` | Ambiente operacional paralelo da Porcelane | Separado; não altera o sistema antigo |
| `https-github.com-amandaffmelo17-pixel-porcelane.operacional` | Repositório adicional | Manter separado até auditoria |
| `gestao-de-marmoraria` | Legado/relacionado | Preservar para histórico |

## 4. Regra de não duplicação

Não criar um segundo produto chamado Gestão PETRA.

Não criar outro aplicativo para o Motor PETRA.

Não criar uma segunda versão do fluxo oficial dentro do PETRA.

Novas funções devem entrar no PETRA como módulos, serviços ou componentes da arquitetura existente.

## 5. Estratégia técnica

Nesta etapa, **não fazer uma fusão física dos dois repositórios sem auditoria do código**.

A organização inicial é lógica e documental:

1. `petra-1` = referência principal do produto.
2. `gestaopetra` = componente Motor PETRA preservado.
3. Contratos entre Aplicativo e Motor ficam documentados.
4. Código existente não é reconstruído sem necessidade.
5. Só depois da auditoria será decidida eventual migração para monorepo.

## 6. Empresa piloto

A Porcelane é o primeiro ambiente/tenant do PETRA.

A configuração da Porcelane deve ser feita por dados/configuração, e não por código específico de cliente.

O sistema antigo da Porcelane não deve ser alterado durante o desenvolvimento do ambiente paralelo.

## 7. Regra operacional crítica

**Nenhuma Ordem de Corte pode ser liberada ou enviada para produção sem que exista uma data de medição registrada no sistema.**

Essa regra deve ser validada tanto na interface quanto na camada de negócio/backend.

## 8. Fluxo oficial

`Cliente → Comercial → Orçamento → Aprovação → Pedido → Medição/Conferência → Desenho Técnico → Liberação Técnica → Produção → Acabamento → Romaneio/Carregamento → Instalação → Finalizado → Pós-venda`

## 9. Ordem de trabalho para evolução

**Auditar → organizar → consolidar contratos → implementar → testar → validar regras → acabamento visual.**

Nenhuma alteração destrutiva deve ser feita apenas para reorganizar nomes ou pastas.

---

**Documento:** Organização Oficial do PETRA  
**Status:** ativo  
**Repositório de referência:** `petra-1`