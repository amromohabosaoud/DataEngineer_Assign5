-- create tables for the assignment (PostgreSQL)

CREATE SCHEMA IF NOT EXISTS assignment5;

SET search_path TO assignment5;

DROP VIEW IF EXISTS v_transactions_enriched;

DROP VIEW IF EXISTS v_customers_region;

DROP TABLE IF EXISTS transactions;

DROP TABLE IF EXISTS articles;

DROP TABLE IF EXISTS customers;

DROP TABLE IF EXISTS meteo;

DROP TABLE IF EXISTS customer_region;

CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    fn INTEGER,
    active INTEGER,
    club_member_status TEXT,
    fashion_news_frequency TEXT,
    age INTEGER,
    postal_code TEXT
);

CREATE TABLE articles (
    article_id TEXT PRIMARY KEY,
    product_code INTEGER,
    prod_name TEXT,
    product_type_no INTEGER,
    product_type_name TEXT,
    product_group_name TEXT,
    graphical_appearance_no INTEGER,
    graphical_appearance_name TEXT,
    colour_group_code INTEGER,
    colour_group_name TEXT,
    perceived_colour_value_id INTEGER,
    perceived_colour_value_name TEXT,
    perceived_colour_master_id INTEGER,
    perceived_colour_master_name TEXT,
    department_no INTEGER,
    department_name TEXT,
    index_code TEXT,
    index_name TEXT,
    index_group_no INTEGER,
    index_group_name TEXT,
    section_no INTEGER,
    section_name TEXT,
    garment_group_no INTEGER,
    garment_group_name TEXT,
    detail_desc TEXT
);

CREATE TABLE meteo (
    day DATE PRIMARY KEY,
    weather_code INTEGER
);

CREATE TABLE transactions (
    t_dat DATE NOT NULL,
    customer_id TEXT NOT NULL REFERENCES customers (customer_id),
    article_id TEXT NOT NULL REFERENCES articles (article_id),
    price NUMERIC,
    sales_channel_id INTEGER
);

CREATE INDEX idx_transactions_t_dat ON transactions (t_dat);

CREATE INDEX idx_transactions_customer_id ON transactions (customer_id);

CREATE INDEX idx_transactions_article_id ON transactions (article_id);

CREATE TABLE customer_region (
    customer_id TEXT PRIMARY KEY REFERENCES customers (customer_id),
    postal_code_mod10 SMALLINT,
    region_name TEXT
);

CREATE OR REPLACE VIEW v_customers_region AS
SELECT c.*, r.postal_code_mod10, r.region_name
FROM
    customers c
    LEFT JOIN customer_region r ON r.customer_id = c.customer_id;

CREATE OR REPLACE VIEW v_transactions_enriched AS
SELECT t.t_dat, t.customer_id, t.article_id, t.price, t.sales_channel_id, c.postal_code, c.postal_code_mod10, c.region_name, m.weather_code
FROM
    transactions t
    JOIN v_customers_region c ON c.customer_id = t.customer_id
    LEFT JOIN meteo m ON m.day = t.t_dat;