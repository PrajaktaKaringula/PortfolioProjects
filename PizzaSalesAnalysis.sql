USE PizzaSalesDB;

SELECT * FROM pizza_sales;

-- BASIC DATA EXPLORATION
-- How many total orders are recorded in the system?
SELECT COUNT(*)
FROM pizza_sales;

-- How many unique pizzas are there in the dataset?
SELECT COUNT(DISTINCT pizza_name_id) AS unique_pizzas_count
FROM pizza_sales;

-- What are the different pizza categories available?
SELECT DISTINCT pizza_category
FROM pizza_sales;

-- What are different pizza sizes and their distribution?
SELECT pizza_size, SUM(quantity) AS size_distribution
FROM pizza_sales
GROUP BY pizza_size
ORDER BY size_distribution;

-- SALES PERFORMANCE ANALYSIS
-- What are the top 5 best selling pizzas by quantity?
SELECT TOP 5 pizza_name, SUM(quantity) AS popularity
FROM pizza_sales
GROUP BY pizza_name
ORDER BY popularity DESC;
/* Use SUM(quantity) instead of COUNT(quantity)
COUNT(quantity) counts the number of rows, not the total quantity of pizzas sold.
SUM(quantity) correctly gives the total pizzas sold per type. */

-- What are the top 5 highest revenue generating pizzas?
SELECT TOP 5 pizza_name, SUM(total_price) AS revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY revenue DESC;

-- Which pizza size generates the highest total revenue?
SELECT TOP 1 pizza_size, SUM(total_price) AS revenue
FROM pizza_sales
GROUP BY pizza_size
ORDER BY revenue DESC;

-- What is the total revenue per pizza category?
SELECT pizza_category, SUM(total_price) as revenue
FROM pizza_sales
GROUP BY pizza_category
ORDER BY revenue DESC;

-- What is the average order value?
SELECT SUM(total_price)/COUNT(order_id) AS avg_order_value
FROM pizza_sales;


-- TIME BASED ANALYSIS
-- What are the busiest order times (most order places)?
SELECT DATEPART(HOUR, order_time) AS busy_order_time, COUNT(order_id) AS order_count
FROM pizza_sales
GROUP BY DATEPART(HOUR, order_time)
ORDER BY order_count DESC;

-- Which days of the week have the highest sales?
SELECT DATENAME(WEEKDAY, order_date) AS order_day, SUM(total_price) AS sales_amount
FROM pizza_sales
GROUP BY DATENAME(WEEKDAY, order_date)
ORDER BY sales_amount DESC;

-- Which month has the highest revenue?
SELECT FORMAT(order_date, 'MMMM') AS order_month, SUM(total_price) AS total_revenue
FROM pizza_sales
GROUP BY FORMAT(order_date, 'MMMM')
ORDER BY total_revenue DESC;


-- CUSTOMER AND ORDER INSIGHTS
-- What is the average number of pizzas per order?
SELECT (SUM(quantity) * 1.0)/COUNT(DISTINCT order_id) AS avg_pizzas_per_order
FROM pizza_sales;

-- What is the most frequently ordered pizza size?
SELECT TOP 1 pizza_size, SUM(quantity) AS order_frequency
FROM pizza_sales
GROUP BY pizza_size
ORDER BY order_frequency DESC;


-- PROFITABILITY ANALYSIS
-- What is the average price per pizza category?
SELECT pizza_category, AVG(unit_price) AS avg_price
FROM pizza_sales
GROUP BY pizza_category
ORDER BY avg_price DESC;
-- unit_price represents the price of a single pizza.

-- Which pizzas have the highest total price per order?
SELECT TOP 5 pizza_name, SUM(total_price) AS total_revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_revenue DESC;
 


