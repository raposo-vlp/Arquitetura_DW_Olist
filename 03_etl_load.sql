-- ETL para carregar dimensões e fato no DW
-- OLTP  --->  DW (SCD2 + fato)
-- ===========================================================

--------------------------------------------------------------
-- 1. DIM_DATE (VERSÃO FINAL PARA DUCKDB — sem to_char)
--------------------------------------------------------------

DELETE FROM fact_sales;

DELETE FROM dim_customer;
DELETE FROM dim_product;
DELETE FROM dim_seller;
DELETE FROM dim_payment_type;
DELETE FROM dim_date;


--------------------------------------------------------------
-- 1. DIM_DATE  (100% compatível com DuckDB)
--------------------------------------------------------------

WITH dates AS (
    SELECT
        MIN(order_purchase_timestamp)::DATE AS start_date,
        MAX(order_purchase_timestamp)::DATE AS end_date
    FROM oltp_orders
),
expanded AS (
    SELECT
        start_date + (i * INTERVAL 1 DAY) AS full_date
    FROM dates,
    range(
        (SELECT date_diff('day', start_date, end_date) + 1 FROM dates)
    ) AS r(i)
)

INSERT INTO dim_date (
    date_key, full_date, year, quarter, month, month_name,
    week, day, weekday
)
SELECT
    CAST(strftime('%Y%m%d', full_date) AS INTEGER),
    full_date,
    EXTRACT(YEAR FROM full_date),
    EXTRACT(QUARTER FROM full_date),
    EXTRACT(MONTH FROM full_date),
    strftime('%B', full_date),
    EXTRACT(WEEK FROM full_date),
    EXTRACT(DAY FROM full_date),
    strftime('%A', full_date)
FROM expanded;


--------------------------------------------------------------
-- 2. DIM_PAYMENT_TYPE
--------------------------------------------------------------

INSERT INTO dim_payment_type (payment_type)
SELECT DISTINCT payment_type
FROM oltp_order_payments
WHERE payment_type IS NOT NULL;


--------------------------------------------------------------
-- 3. DIM_CUSTOMER — SCD2
--------------------------------------------------------------

-- Novos clientes
INSERT INTO dim_customer (
    customer_id, customer_unique_id, customer_city, customer_state,
    zip_code_prefix, start_date, end_date, is_current
)
SELECT
    c.customer_id, c.customer_unique_id, c.customer_city,
    c.customer_state, c.zip_code_prefix,
    CURRENT_DATE, NULL, TRUE
FROM oltp_customers c
LEFT JOIN dim_customer d
    ON c.customer_id = d.customer_id
   AND d.is_current = TRUE
WHERE d.customer_id IS NULL;

-- Clientes alterados
UPDATE dim_customer
SET end_date = CURRENT_DATE - INTERVAL 1 DAY,
    is_current = FALSE
WHERE customer_id IN (
    SELECT c.customer_id
    FROM oltp_customers c
    JOIN dim_customer d
        ON c.customer_id = d.customer_id
    WHERE d.is_current = TRUE
      AND (
            c.customer_city      <> d.customer_city OR
            c.customer_state     <> d.customer_state OR
            c.zip_code_prefix    <> d.zip_code_prefix
      )
);

-- Inserção das versões novas
INSERT INTO dim_customer (
    customer_id, customer_unique_id, customer_city, customer_state,
    zip_code_prefix, start_date, end_date, is_current
)
SELECT
    c.customer_id, c.customer_unique_id, c.customer_city,
    c.customer_state, c.zip_code_prefix,
    CURRENT_DATE, NULL, TRUE
FROM oltp_customers c
JOIN dim_customer d
     ON c.customer_id = d.customer_id
WHERE d.end_date = CURRENT_DATE - INTERVAL 1 DAY;



--------------------------------------------------------------
-- 4. DIM_PRODUCT — SCD2
--------------------------------------------------------------

-- Novos produtos
INSERT INTO dim_product (
    product_id, product_category_name, product_category_english,
    product_weight_g, product_length_cm, product_height_cm,
    product_width_cm, start_date, end_date, is_current
)
SELECT
    p.product_id, p.product_category_name,
    t.product_category_name_english,
    p.product_weight_g, p.product_length_cm, p.product_height_cm,
    p.product_width_cm,
    CURRENT_DATE, NULL, TRUE
FROM oltp_products p
LEFT JOIN dim_product d
       ON p.product_id = d.product_id
      AND d.is_current = TRUE
LEFT JOIN oltp_category_translation t
       ON p.product_category_name = t.product_category_name
WHERE d.product_id IS NULL;

-- Produtos alterados
UPDATE dim_product
SET end_date = CURRENT_DATE - INTERVAL 1 DAY,
    is_current = FALSE
