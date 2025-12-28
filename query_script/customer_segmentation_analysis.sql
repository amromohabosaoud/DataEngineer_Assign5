SET search_path TO assignment5;

-- Age range segmentation analysis
SELECT
    CASE
        WHEN c.age < 18 THEN 'Under 18'
        WHEN c.age BETWEEN 18 AND 25  THEN '18-25'
        WHEN c.age BETWEEN 26 AND 35  THEN '26-35'
        WHEN c.age BETWEEN 36 AND 45  THEN '36-45'
        WHEN c.age BETWEEN 46 AND 55  THEN '46-55'
        WHEN c.age BETWEEN 56 AND 65  THEN '56-65'
        ELSE '66 and above'
    END AS age_range,
    COUNT(DISTINCT t.customer_id) AS num_customers,
    SUM(t.price) AS total_sales,
    AVG(t.price) AS avg_sales_per_customer
FROM customers c
    JOIN transactions t ON t.customer_id = c.customer_id
GROUP BY
    age_range;

-- Location segmentation analysis
SELECT
    r.region_name,
    COUNT(DISTINCT t.customer_id) AS num_customers,
    SUM(t.price) AS total_sales,
    AVG(t.price) AS avg_sales_per_customer
FROM
    transactions t
    JOIN customer_region r ON r.customer_id = t.customer_id
WHERE
    r.region_name IS NOT NULL
GROUP BY
    r.region_name
ORDER BY total_sales DESC;

-- Combined age and location segmentation analysis
SELECT
    CASE
        WHEN c.age < 18 THEN 'Under 18'
        WHEN c.age BETWEEN 18 AND 25  THEN '18-25'
        WHEN c.age BETWEEN 26 AND 35  THEN '26-35'
        WHEN c.age BETWEEN 36 AND 45  THEN '36-45'
        WHEN c.age BETWEEN 46 AND 55  THEN '46-55'
        WHEN c.age BETWEEN 56 AND 65  THEN '56-65'
        ELSE '66 and above'
    END AS age_range,
    r.region_name,
    COUNT(DISTINCT t.customer_id) AS num_customers,
    SUM(t.price) AS total_sales,
    AVG(t.price) AS avg_sales_per_customer
FROM
    customers c
    JOIN transactions t ON t.customer_id = c.customer_id
    JOIN customer_region r ON r.customer_id = t.customer_id
WHERE
    r.region_name IS NOT NULL
GROUP BY
    age_range,
    r.region_name
ORDER BY age_range, total_sales DESC;

-- Seasonal purchasing behavior analysis
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
    COUNT(DISTINCT t.customer_id) AS num_customers,
    SUM(t.price) AS total_sales,
    AVG(t.price) AS avg_sales_per_customer
FROM transactions t
GROUP BY
    season
ORDER BY season;