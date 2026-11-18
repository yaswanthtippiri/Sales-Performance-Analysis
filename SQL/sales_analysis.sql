SHOW DATABASES;
CREATE DATABASE sales_analysis;
USE sales_analysis;
SELECT* FROM sales_data;
SELECT COUNT(*) FROM sales_data;
SELECT COUNT(*) AS Total_Records
FROM sales_data;
SELECT SUM(CAST(amount AS DECIMAL(15,2))) AS total_sales FROM sales_data;
SELECT SUM(units) AS total_units_sold FROM sales_data;
SELECT ROUND(AVG(CAST(amount AS DECIMAL(15,2))),2) FROM sales_data;
SELECT COUNT(DISTINCT products) AS total_products FROM sales_data;
SELECT COUNT(DISTINCT 'sales persons') AS total_salespeople FROM sales_data;
SELECT products,
SUM(CAST(amount AS DECIMAL(15,2))) AS total_sales FROM sales_data
GROUP BY products
ORDER BY total_sales  DESC;
SELECT 'sales persons',
SUM(CAST(amount AS DECIMAL(15,2))) AS total_sales FROM sales_data
GROUP BY 'sales persons'
ORDER BY total_sales  DESC;
SELECT `ï»¿Date`
FROM sales_data
LIMIT 10;
show columns from sales_data;
ALTER TABLE sales_data
RENAME COLUMN `ï»¿Date` TO Order_Date;
describe sales_data;
select order_date from sales_data limit 10;
select 
order_date as original_date,
str_to_date(order_date, '%d-%m-%y') as converted_date
from sales_data limit 10;
describe sales_data;
SHOW INDEX FROM sales_data;
SET SQL_SAFE_UPDATES = 0;
UPDATE sales_data
SET Order_Date = DATE_FORMAT(
    STR_TO_DATE(Order_Date, '%d-%m-%Y'),
    '%Y-%m-%d'
);
SELECT Order_Date
FROM sales_data
LIMIT 10;
ALTER TABLE sales_data
MODIFY COLUMN Order_Date DATE;
DESCRIBE sales_data;
SELECT
    YEAR(Order_Date) AS sales_year,
    MONTH(Order_Date) AS sales_month,
    SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales
FROM sales_data
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    sales_year,
    sales_month;
SELECT
    DATE_FORMAT(Order_Date, '%Y-%m') AS sales_month,
    SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales
FROM sales_data
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY sales_month;
SELECT
    DATE_FORMAT(Order_Date, '%Y-%m') AS sales_month,
    SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales
FROM sales_data
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY total_sales DESC
LIMIT 1;
SELECT
    YEAR(Order_Date) AS sales_year,
    SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales
FROM sales_data
GROUP BY YEAR(Order_Date)
ORDER BY total_sales DESC;
WITH yearly_sales AS (
    SELECT
        YEAR(Order_Date) AS sales_year,
        SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales
    FROM sales_data
    GROUP BY YEAR(Order_Date)
)
SELECT
    sales_year,
    total_sales,
    LAG(total_sales) OVER (
        ORDER BY sales_year
    ) AS previous_year_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (
            ORDER BY sales_year
        )) * 100.0 /
        NULLIF(LAG(total_sales) OVER (
            ORDER BY sales_year
        ), 0),
        2
    ) AS growth_percentage
FROM yearly_sales
ORDER BY sales_year;
SELECT
    Products,
    SUM(Units) AS total_units_sold
FROM sales_data
GROUP BY Products
ORDER BY total_units_sold DESC;
SELECT
    `Sales Persons`,
    SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales,
    SUM(Units) AS total_units_sold
FROM sales_data
GROUP BY `Sales Persons`
ORDER BY total_sales DESC;
SELECT COUNT(DISTINCT `Sales Persons`) AS total_salespeople
FROM sales_data;
SELECT
    `Sales Persons`,
    SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales,
    SUM(Units) AS total_units_sold
FROM sales_data
GROUP BY `Sales Persons`
ORDER BY total_sales DESC;
SELECT
    Place,
    SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales,
    SUM(Units) AS total_units_sold
FROM sales_data
GROUP BY Place
ORDER BY total_sales DESC;
WITH product_location_sales AS (
    SELECT
        Place,
        Products,
        SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales
    FROM sales_data
    GROUP BY Place, Products
),
ranked_products AS (
    SELECT
        Place,
        Products,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY Place
            ORDER BY total_sales DESC
        ) AS product_rank
    FROM product_location_sales
)
SELECT
    Place,
    Products,
    total_sales
FROM ranked_products
WHERE product_rank = 1
ORDER BY Place;
SELECT
    Products,
    SUM(CAST(Amount AS DECIMAL(15,2))) AS total_sales,
    SUM(Units) AS total_units_sold,
    ROUND(
        SUM(CAST(Amount AS DECIMAL(15,2)))
        / NULLIF(SUM(Units), 0),
        2
    ) AS average_revenue_per_unit
FROM sales_data
GROUP BY Products
ORDER BY average_revenue_per_unit DESC;
SELECT
    COUNT(*) AS total_records,
    SUM(
        CASE
            WHEN CAST(Amount AS DECIMAL(15,2))
                 <> Price * Units
            THEN 1
            ELSE 0
        END
    ) AS mismatched_records
FROM sales_data;
SELECT
    Order_Date,
    Products,
    Price,
    Units,
    Amount,
    Price * Units AS calculated_amount
FROM sales_data
WHERE CAST(Amount AS DECIMAL(15,2)) <> Price * Units
LIMIT 15;
describe sales_data;
SELECT
    Order_Date,
    Products,
    Price,
    Units,
    Amount,
    Price * Units AS calculated_amount
FROM sales_data
WHERE CAST(Amount AS DECIMAL(15,2)) <> Price * Units
LIMIT 15;
SELECT DISTINCT Amount
FROM sales_data
LIMIT 20;
SELECT
    Price,
    Units,
    Amount AS original_amount,
    CAST(
        REPLACE(Amount, ',', '')
        AS DECIMAL(15,2)
    ) AS cleaned_amount,
    Price * Units AS calculated_amount
FROM sales_data
LIMIT 15;
SELECT
    COUNT(*) AS total_records,
    SUM(
        CASE
            WHEN CAST(
                REPLACE(Amount, ',', '')
                AS DECIMAL(15,2)
            ) <> Price * Units
            THEN 1
            ELSE 0
        END
    ) AS mismatched_records
FROM sales_data;
SELECT
    SUM(
        CAST(REPLACE(Amount, ',', '') AS DECIMAL(15,2))
    ) AS total_sales,
    SUM(Units) AS total_units_sold,
    COUNT(*) AS total_records
FROM sales_data;
SELECT
    SUM(CAST(REPLACE(Amount, ',', '') AS DECIMAL(15,2)))
        AS total_sales,
    SUM(Units) AS total_units_sold,
    ROUND(
        AVG(CAST(REPLACE(Amount, ',', '') AS DECIMAL(15,2))),
        2
    ) AS average_transaction_amount,
    COUNT(DISTINCT Products) AS total_products,
    COUNT(DISTINCT `Sales Persons`) AS total_salespeople,
    COUNT(*) AS total_records
FROM sales_data;