WHERE product_id IN (
    SELECT p.product_id
    FROM oltp_products p
    JOIN dim_product d
       ON p.product_id = d.product_id
    WHERE d.is_current = TRUE
      AND (
          p.product_category_name <> d.product_category_name OR
          p.product_weight_g      <> d.product_weight_g OR
          p.product_length_cm     <> d.product_length_cm OR
          p.product_height_cm     <> d.product_height_cm OR
          p.product_width_cm      <> d.product_width_cm
      )
);

-- Inserção das versões novas
INSERT INTO dim_product (
    product_id, product_category_name, product_category_english,
    product_weight_g, product_length_cm, product_height_cm,
    product_width_cm, start_date, end_date, is_current
)
SELECT
    p.product_id, p.product_category_name,
    t.product_category_name_english,
    p.product_weight_g, p.product_length_cm, p.product_height_cm,
    p.product_width_cm,
    CURRENT_DATE, NULL, TRUE
FROM oltp_products p
JOIN dim_product d
     ON p.product_id = d.product_id
LEFT JOIN oltp_category_translation t
       ON p.product_category_name = t.product_category_name
WHERE d.end_date = CURRENT_DATE - INTERVAL 1 DAY;



--------------------------------------------------------------
-- 5. DIM_SELLER — SCD2
--------------------------------------------------------------

-- Novos
INSERT INTO dim_seller (
    seller_id, seller_city, seller_state, zip_code_prefix,
    start_date, end_date, is_current
)
SELECT
    s.seller_id, s.seller_city, s.seller_state, s.zip_code_prefix,
    CURRENT_DATE, NULL, TRUE
FROM oltp_sellers s
LEFT JOIN dim_seller d
       ON s.seller_id = d.seller_id
      AND d.is_current = TRUE
WHERE d.seller_id IS NULL;

-- Alterados
UPDATE dim_seller
SET end_date = CURRENT_DATE - INTERVAL 1 DAY,
    is_current = FALSE
WHERE seller_id IN (
    SELECT s.seller_id
    FROM oltp_sellers s
    JOIN dim_seller d
       ON s.seller_id = d.seller_id
    WHERE d.is_current = TRUE
      AND (
            s.seller_city      <> d.seller_city OR
            s.seller_state     <> d.seller_state OR
            s.zip_code_prefix  <> d.zip_code_prefix
          )
);

-- Versões novas
INSERT INTO dim_seller (
    seller_id, seller_city, seller_state, zip_code_prefix,
    start_date, end_date, is_current
)
SELECT
    s.seller_id, s.seller_city, s.seller_state, s.zip_code_prefix,
    CURRENT_DATE, NULL, TRUE
FROM oltp_sellers s
JOIN dim_seller d
     ON s.seller_id = d.seller_id
WHERE d.end_date = CURRENT_DATE - INTERVAL 1 DAY;



--------------------------------------------------------------
-- 6. FACT_SALES — VERSÃO FINAL (SEM DUPLICAÇÃO DE REVIEWS)
--------------------------------------------------------------

-- REVIEW ÚNICA POR PEDIDO
WITH latest_reviews AS (
    SELECT *
    FROM (
        SELECT
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp,
            ROW_NUMBER() OVER (
                PARTITION BY order_id
                ORDER BY review_creation_date DESC
            ) AS rn
        FROM oltp_order_reviews
    )
    WHERE rn = 1
)

INSERT INTO fact_sales (
    sales_key, date_key, customer_key, product_key, seller_key,
    payment_type_key, price, freight_value, payment_value,
    review_score, quantity, order_id, order_item_id
)
SELECT
    ROW_NUMBER() OVER () AS sales_key,

    CAST(strftime('%Y%m%d', o.order_purchase_timestamp)::INT AS INTEGER),

    dc.customer_key,
    dp.product_key,
    ds.seller_key,
    dpt.payment_type_key,

    oi.price,
    oi.freight_value,
    op.payment_value,
    rv.review_score,

    1 AS quantity,

    oi.order_id,
    oi.order_item_id

FROM oltp_order_items oi
JOIN oltp_orders o
    ON oi.order_id = o.order_id
JOIN oltp_customers c
    ON o.customer_id = c.customer_id
JOIN dim_customer dc
    ON c.customer_id = dc.customer_id AND dc.is_current = TRUE
JOIN oltp_products p
    ON oi.product_id = p.product_id
JOIN dim_product dp
    ON p.product_id = dp.product_id AND dp.is_current = TRUE
JOIN oltp_sellers s
    ON oi.seller_id = s.seller_id
JOIN dim_seller ds
    ON s.seller_id = ds.seller_id AND ds.is_current = TRUE

LEFT JOIN oltp_order_payments op
    ON oi.order_id = op.order_id
   AND op.payment_sequential = 1

LEFT JOIN dim_payment_type dpt
    ON op.payment_type = dpt.payment_type

LEFT JOIN latest_reviews rv
    ON oi.order_id = rv.order_id;
