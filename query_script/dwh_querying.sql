SET search_path TO assignment5;

-- A) How many customers did at least one purchase.
SELECT COUNT(DISTINCT t.customer_id) AS num_customers_with_purchase
FROM transactions t;

-- B) How many articles have been sold in 2019.
SELECT COUNT(DISTINCT t.article_id) AS num_articles_sold_2019
FROM transactions t
WHERE
    t.t_dat BETWEEN '2019-01-01' AND '2019-12-31';

-- C) Aggregate sales by graphical appearance name.
SELECT a.graphical_appearance_name, SUM(t.price) AS total_sales
FROM transactions t
    JOIN articles a ON a.article_id = t.article_id
GROUP BY
    a.graphical_appearance_name
ORDER BY total_sales DESC;

-- D) Aggregate sales for each Swedish region by product type and season.
SELECT
    r.region_name,
    a.product_type_name,
    CASE
        WHEN EXTRACT(
            MONTH
            FROM t.t_dat
        ) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(
            MONTH
            FROM t.t_dat
        ) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(
            MONTH
            FROM t.t_dat
        ) IN (6, 7, 8) THEN 'Summer'
        WHEN EXTRACT(
            MONTH
            FROM t.t_dat
        ) IN (9, 10, 11) THEN 'Autumn'
    END AS season,
    SUM(t.price) AS total_sales
FROM
    transactions t
    JOIN articles a ON a.article_id = t.article_id
    JOIN customer_region r ON r.customer_id = t.customer_id
GROUP BY
    r.region_name,
    a.product_type_name,
    season
ORDER BY r.region_name, a.product_type_name, season;

-- E) Aggregate sales for the region Stockholm by product category and month.
SELECT date_trunc ('month', t.t_dat) AS month, a.product_group_name, SUM(t.price) AS total_sales
FROM
    transactions t
    JOIN articles a ON a.article_id = t.article_id
    JOIN customer_region r ON r.customer_id = t.customer_id
WHERE
    r.region_name = 'Stockholm'
GROUP BY
    month,
    a.product_group_name
ORDER BY month, total_sales DESC;

-- F) Color groups that led to highest aggregate sales per season.
WITH
    tx AS (
        SELECT
            t.*,
            CASE
                WHEN EXTRACT(
                    MONTH
                    FROM t.t_dat
                ) IN (12, 1, 2) THEN 'Winter'
                WHEN EXTRACT(
                    MONTH
                    FROM t.t_dat
                ) IN (3, 4, 5) THEN 'Spring'
                WHEN EXTRACT(
                    MONTH
                    FROM t.t_dat
                ) IN (6, 7, 8) THEN 'Summer'
                WHEN EXTRACT(
                    MONTH
                    FROM t.t_dat
                ) IN (9, 10, 11) THEN 'Autumn'
            END AS season
        FROM transactions t
    ),
    season_color AS (
        SELECT tx.season, a.colour_group_name, SUM(tx.price) AS total_sales
        FROM tx
            JOIN articles a ON a.article_id = tx.article_id
        GROUP BY
            tx.season,
            a.colour_group_name
    ),
    ranked_colors AS (
        SELECT
            season,
            colour_group_name,
            total_sales,
            ROW_NUMBER() OVER (
                PARTITION BY
                    season
                ORDER BY total_sales DESC
            ) AS sales_rank
        FROM season_color
    )
SELECT
    season,
    colour_group_name,
    total_sales
FROM ranked_colors
WHERE
    sales_rank = 1
ORDER BY season;