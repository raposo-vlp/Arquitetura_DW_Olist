-- ANALYTICS.SQL — Validação do Data Warehouse Olist
-- Todas as validações retornam um número:
--   0  = PASS
--  >0  = FAIL
------------------------------------------------------------


------------------------------------------------------------
-- 1) CONTAGENS
------------------------------------------------------------

-- Quantidade de pedidos na bronze (OLTP)
SELECT COUNT(*) AS oltp_orders FROM oltp_orders;

-- Quantidade de itens de pedido
SELECT COUNT(*) AS oltp_order_items FROM oltp_order_items;

-- Quantidade de linhas na fato
SELECT COUNT(*) AS dw_fact_sales FROM fact_sales;

-- FAIL se o número da fato exceder o número de order_items
SELECT
    CASE WHEN
        (SELECT COUNT(*) FROM fact_sales)
        <=
        (SELECT COUNT(*) FROM oltp_order_items)
    THEN 0 ELSE 1 END AS fail_fact_exceeds_items;


------------------------------------------------------------
-- 2) FKs NULAS (exceto payment_type_key)
------------------------------------------------------------

-- Customer
SELECT COUNT(*) AS fk_customer_null
FROM fact_sales
WHERE customer_key IS NULL;

-- Product
SELECT COUNT(*) AS fk_product_null
FROM fact_sales
WHERE product_key IS NULL;

-- Seller
SELECT COUNT(*) AS fk_seller_null
FROM fact_sales
WHERE seller_key IS NULL;

-- Date
SELECT COUNT(*) AS fk_date_null
FROM fact_sales
WHERE date_key IS NULL;

-- Payment pode ser NULL, apenas informativo
SELECT COUNT(*) AS fk_payment_null
FROM fact_sales
WHERE payment_type_key IS NULL;


------------------------------------------------------------
-- 3) INTEGRIDADE DIMENSIONAL (tabelas de dimensão completas)
------------------------------------------------------------

-- Clientes faltando
SELECT COUNT(*) AS missing_customers
FROM fact_sales fs
LEFT JOIN dim_customer dc USING (customer_key)
WHERE dc.customer_key IS NULL;

-- Produtos faltando
SELECT COUNT(*) AS missing_products
FROM fact_sales fs
LEFT JOIN dim_product dp USING (product_key)
WHERE dp.product_key IS NULL;

-- Sellers faltando
SELECT COUNT(*) AS missing_sellers
FROM fact_sales fs
LEFT JOIN dim_seller ds USING (seller_key)
WHERE ds.seller_key IS NULL;


------------------------------------------------------------
-- 4) RANGE DE DATAS (dim_date cobre o período)
------------------------------------------------------------

-- Datas na dimensão
SELECT
    MIN(full_date) AS dw_min_date,
    MAX(full_date) AS dw_max_date
FROM dim_date;

-- Datas reais nos pedidos
SELECT
    MIN(order_purchase_timestamp)::DATE AS raw_min_date,
    MAX(order_purchase_timestamp)::DATE AS raw_max_date
FROM oltp_orders;

-- FAIL se ranges forem diferentes
SELECT
    CASE WHEN
        (SELECT MIN(full_date) FROM dim_date) =
        (SELECT MIN(order_purchase_timestamp)::DATE FROM oltp_orders)
    AND
        (SELECT MAX(full_date) FROM dim_date) =
        (SELECT MAX(order_purchase_timestamp)::DATE FROM oltp_orders)
    THEN 0 ELSE 1 END AS fail_date_range;


------------------------------------------------------------
-- 5) SCD2 (somente um is_current por ID)
------------------------------------------------------------

-- Customer
SELECT COUNT(*) AS scd_customer_fail
FROM (
    SELECT customer_id, SUM(is_current::INT) AS curr
    FROM dim_customer
    GROUP BY customer_id
    HAVING curr > 1
);

-- Product
SELECT COUNT(*) AS scd_product_fail
FROM (
    SELECT product_id, SUM(is_current::INT) AS curr
    FROM dim_product
    GROUP BY product_id
    HAVING curr > 1
);

-- Seller
SELECT COUNT(*) AS scd_seller_fail
FROM (
    SELECT seller_id, SUM(is_current::INT) AS curr
    FROM dim_seller
    GROUP BY seller_id
    HAVING curr > 1
);
