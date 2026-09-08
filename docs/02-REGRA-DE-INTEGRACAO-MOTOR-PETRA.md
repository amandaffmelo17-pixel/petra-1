# PETRA — INTEGRAÇÃO DO MOTOR PETRA

## Objetivo

Definir claramente como o aplicativo PETRA e o Motor PETRA fazem parte do mesmo produto sem misturar responsabilidades.

## Aplicativo PETRA

Responsável pela operação diária das empresas:

- telas;
- fluxos operacionais;
- orçamentos;
- pedidos;
- medição/conferência;
- desenho técnico;
- produção;
- instalação;
- financeiro;
- documentos;
- marketing;
- pós-venda;
- Assistente contextual.

## Motor PETRA

Responsável pelas funções centrais de governança:

- cadastro de empresas/tenants;
- provisionamento de ambientes;
- ativação de módulos;
- configurações globais;
- segurança;
- auditoria;
- diagnóstico;
- comunicação segura entre componentes.

## Regra de comunicação

O aplicativo não deve acessar diretamente responsabilidades internas do Motor de forma improvisada.

A comunicação deve ocorrer por contratos/interfaces definidos e auditáveis.

## Multiempresa

Uma instalação do PETRA pode atender várias empresas.

Cada empresa deve possuir isolamento de dados e configuração própria.

A Porcelane é apenas o primeiro tenant/piloto e não deve gerar forks específicos do PETRA.

## Fusão futura

Uma eventual fusão física dos repositórios deve ser feita somente depois de:

1. inventário dos arquivos;
2. identificação de dependências;
3. comparação de banco e migrações;
4. comparação de variáveis de ambiente/secrets;
5. identificação de módulos duplicados;
6. definição da estrutura final;
7. criação de branch de segurança;
8. testes;
9. validação do ambiente PETRA;
10. somente então consolidação.

Até lá, dois repositórios podem existir tecnicamente sem representar dois produtos.

## Regra principal

**PETRA = Aplicativo + Motor + Assistente + ambientes/tenants.**

Não tratar Gestão PETRA e PETRA como produtos separados.