# PETRA — ARQUITETURA MESTRA E ESPECIFICAÇÃO

**Projeto:** Petra  
**Empresa piloto:** Porcelane  
**Objetivo:** sistema único de gestão e operação de marmoraria, evoluindo a base existente sem reconstrução desnecessária.

## 1. Princípio central

O Petra é o sistema central. Não devem ser criados aplicativos separados para as funções abaixo.

- Comercial
- Orçamentos
- Pedidos
- Medição/Conferência
- Desenho Técnico
- Produção
- Acabamento
- Romaneio/Logística
- Instalação
- Financeiro
- Estoque/Materiais
- Clientes
- Documentos
- Marketing/Agência
- Integrações
- Pedra Assistente
- Configurações e permissões

## 2. Fluxo oficial

**Lead/Cliente → Orçamento → Aprovação → Pedido → Medição/Conferência → Desenho Técnico → Liberação Técnica → Produção → Acabamento → Romaneio/Carregamento → Instalação → Finalizado → Pós-venda**

Deve existir uma única representação oficial do fluxo. Representações antigas ou duplicadas devem ser adaptadas, não mantidas como fluxos concorrentes.

## 3. Regra de organização documental

O Petra não deve obrigar o usuário a salvar arquivos no computador.

O armazenamento oficial poderá ser integrado ao Google Drive da Porcelane. O computador continua podendo baixar uma cópia quando desejado.

### Regra crítica

**A pasta do pedido só é criada quando o Pedido for realmente fechado/aprovado.**

Não criar pasta para todo orçamento que nunca virou pedido.

Estrutura sugerida:

```text
PORCELANE/
  PEDIDOS/
    2026/
      PEDIDO 000254 - CLIENTE/
        01 - ORÇAMENTO/
        02 - PEDIDO/
        03 - MEDIÇÃO/
        04 - DESENHO TÉCNICO/
        05 - PRODUÇÃO/
        06 - INSTALAÇÃO/
        07 - FINANCEIRO/
        08 - FOTOS E ANEXOS/
```

Todos os PDFs, desenhos, fotos, anexos e versões devem permanecer vinculados ao Pedido no Petra e, quando configurado, também na pasta correspondente do Drive.

## 4. Documentos

O Petra deve gerar documentos internamente e armazená-los online:

- Orçamento comercial
- Pedido
- Medição/Conferência
- Desenho Técnico
- Ordem de Corte
- Ordem de Acabamento
- MFC
- Romaneio
- Checklist de instalação
- Documentos de entrega/retirada/instalação
- Relatórios
- PDFs enviados ao cliente

Cada documento deve ter identificação, data, versão quando aplicável e vínculo ao registro de origem.

Revisões não devem apagar versões anteriores.

## 5. Orçamento

Regras consolidadas:

- cálculo interno por m² quando necessário;
- preço interno de m² não aparece no PDF do cliente;
- PDF pode apresentar valor individual das peças;
- subtotal por ambiente;
- materiais, insumos e serviços separados;
- frete, retirada, instalação, rodapé, desconto e condições de pagamento;
- entrada e parcelamento;
- múltiplas formas de pagamento;
- checkbox para serviços/acabamentos aplicáveis;
- perda de material de 30% quando definida para resumo de material;
- taxa de medição quando o cliente não possui medidas;
- se o pedido fechar, a taxa de medição é abatida do valor do pedido;
- duplicação e revisão de orçamento;
- pré-visualização antes da geração do PDF.

## 6. Pedido

Ao aprovar o orçamento, o Petra deve criar o Pedido preservando o vínculo e o snapshot comercial aprovado.

Depois de aprovado/fechado:

- informações comerciais aprovadas ficam protegidas;
- alterações posteriores devem ocorrer por revisão/aditivo apropriado;
- histórico de alterações deve ser preservado;
- documentos devem continuar vinculados ao Pedido;
- Pedido fechado com entrega + instalação pode gerar cartão no Trello conforme integração configurada.

## 7. Desenho Técnico

A base existente deve ser preservada e evoluída para um editor técnico especializado em marmoraria.

### Já previsto na estrutura

- ambientes;
- peças parametrizadas;
- comprimento/largura/quantidade;
- espessura;
- formatos;
- recortes;
- furos;
- acabamentos por lado;
- acessórios posicionados;
- configuração 2D/3D;
- revisões;
- liberação técnica;
- Ordem de Corte;
- Ordem de Acabamento.

### Evolução desejada

- editor visual real;
- cotas inteligentes;
- arrastar elementos;
- edição visual de recortes e furos;
- biblioteca visual de peças e acessórios;
- snap/alinhamento/distribuição;
- copiar e espelhar;
- modelos de peças comuns de marmoraria;
- numeração automática;
- A4 com escala automática;
- impressão/exportação técnica;
- integração direta com liberação técnica e produção.

### Evolução posterior

- aproveitamento de chapa;
- nesting automático;
- otimização de cortes.

## 8. Produção

Fluxo oficial por ambiente/pedido:

**Liberado → Corte → Acabamento → Romaneio/Carregamento → Instalação → Finalizado**

O sistema deve eliminar telas que apresentem fluxos incompatíveis entre si.

## 9. Medição e Conferência

A medição deve registrar medidas, conferência, pendências, responsável, evidências e liberação dos ambientes.

A taxa de medição segue a regra comercial descrita acima.

## 10. Instalação

Instalações são realizadas somente em horário comercial. Não programar instalação noturna.

