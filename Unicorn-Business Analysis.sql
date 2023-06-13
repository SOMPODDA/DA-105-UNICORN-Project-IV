/* 1.	How many customers do we have in the data?*/

SELECT Count (*)
FROM customers

/*2.	What was the city with the most profit for the company in 2015?*/

SELECT shipping_city,SUM(order_profits),EXTRACT(YEAR FROM order_date) AS Year_of_profit
FROM Orders AS o
JOIN order_details AS od
ON o.order_id = od.order_id
WHERE EXTRACT(YEAR FROM order_date) = '2015'
GROUP BY 1,3
ORDER BY 2 DESC
LIMIT 5;

/* 3.	In 2015, what was the most profitable city's profit?*/

SELECT shipping_city,SUM(order_profits),EXTRACT(YEAR FROM order_date) AS Year_of_profit
FROM Orders AS o
JOIN order_details AS od
ON o.order_id = od.order_id
WHERE EXTRACT(YEAR FROM order_date) = '2015'
GROUP BY 1,3
ORDER BY 2 DESC
LIMIT 5;

/* 4.	How many different cities do we have in the data?*/

SELECT  COUNT (DISTINCT shipping_city) AS different_cities_nos
FROM orders

/* 5.	Show the total spent by customers from low to high.*/

SELECT c.customer_id,c.customer_name,SUM(od.order_sales) AS total_spent
FROM order_details AS od
JOIN orders AS o
ON o.order_id = od.order_id
JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY 1,2
ORDER BY 3
LIMIT 10;

/* 6.	What is the most profitable city in the State of Tennessee?*/

SELECT o.shipping_city, SUM(od.order_profits) AS most_profit
FROM order_details AS od
JOIN orders AS o
ON o.order_id = od.order_id
WHERE o.shipping_state = 'Tennessee'
GROUP BY 1
ORDER BY SUM(od.order_profits) DESC
LIMIT 5;

/* 7.	What’s the average annual profit for that city across all years?*/

SELECT o.shipping_city, ROUND(AVG(od.order_profits),2) AS avg_profit
FROM order_details AS od
JOIN orders AS o
ON o.order_id = od.order_id
WHERE o.shipping_city = 'Lebanon'
GROUP BY 1
ORDER BY AVG(od.order_profits) DESC;

/* 8.	What is the distribution of customer types in the data?*/

SELECT DISTINCT customer_segment AS customerè_types, count(*)
FROM customers
GROUP BY 1;

/* 9.	What’s the most profitable product category on average in Iowa across all years? */

SELECT p.product_category,o.shipping_state,AVG(od.order_profits) AS avg_profitable_category
FROM product AS p
JOIN order_details AS od
ON p.product_id = od.product_id
JOIN orders AS o
ON o.order_id = od.order_id
WHERE o.shipping_state = 'Iowa'
GROUP BY 1,2
ORDER BY AVG(od.order_profits) DESC;

/* 10. What is the most popular product in that category across all states in 2016?*/

SELECT p.product_category,p.product_name,SUM(od.quantity) AS total_quantity,
EXTRACT(YEAR FROM order_date) AS Year_of_profit
FROM product AS p
JOIN order_details AS od
ON p.product_id = od.product_id
JOIN orders AS o
ON o.order_id = od.order_id
WHERE EXTRACT (YEAR FROM o.order_date) = '2016' AND p.product_category = 'Furniture'
GROUP BY 1,2,4
ORDER BY SUM(od.quantity) DESC;

/* 11.	Which customer got the most discount in the data? (in total amount)?*/

SELECT c.customer_id,c.customer_name, SUM((order_sales*order_discount)/(1-order_discount)) AS total_discount
FROM customers AS c
JOIN orders AS o
ON c.customer_id = o.customer_id
JOIN order_details AS od
ON o.order_id = od.order_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;

/* 12.	How widely did monthly profits vary in 2018?*/

