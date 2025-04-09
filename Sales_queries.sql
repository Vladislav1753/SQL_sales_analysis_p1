-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );
			
-- Having a look at our data			
SELECT * FROM retail_sales
LIMIT 10;

-- Deleting all incomplete data (with at least one null value)
DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

-- How many sales we have?
SELECT COUNT(*) as total_sale FROM retail_sales

-- How many uniuque customers do we have?
SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales

-- How many categories do we have?
SELECT DISTINCT category FROM retail_sales


-- Data Analysis & Business Key Problems & Answers

-- Q.1 Retrieve all transactions in April 2023 where the total_sale is above the average total_sale for that month.
-- Q.2 Retrieve all transactions where the category is 'Electronics' and the quantity sold is more than 3 in the August 2022
-- Q.3 Calculate the total sales (total_sale) for each category.
-- Q.4 Find the average age of customers who purchased items from the 'Electronics' category.
-- Q.5 Find all transactions where the total_sale is greater than 1000 and the price per unit is above the average price for that category.
-- Q.6 Find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Find the top 5 customers based on the highest total sales 
-- Q.9 Find the number of unique customers per category who made more than 2 purchases in that category.
-- Q.10 Create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


-- Q.1 Retrieve all transactions in April 2023 where the total_sale is above the average total_sale for that month.

SELECT *
FROM retail_sales
WHERE total_sale > (
	SELECT AVG(total_sale)
	FROM retail_sales
	WHERE TO_CHAR(sale_date, 'YYYY-MM') = '2023-04'
)
AND TO_CHAR(sale_date, 'YYYY-MM') = '2023-04';


-- Q.2 Retrieve all transactions where the category is 'Electronics' and the quantity sold is more than 3 in the August 2022

SELECT *
FROM retail_sales
WHERE 
    category = 'Electronics'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-08'
    AND
    quantity >= 3;


-- Q.3 Calculate the total sales (total_sale) for each category.

SELECT category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY category;

-- Q.4 Find the average age of customers who purchased items from the 'Electronics' category.

SELECT ROUND(AVG(age), 1) as avg_age
FROM retail_sales
WHERE category = 'Electronics';


-- Q.5 Find all transactions where the total_sale is greater than 1000 and the price per unit is above the average price for that category.

SELECT *
FROM retail_sales r
WHERE total_sale > 1000
  AND price_per_unit > (
    SELECT AVG(price_per_unit)
    FROM retail_sales
    WHERE category = r.category
);


-- Q.6 Find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP BY 
    category,
    gender
ORDER BY category;


-- Q.7 Calculate the average sale for each month. Find out best selling month in each year

SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    ROUND(AVG(total_sale)::numeric, 1) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY year, month
) as t1
WHERE rank = 1;
    
	
-- Q.8 Find the top 5 customers based on the highest total sales 

SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q.9 Find the number of unique customers per category who made more than 2 purchases in that category.

SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM (
    SELECT category, customer_id, COUNT(*) AS num_purchases
    FROM retail_sales
    GROUP BY category, customer_id
    HAVING COUNT(*) > 2
) AS sub
GROUP BY category;



-- Q.10 Create each shift and number of orders (Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift;

-- End of project