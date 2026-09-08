# PETRA — MAPA DE REPOSITÓRIOS

Este documento evita confusão entre projetos, ambientes e componentes.

## Repositórios conhecidos

### 1. `petra-1`
**Função:** repositório principal do produto PETRA.

Contém a aplicação, arquitetura e documentação mestre.

### 2. `gestaopetra`
**Função:** Motor PETRA.

Responsável pela camada central de governança, provisionamento, configuração, segurança, auditoria e comunicação com os ambientes PETRA.

É parte do PETRA, embora permaneça em repositório próprio nesta fase.

### 3. `porcelane.operacional`
**Função:** ambiente operacional paralelo da Porcelane.

Regra absoluta: não modificar o sistema antigo da Porcelane.

### 4. `https-github.com-amandaffmelo17-pixel-porcelane.operacional`
**Função:** repositório adicional identificado.

Deve permanecer preservado até que seu conteúdo seja auditado e sua finalidade confirmada.

### 5. `gestao-de-marmoraria`
**Função:** repositório legado/relacionado.

Preservar para não perder histórico ou componentes que possam ser reaproveitados.

## Regra de segurança

Nenhum repositório existente deve ser apagado, renomeado ou substituído como parte desta organização sem auditoria prévia.

## Regra de arquitetura

Mesmo com vários repositórios, existe **um único produto: PETRA**.

```text
                    PETRA
                      │
          ┌───────────┴───────────┐
          │                       │
   Aplicativo PETRA        Motor PETRA
      petra-1               gestaopetra
          │                       │
          └───────────┬───────────┘
                      │
              Pedra Assistente
                      │
               Tenants/Empresas
                      │
                  Porcelane
```

## Próxima etapa técnica

Antes de qualquer fusão física, comparar estrutura, dependências, banco, variáveis de ambiente, rotas e responsabilidades dos dois repositórios principais.

A decisão de monorepo deve ser tomada somente depois dessa auditoria.