SELECT EXTRACT(MONTH FROM o.order_date) AS MONTH, SUM(od.order_profits) AS monthly_profits,LAG (SUM(od.order_profits),1,0) OVER(ORDER BY EXTRACT(MONTH FROM o.order_date))
AS lag, (SUM(od.order_profits)-LAG (SUM(od.order_profits),1,0) OVER(ORDER BY EXTRACT(MONTH FROM o.order_date))) AS variance_monthly

FROM orders AS o
JOIN order_details AS od
ON o.order_id = od.order_id
WHERE EXTRACT(YEAR FROM order_date) = '2018'
GROUP BY 1
ORDER BY 1

/* 13.	Which order was the highest in 2015?*/

SELECT p.product_subcategory,od.order_id,SUM(od.order_sales) AS total_sales
FROM orders AS o
JOIN order_details AS od
ON o.order_id = od.order_id
JOIN product AS p
ON p.product_id = od.product_id
WHERE EXTRACT(YEAR FROM order_date) = '2015'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

/* 14.	What was the rank of each city in the East region in 2015?*/

SELECT o.shipping_city,
SUM(od.quantity) AS total_quantity, rank() OVER (Order by SUM(od.quantity)DESC) AS city_rank
FROM orders AS o
JOIN order_details AS od
ON o.order_id = od.order_id
WHERE EXTRACT(YEAR FROM order_date) = '2015' AND o.shipping_region = 'East'
GROUP BY 1
ORDER BY 3;

/* 15.	Display customer names for customers who are in the segment ‘Consumer’ or ‘Corporate.’
        How many customers are there in total?*/

SELECT customer_id,customer_name,COUNT(*)
FROM customers
WHERE customer_segment IN ('Consumer', 'Corporate')
GROUP BY 1,2

--- AND----

SELECT COUNT(*)
FROM customers
WHERE
customer_segment IN ('Consumer', 'Corporate');

/* 16.	Calculate the difference between the largest and smallest order quantities for product id ‘100.’*/

select MAX(quantity) AS largest_order,MIN(quantity) AS smallest_order,
(MAX(quantity)-MIN(quantity)) AS difference
FROM order_details
WHERE product_id = '100'

/* 17.	Calculate the percent of products that are within the category ‘Furniture.’ */

WITH t1 AS
(SELECT product_category,COUNT(*) AS count_category
FROM product
GROUP BY 1),
t2 AS
(SELECT COUNT(*) AS total_category
FROM product)

SELECT product_category, ROUND(t1.count_category*1.0/t2.total_category*100,2) AS percentage_category
FROM t1,t2

-- OR--
select
(SELECT COUNT(*) AS count_category FROM product where product_category = 'Furniture')*1.0/
(SELECT COUNT(*) AS count_category FROM product) as Furniture_percentage


/* 18.	Display the number of duplicate products based on their product manufacturer.
Example: A product with an identical product manufacturer can be considered a duplicate.*/

select product_manufacturer,COUNT(*) AS num_of_duplicates
FROM product
GROUP BY 1
HAVING count(*)>1

/* 19.	Show the product_subcategory and the total number of products in the subcategory.
        Show the order from most to least products and then by product_subcategory name ascending.*/

SELECT product_subcategory,COUNT(product_subcategory) AS total_products
FROM product
GROUP BY 1
ORDER BY 2 DESC;

-- AND--

SELECT product_subcategory,COUNT(product_subcategory) AS total_products
FROM product
GROUP BY 1
ORDER BY 1;

/* 20.	Show the product_id(s), the sum of quantities, where the total sum of its product quantities is greater than or equal to 100.*/

SELECT product_id,SUM(quantity) AS total_quantity
FROM order_details
GROUP BY 1
HAVING SUM(quantity) >= '100'

/* 21 Join all database tables into one dataset that includes all unique columns and download it as a .csv file*/

SELECT *
FROM order_details
NATURAL JOIN orders
NATURAL JOIN customers
NATURAL JOIN product
