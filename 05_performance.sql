--------------------------------------------------------------------
-- ETAPA 5 — Performance e Otimização (Olist DW)
-- Gera tabela agregada, realiza consultas e produz EXPLAIN ANALYZE
--------------------------------------------------------------------

-- 1) Remover tabela agregada anterior (se existir)

DROP TABLE IF EXISTS agg_monthly_sales;

CREATE TABLE agg_monthly_sales AS
SELECT
d.year,
d.month,
SUM(f.price) AS receita,
COUNT(*) AS qtd_itens
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY 1,2
ORDER BY 1,2;

-- 3) Consultar resultados originais e otimizados (sem EXPLAIN)

-- Resultados originais
CREATE OR REPLACE TABLE results_original AS
SELECT
d.year,
d.month,
SUM(f.price) AS receita,
COUNT(*) AS qtd_itens
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY 1,2
ORDER BY 1,2;

-- Resultados otimizados usando tabela agregada
CREATE OR REPLACE TABLE results_optimized AS
SELECT *
FROM agg_monthly_sales
ORDER BY year, month;

-- 4) EXPLAIN ANALYZE para verificar performance

EXPLAIN ANALYZE
SELECT
d.year,
d.month,
SUM(f.price) AS receita,
COUNT(*) AS qtd_itens
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY 1,2
ORDER BY 1,2;

EXPLAIN ANALYZE
SELECT *
FROM agg_monthly_sales
ORDER BY year, month;

COPY agg_monthly_sales
TO 'agg_monthly_sales.parquet'
(FORMAT PARQUET);
