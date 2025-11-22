-- Estrutura do DW (Dimensões + Tabela Fato)
-- Apenas a estrutura — sem inserir dados ainda.
-- ===========================================================

--------------------------------------------------------------
-- Limpeza para idempotência
--------------------------------------------------------------
DROP SEQUENCE IF EXISTS seq_customer;
DROP SEQUENCE IF EXISTS seq_product;
DROP SEQUENCE IF EXISTS seq_seller;
DROP SEQUENCE IF EXISTS seq_payment_type;

DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_seller;
DROP TABLE IF EXISTS dim_payment_type;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS fact_sales;


--------------------------------------------------------------
-- Criar SEQUENCES (para chaves substitutas: surrogate keys)
--------------------------------------------------------------
CREATE SEQUENCE seq_customer;
CREATE SEQUENCE seq_product;
CREATE SEQUENCE seq_seller;
CREATE SEQUENCE seq_payment_type;


--------------------------------------------------------------
-- DIM_DATE (não tem SCD2, pois data não muda)
--------------------------------------------------------------
CREATE TABLE dim_date (
    date_key        INTEGER PRIMARY KEY,    -- YYYYMMDD
    full_date       DATE NOT NULL,
    year            INTEGER,
    quarter         INTEGER,
    month           INTEGER,
    month_name      VARCHAR,
    week            INTEGER,
    day             INTEGER,
    weekday         VARCHAR
);


--------------------------------------------------------------
-- DIM_CUSTOMER (com SCD2)
--------------------------------------------------------------
CREATE TABLE dim_customer (
    customer_key        INTEGER PRIMARY KEY DEFAULT nextval('seq_customer'),

    -- Natural Keys
    customer_id         VARCHAR,
    customer_unique_id  VARCHAR,

    -- Atributos
    customer_city       VARCHAR,
    customer_state      VARCHAR,
    zip_code_prefix     VARCHAR,

    -- SCD2
    start_date          DATE NOT NULL,
    end_date            DATE,
    is_current          BOOLEAN NOT NULL DEFAULT TRUE
);


--------------------------------------------------------------
-- DIM_PRODUCT (com SCD2)
--------------------------------------------------------------
CREATE TABLE dim_product (
    product_key                 INTEGER PRIMARY KEY DEFAULT nextval('seq_product'),

    -- Natural Key
    product_id                  VARCHAR,

    -- Atributos
    product_category_name       VARCHAR,
    product_category_english    VARCHAR,
    product_weight_g            DOUBLE,
    product_length_cm           DOUBLE,
    product_height_cm           DOUBLE,
    product_width_cm            DOUBLE,

    -- SCD2
    start_date          DATE NOT NULL,
    end_date            DATE,
    is_current          BOOLEAN NOT NULL DEFAULT TRUE
);


--------------------------------------------------------------
-- DIM_SELLER (com SCD2)
--------------------------------------------------------------
CREATE TABLE dim_seller (
    seller_key         INTEGER PRIMARY KEY DEFAULT nextval('seq_seller'),

    -- Natural Key
    seller_id          VARCHAR,

    -- Atributos
    seller_city        VARCHAR,
    seller_state       VARCHAR,
    zip_code_prefix    VARCHAR,

    -- SCD2
    start_date         DATE NOT NULL,
    end_date           DATE,
    is_current         BOOLEAN NOT NULL DEFAULT TRUE
);


--------------------------------------------------------------
-- DIM_PAYMENT_TYPE (pequena e útil)
-- Exemplo: credit_card, boleto, voucher, debit_card
--------------------------------------------------------------
CREATE TABLE dim_payment_type (
    payment_type_key   INTEGER PRIMARY KEY DEFAULT nextval('seq_payment_type'),
    payment_type       VARCHAR UNIQUE
);


--------------------------------------------------------------
-- TABELA FATO: fact_sales
-- Grain: UM item do pedido (order_id + order_item_id)
--------------------------------------------------------------
CREATE TABLE fact_sales (

    -- Surrogate Key opcional (não necessária)
    sales_key              BIGINT PRIMARY KEY,

    -- Foreign Keys
    date_key               INTEGER NOT NULL,  -- Data de compra
    customer_key           INTEGER NOT NULL,
    product_key            INTEGER NOT NULL,
    seller_key             INTEGER NOT NULL,
    payment_type_key       INTEGER,           -- Pode existir mais de 1 por pedido

    -- Medidas de negócio
    price                  DOUBLE,
    freight_value          DOUBLE,
    payment_value          DOUBLE,
    review_score           INTEGER,
    quantity               INTEGER,

    -- Fake Natural Keys (para rastrear origem)
    order_id               VARCHAR,
    order_item_id          INTEGER,

    -- Foreign Key Relations
    FOREIGN KEY (date_key)         REFERENCES dim_date(date_key),
    FOREIGN KEY (customer_key)     REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key)      REFERENCES dim_product(product_key),
    FOREIGN KEY (seller_key)       REFERENCES dim_seller(seller_key),
    FOREIGN KEY (payment_type_key) REFERENCES dim_payment_type(payment_type_key)
);