O sistema deve centralizar essa regra para agenda, produção, comunicação e documentos.

## 11. Financeiro e pagamentos

O Petra deve ser preparado para integrações com:

- Pix;
- cartão/Rede ou outro gateway/adquirente configurado;
- contas a receber;
- contas a pagar;
- parcelas;
- comissões;
- conciliação e registros de pagamento.

Credenciais nunca devem ser gravadas em código, documentação pública ou mensagens comuns. Devem ser configuradas em Secrets/variáveis de ambiente ou mecanismo seguro equivalente.

## 12. Trello

Quando configurado, o Pedido aprovado/fechado pode gerar automaticamente um cartão no Trello.

Nome-base do cartão:

**PEDIDO**

O cartão pode receber links/anexos dos documentos relevantes e permanecer sincronizado conforme as regras definidas.

## 13. WhatsApp

O Petra deve estar preparado para:

- identificação do cliente por telefone;
- consulta de financeiro;
- consulta técnica;
- consulta de previsão de entrega;
- solicitação/agendamento de medição;
- envio de PDFs e links;
- recebimento de fotos/anexos quando a integração permitir;
- encaminhamento para o responsável adequado.

Arquivos recebidos devem ser vinculados ao Pedido correto antes de serem enviados ao armazenamento externo.

## 14. Google Drive

O Drive será o armazenamento documental externo preferencial se a conta da Porcelane estiver no ecossistema Google.

O Petra deve ser a fonte operacional; o Drive, a fonte documental/arquivística.

Fluxo:

**Pedido fechado → criar pasta → gerar documentos → armazenar → registrar link → enviar ao cliente quando necessário → continuar alimentando a pasta durante a execução.**

Não duplicar pastas para o mesmo Pedido.

## 15. Pedra Assistente

A Pedra Assistente permanece dentro do Petra.

Ela deve ter acesso contextual e controlado a:

- Comercial
- Orçamentos
- Pedidos
- Técnico
- Produção
- Financeiro
- Clientes
- Marketing
- Documentos

Funções futuras incluem análise de pendências, apoio ao desenho técnico, consulta de pedidos, geração assistida de documentos, apoio comercial e criação de conteúdo de marketing.

## 16. Marketing / Agência

Marketing é módulo nativo do Petra.

Deve contemplar:

- calendário editorial;
- posts;
- Stories;
- Reels;
- campanhas;
- promoções;
- catálogo;
- datas comemorativas;
- briefing;
- aprovação de arte;
- publicação;
- métricas/relatórios.

A agência deve aproveitar os dados comerciais do Petra para campanhas e ações de venda.

## 17. Usuários e permissões

O sistema não deve ser limitado a dois acessos.

Cada usuário deve possuir identidade e permissões próprias. Exemplos de áreas:

- Administração
- Financeiro
- Comercial
- Técnico
- Produção
- Instalação/Logística
- Marketing

As permissões devem controlar visualização, edição, aprovação e acesso a informações sensíveis.

## 18. Comissões

Regras já definidas:

- Amanda Ferraz: 2% até R$ 100.000; 3% acima de R$ 100.000.
- Arquitetos/parceiros: 5% conforme regra cadastrada.
- Medidor: comissão sobre o pedido, limitada aos ambientes que ele liberar.
- Comissão técnica deve permanecer separada das demais regras.

Não misturar vendedor, arquiteto/parceiro, medidor e técnico em uma única regra genérica.

## 19. Base técnica existente

A evolução deve reutilizar a estrutura existente do Petra, incluindo funções e módulos de orçamento, conversão, aprovação, bloqueio, valores do pedido, documentos técnicos, liberação técnica, checklist, Trello, comissões, recebíveis, IA, reconhecimento de peças e marketing.

Também devem ser preservadas as estruturas existentes de banco de dados, especialmente pedidos, orçamentos, clientes, medições, documentos técnicos, anexos, financeiro, usuários, permissões e integrações, salvo necessidade técnica comprovada.

## 20. Banco e segurança

O banco existente deve ser auditado antes de alterações estruturais.

Prioridades:

1. isolamento correto dos dados;
2. permissões por usuário/módulo;
3. proteção de pedidos aprovados;
4. histórico/auditoria;
5. proteção de documentos;
6. credenciais somente em secrets;
7. nenhuma senha ou chave real dentro do código-fonte.

## 21. Estratégia de implementação

Para economizar créditos e evitar retrabalho:

**Auditar → planejar → consolidar alterações → implementar em grandes blocos → testar → corrigir → acabamento visual.**

Não reconstruir módulos que já funcionam.

Não criar aplicativos paralelos.

Não criar integrações duplicadas.

Não alterar outras aplicações/projetos fora do Petra.

## 22. Regra de credenciais

Quando chegar a fase de configurar integrações, o usuário poderá fornecer/configurar as credenciais pelos mecanismos seguros da plataforma.

**Nunca colocar senhas, tokens, chaves privadas ou secrets neste arquivo Markdown, no GitHub ou no código-fonte.**

## 23. Resultado final desejado

O Petra deve funcionar como um único sistema operacional da Porcelane:

**Cliente → Comercial → Pedido → Técnico → Produção → Instalação → Financeiro → Documentos → Marketing → Pós-venda**

com integrações externas servindo ao Petra, e não substituindo o Petra.

---

**Status:** especificação mestre de arquitetura.  
**Próximo passo:** auditoria/organização do código existente e implementação consolidada, sem reconstrução desnecessária.