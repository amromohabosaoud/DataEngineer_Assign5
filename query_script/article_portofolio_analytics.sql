SET search_path TO assignment5;

-- products color groups with highest sales analysis
SELECT
    a.colour_group_name,
    COUNT(DISTINCT a.article_id) AS num_articles,
    COUNT(t.article_id) AS num_sold,
    SUM(t.price) AS total_sales,
    AVG(t.price) AS avg_price
FROM transactions t
    JOIN articles a ON a.article_id = t.article_id
WHERE
    a.colour_group_name IS NOT NULL
GROUP BY
    a.colour_group_name
ORDER BY total_sales DESC;

-- products color groups with highest sales per season analysis
SELECT
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
    a.colour_group_name,
    SUM(t.price) AS total_sales
FROM transactions t
    JOIN articles a ON a.article_id = t.article_id
GROUP BY
    season,
    a.colour_group_name
ORDER BY season, total_sales DESC;

-- Departments
SELECT
    a.department_name,
    COUNT(DISTINCT a.article_id) AS num_articles,
    COUNT(t.article_id) AS num_sold,
    SUM(t.price) AS total_sales,
    AVG(t.price) AS avg_price
FROM transactions t
    JOIN articles a ON a.article_id = t.article_id
WHERE
    a.department_name IS NOT NULL
GROUP BY
    a.department_name
ORDER BY total_sales DESC;

-- Graphical appearance
SELECT
    a.graphical_appearance_name,
    COUNT(DISTINCT a.article_id) AS num_articles,
    COUNT(t.article_id) AS num_sold,
    SUM(t.price) AS total_sales,
    AVG(t.price) AS avg_price
FROM transactions t
    JOIN articles a ON a.article_id = t.article_id
WHERE
    a.graphical_appearance_name IS NOT NULL
GROUP BY
    a.graphical_appearance_name
ORDER BY total_sales DESC;