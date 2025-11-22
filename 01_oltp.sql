-- ===========================================================
-- Camada OLTP normalizada (a partir do STAGING)
-- ===========================================================

--------------------------------------------------------------
-- DROP TABLES (para idempotência)
--------------------------------------------------------------
DROP TABLE IF EXISTS oltp_customers;
DROP TABLE IF EXISTS oltp_sellers;
DROP TABLE IF EXISTS oltp_products;
DROP TABLE IF EXISTS oltp_orders;
DROP TABLE IF EXISTS oltp_order_items;
DROP TABLE IF EXISTS oltp_order_payments;
DROP TABLE IF EXISTS oltp_order_reviews;
DROP TABLE IF EXISTS oltp_geolocation;
DROP TABLE IF EXISTS oltp_category_translation;


--------------------------------------------------------------
-- CUSTOMERS (CORRIGIDO)
--------------------------------------------------------------
CREATE TABLE oltp_customers AS
SELECT DISTINCT
    customer_id::VARCHAR              AS customer_id,
    customer_unique_id::VARCHAR       AS customer_unique_id,
    customer_zip_code_prefix::VARCHAR AS zip_code_prefix,
    customer_city::VARCHAR            AS customer_city,
    customer_state::VARCHAR           AS customer_state
FROM stg_customers;


--------------------------------------------------------------
-- SELLERS (CORRIGIDO)
--------------------------------------------------------------
CREATE TABLE oltp_sellers AS
SELECT DISTINCT
    seller_id::VARCHAR              AS seller_id,
    seller_zip_code_prefix::VARCHAR AS zip_code_prefix,
    seller_city::VARCHAR            AS seller_city,
    seller_state::VARCHAR           AS seller_state
FROM stg_sellers;


--------------------------------------------------------------
-- PRODUCTS (CORRIGIDO)
--------------------------------------------------------------
CREATE TABLE oltp_products AS
SELECT DISTINCT
    product_id::VARCHAR                  AS product_id,
    product_category_name::VARCHAR       AS product_category_name,
    product_name_lenght::INTEGER         AS product_name_lenght,
    product_description_lenght::INTEGER  AS product_description_lenght,
    product_photos_qty::INTEGER          AS product_photos_qty,
    product_weight_g::DOUBLE             AS product_weight_g,
    product_length_cm::DOUBLE            AS product_length_cm,
    product_height_cm::DOUBLE            AS product_height_cm,
    product_width_cm::DOUBLE             AS product_width_cm
FROM stg_products;


--------------------------------------------------------------
-- ORDERS (CORRIGIDO)
--------------------------------------------------------------
CREATE TABLE oltp_orders AS
SELECT DISTINCT
    order_id::VARCHAR    AS order_id,
    customer_id::VARCHAR AS customer_id,
    order_status::VARCHAR AS order_status,

    CAST(order_purchase_timestamp      AS TIMESTAMP) AS order_purchase_timestamp,
    CAST(order_approved_at             AS TIMESTAMP) AS order_approved_at,
    CAST(order_delivered_carrier_date  AS TIMESTAMP) AS order_delivered_carrier_date,
    CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date

FROM stg_orders;


--------------------------------------------------------------
-- ORDER ITEMS (CORRIGIDO)
--------------------------------------------------------------
CREATE TABLE oltp_order_items AS
SELECT DISTINCT
    order_id::VARCHAR    AS order_id,
    order_item_id::INTEGER AS order_item_id,
    product_id::VARCHAR  AS product_id,
    seller_id::VARCHAR   AS seller_id,
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
    price::DOUBLE        AS price,
    freight_value::DOUBLE AS freight_value
FROM stg_order_items;


--------------------------------------------------------------
-- ORDER PAYMENTS (CORRIGIDO)
--------------------------------------------------------------
CREATE TABLE oltp_order_payments AS
SELECT DISTINCT
    order_id::VARCHAR              AS order_id,
    payment_sequential::INTEGER    AS payment_sequential,
    payment_type::VARCHAR          AS payment_type,
    payment_installments::INTEGER  AS payment_installments,
    payment_value::DOUBLE          AS payment_value
FROM stg_order_payments;


--------------------------------------------------------------
-- ORDER REVIEWS (CORRIGIDO)
--------------------------------------------------------------
CREATE TABLE oltp_order_reviews AS
SELECT DISTINCT
    review_id::VARCHAR       AS review_id,
    order_id::VARCHAR        AS order_id,
    review_score::INTEGER    AS review_score,
    review_comment_title::VARCHAR      AS review_comment_title,
    review_comment_message::VARCHAR    AS review_comment_message,
    CAST(review_creation_date     AS TIMESTAMP) AS review_creation_date,
    CAST(review_answer_timestamp  AS TIMESTAMP) AS review_answer_timestamp
FROM stg_order_reviews;


--------------------------------------------------------------
-- GEOLOCATION (CORRIGIDO)
--------------------------------------------------------------
CREATE TABLE oltp_geolocation AS
SELECT DISTINCT
    geolocation_zip_code_prefix::VARCHAR AS zip_code_prefix,
    geolocation_lat::DOUBLE              AS geolocation_lat,
    geolocation_lng::DOUBLE              AS geolocation_lng,
    geolocation_city::VARCHAR            AS geolocation_city,
    geolocation_state::VARCHAR           AS geolocation_state
FROM stg_geolocation;


--------------------------------------------------------------
-- CATEGORY TRANSLATION (CORRIGIDO)
--------------------------------------------------------------
CREATE TABLE oltp_category_translation AS
SELECT DISTINCT
    product_category_name::VARCHAR         AS product_category_name,
    product_category_name_english::VARCHAR AS product_category_name_english
FROM stg_category_translation;
