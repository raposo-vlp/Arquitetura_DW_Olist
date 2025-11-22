-- ===============================
-- STAGING: ORDERS
-- ===============================
CREATE OR REPLACE VIEW stg_orders AS
SELECT *
FROM read_csv_auto('/kaggle/input/brazilian-ecommerce/olist_orders_dataset.csv');


-- ===============================
-- STAGING: ORDER ITEMS
-- ===============================
CREATE OR REPLACE VIEW stg_order_items AS
SELECT *
FROM read_csv_auto('/kaggle/input/brazilian-ecommerce/olist_order_items_dataset.csv');


-- ===============================
-- STAGING: ORDER PAYMENTS
-- ===============================
CREATE OR REPLACE VIEW stg_order_payments AS
SELECT *
FROM read_csv_auto('/kaggle/input/brazilian-ecommerce/olist_order_payments_dataset.csv');


-- ===============================
-- STAGING: ORDER REVIEWS
-- ===============================
CREATE OR REPLACE VIEW stg_order_reviews AS
SELECT *
FROM read_csv_auto('/kaggle/input/brazilian-ecommerce/olist_order_reviews_dataset.csv');


-- ===============================
-- STAGING: PRODUCTS
-- ===============================
CREATE OR REPLACE VIEW stg_products AS
SELECT *
FROM read_csv_auto('/kaggle/input/brazilian-ecommerce/olist_products_dataset.csv');


-- ===============================
-- STAGING: CUSTOMERS
-- ===============================
CREATE OR REPLACE VIEW stg_customers AS
SELECT *
FROM read_csv_auto('/kaggle/input/brazilian-ecommerce/olist_customers_dataset.csv');


-- ===============================
-- STAGING: SELLERS
-- ===============================
CREATE OR REPLACE VIEW stg_sellers AS
SELECT *
FROM read_csv_auto('/kaggle/input/brazilian-ecommerce/olist_sellers_dataset.csv');


-- ===============================
-- STAGING: GEOLOCATION
-- ===============================
CREATE OR REPLACE VIEW stg_geolocation AS
SELECT *
FROM read_csv_auto('/kaggle/input/brazilian-ecommerce/olist_geolocation_dataset.csv');


-- ===============================
-- STAGING: CATEGORY TRANSLATION
-- ===============================
CREATE OR REPLACE VIEW stg_category_translation AS
SELECT *
FROM read_csv_auto('/kaggle/input/brazilian-ecommerce/product_category_name_translation.csv');
