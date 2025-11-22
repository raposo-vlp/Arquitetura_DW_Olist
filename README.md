# Data Warehouse Olist com DuckDB

Projeto desenvolvido para a conclusão da disciplina de Bancos e Armazéns de Dados do curso de Ciência de Dados da Fatec Jundiaí, ministrada pelo professor Rafael Gross | [LinkedIn](https://www.linkedin.com/in/prof-rafaelgross/?originalSubdomain=br) | [Site](rafaelgross.pro.br).

Integrantes do projeto:

- Ariel Ladislau Reises | [LinkedIn](https://www.linkedin.com/in/arielreises/) | [GitHub](https://github.com/arielreises/) | [Site](https://arielreises.com.br)

- João Paulo Martins | [LinkedIn](https://www.linkedin.com/in/joão-paulo-martins-0008962b7/)

- Matheus Castro Alexandre | [LinkedIn](https://www.linkedin.com/in/matheuscastrocdd/)

- Thiago Macedo Vaz | [LinkedIn](https://www.linkedin.com/in/thiagomacedovaz/)

- Sofia Pena

## 📌 Descrição do Projeto

Este projeto constrói um Data Warehouse completo utilizando o dataset Olist (Brazilian E-commerce).
Todo o pipeline foi desenvolvido para rodar facilmente no Google Colab, utilizando:

DuckDB como banco analítico

Python + SQL para staging, dimensões e fato

KaggleHub para baixar o dataset diretamente

Matplotlib para visualização

EXPLAIN ANALYZE para otimização

## 🧠 Pipeline
O fluxo do trabalho segue uma arquitetura moderna de dados com as seguintes camadas:

Staging – Leitura direta dos arquivos brutos em views

OLTP (Modelo Operacional) – Normalização e padronização dos dados

DW (Data Warehouse)

Criação das tabelas dimensão

Construção da tabela fato

Visualizações – Análises exploratórias e métricas

Performance – Otimização via tabela agregada + comparação com EXPLAIN ANALYZE

Todo o projeto é automatizado dentro do notebook.

## 🛠️ Pré-requisitos

Como o projeto roda no Google Colab, você só precisa de:

✔️ Uma conta Google
✔️ O arquivo do notebook:

Arquitetura_DW_Olist.ipynb

✔️ As bibliotecas são instaladas automaticamente no próprio notebook, nada precisa ser instalado na máquina local.

## 📂 Estrutura do Projeto
📦 olist_dw_project/

  ├── Arquitetura_DW_Olist.ipynb        -> Notebook principal com todo o pipeline
  
  ├── olist_dw.duckdb     ->       Banco gerado após execução
  
  └── scripts/

      ├── 00_staging.sql          - Views de leitura bruta (staging)
      ├── 01_oltp.sql             - Modelo OLTP: normalização e padronização
      ├── 02_dw_model.sql         - Criação de dimensões e fato (modelo estrela)
      ├── 03_etl_load.sql         - Processo ETL de carga no DW
      ├── 04_analytics.sql        - Validação do DW
      └── 05_performance.sql      - Tabela agregada + EXPLAIN ANALYZE
