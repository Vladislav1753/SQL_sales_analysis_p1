# SQL_sales_analysis_p1

# Retail Sales Analysis SQL Project

## Overview

Welcome!

This is as small project of mine that involves analyzing a retail sales dataset using SQL. The goal is to gain insights into customer behavior, sales patterns, and performance across various product categories and time periods. The dataset includes information such as transaction ID, customer demographics, sale date/time, product category, pricing, and sales values. 

The analysis answers ten business questions using SQL queries and includes data cleaning, aggregation, filtering, and ranking techniques. All queries are designed to work with PostgreSQL.

---

## Setup and Data Preparation

```sql
-- Drop and recreate table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
    transaction_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

-- Preview data
SELECT * FROM retail_sales LIMIT 10;

-- Remove rows with NULL values
DELETE FROM retail_sales
WHERE
    transaction_id IS NULL OR
    sale_date IS NULL OR
    sale_time IS NULL OR
    gender IS NULL OR
    category IS NULL OR
    quantity IS NULL OR
    cogs IS NULL OR
    total_sale IS NULL;

-- Basic exploratory queries
SELECT COUNT(*) AS total_sales FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;
```

---

## Business Questions and SQL Queries

### Q1. Retrieve transactions in April 2023 where total\_sale is above the average for that month.

```sql
SELECT *
FROM retail_sales
WHERE total_sale > (
    SELECT AVG(total_sale)
    FROM retail_sales
    WHERE TO_CHAR(sale_date, 'YYYY-MM') = '2023-04'
)
AND TO_CHAR(sale_date, 'YYYY-MM') = '2023-04';
```

### Q2. Transactions in 'Electronics' category with quantity > 3 in August 2022.

```sql
SELECT *
FROM retail_sales
WHERE
    category = 'Electronics' AND
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-08' AND
    quantity >= 3;
```

### Q3. Total and count of sales per category.

```sql
SELECT category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```

### Q4. Average age of customers who purchased 'Electronics'.

```sql
SELECT ROUND(AVG(age), 1) AS avg_age
FROM retail_sales
WHERE category = 'Electronics';
```

### Q5. Transactions with total\_sale > 1000 and price\_per\_unit above category average.

```sql
SELECT *
FROM retail_sales r
WHERE total_sale > 1000
  AND price_per_unit > (
    SELECT AVG(price_per_unit)
    FROM retail_sales
    WHERE category = r.category
);
```

### Q6. Count transactions by gender and category.

```sql
SELECT category, gender, COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

### Q7. Best selling month per year based on average total\_sale.

```sql
SELECT sales_year, sales_month, average_monthly_sale
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS sales_year,
        EXTRACT(MONTH FROM sale_date) AS sales_month,
        ROUND(AVG(total_sale)::numeric, 1) AS average_monthly_sale,
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS monthly_rank
    FROM retail_sales
    GROUP BY sales_year, sales_month
) AS ranked_months
WHERE monthly_rank = 1;
```

### Q8. Top 5 customers based on total sales.

```sql
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

### Q9. Unique customers per category with more than 2 purchases.

```sql
SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM (
    SELECT category, customer_id, COUNT(*) AS num_purchases
    FROM retail_sales
    GROUP BY category, customer_id
    HAVING COUNT(*) > 2
) AS sub
GROUP BY category;
```

### Q10. Order count by shift (Morning, Afternoon, Evening).

```sql
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;
```

---

## Summary

This project demonstrates the ability to analyze sales data using SQL. We use aggregation, filtering, grouping, subqueries, and window functions to answer practical business questions. These insights could help improve product strategy, customer segmentation, and operational efficiency.

Feel free to fork or clone the project for your own experimentation and portfolio!
