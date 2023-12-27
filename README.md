# Relatório ABAP HCM - Informações do Gerente do Funcionário

## Descrição
Programa ABAP (`Z_ALGJ_42`) que implementa um relatório no SAP HCM (Gestão de Capital Humano). O relatório recebe o número pessoal do funcionário como entrada e recupera informações sobre a posição, unidade organizacional e gerente desse funcionário.

## Conteúdo
1. [**Pré-requisitos**](#pré-requisitos)
2. [**Instruções de Uso**](#instruções-de-uso)
3. [**Detalhes Técnicos**](#detalhes-técnicos)
4. [**Autor**](#autor)

## Pré-requisitos
- Sistema SAP com suporte a ABAP.
- Acesso às transações de desenvolvimento no SAP.

## Instruções de Uso
1. Faça o download do código-fonte (`Z_ALGJ_42.abap`).
2. Importe o código-fonte para o sistema SAP utilizando a transação `SE80` ou `SE38`.
3. Execute o relatório utilizando a transação `SE38` ou `SA38`.
4. Insira o número pessoal do funcionário na tela de seleção.

## Detalhes Técnicos
O código está estruturado para recuperar informações sobre a posição, unidade organizacional e gerente do funcionário no SAP HCM. Utiliza módulos de função padrão e infotipos para obter dados relevantes.

## Autor
Este projeto foi desenvolvido primariamente por André Luiz G.J.