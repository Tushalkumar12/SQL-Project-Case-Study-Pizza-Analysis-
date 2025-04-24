CREATE DATABASE pizza_project
USE pizza_project

CREATE TABLE order_details(
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(100),
    quantity INT
)

LOAD DATA INFILE 'D:\Pizza_Analysis_Project\order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM order_detail
SELECT * FROM order_table
SELECT * FROM pizzas
SELECT * FROM pizza_types

Basic:
# Retrieve the total number of orders placed.
SELECT * FROM Total_Orders;

# Calculate the total revenue generated from pizza sales.
SELECT * FROM Total_Revenue;

# Identify the highest-priced pizza.
SELECT * FROM High_Price_pizza;

# Identify the most common pizza size ordered.
SELECT * FROM most_ordered_pizza_size;

# List the top 5 most ordered pizza types along with their quantities.
SELECT * FROM Top5_Ordered_Pizza;


Intermediate:
-- $ Find the total quantity of each pizza category ordered 
-- (this will help us to understand the category which customers prefer the most).
SELECT * FROM Category_wise_order;

-- $ Determine the distribution of orders by hour of the day 
-- (at which time the orders are maximum (for inventory management and resource allocation).
SELECT * FROM Day_Time_Peak_Order;
 
-- $ Find the category-wise distribution of pizzas (to understand customer behaviour).
SELECT * FROM Each_Category_ManyTypes;

-- $ Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT * FROM Avg_No_of_pizza_day ;

-- $ Determine the top 3 most ordered pizza types based on revenue 
-- (lets see the revenue wise pizza orders to understand from sales perspective which 
-- pizza is the best selling)
 SELECT * FROM Top3_most_sale_pizza;


Advanced:
-- @ Calculate the percentage contribution of each pizza type to total revenue 
-- (to understand % of contribution of each pizza in the total revenue)
SELECT * FROM Revenue_generated_by_each_category_contribution;
SELECT * FROM Revenue_generated_by_each_pizza_contribution;


-- @ Analyze the cumulative revenue generated over time.
SELECT * FROM Cumulative_revenue_over_time;

-- @ Determine the top 3 most ordered pizza types based on revenue for each pizza category
--  (In each category which pizza is the most selling)
SELECT * FROM top3_pizzas_each_category;




Basic:
# Retrieve the total number of orders placed.
CREATE VIEW Total_Orders AS
SELECT COUNT(DISTINCT order_id) as total_no_order
FROM order_detail ;


# Calculate the total revenue generated from pizza sales.
DROP VIEW IF EXISTS Total_Revenue;

CREATE VIEW Total_Revenue AS
SELECT ROUND(SUM(p.price * o.quantity) ,2) as TOTAL_Revenue
FROM order_detail o
JOIN pizzas p
ON p.pizza_id = o.pizza_id;

# Identify the highest-priced pizza.
CREATE VIEW High_Price_pizza AS
SELECT (p.price) as Price ,pt.name as Highest_price_pizza
FROM pizzas p 
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Alternate approach without using LIMIT
WITH cte as (
SELECT p.price as price, pt.name as Highest_price_pizza ,
       RANK() OVER(ORDER BY p.price DESC) as rnk
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
)
SELECT price , Highest_price_pizza
FROM cte
WHERE rnk=1

# Identify the most common pizza size ordered.
CREATE VIEW most_ordered_pizza_size AS
SELECT p.size,  COUNT(DISTINCT order_id)as no_of_orders, SUM(quantity) as Total_quantity
FROM pizzas p
JOIN order_detail o
ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY no_of_orders DESC;


# List the top 5 most ordered pizza types along with their quantities.
CREATE VIEW Top5_Ordered_Pizza AS
SELECT pt.name, SUM(quantity)Total_quantity
FROM pizza_types pt
JOIN pizzas p
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_detail o
ON o.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY Total_quantity DESC
LIMIT 5;


Intermediate:
-- $ Find the total quantity of each pizza category ordered 
-- (this will help us to understand the category which customers prefer the most).
CREATE VIEW Category_wise_order AS
SELECT category ,SUM(quantity) as total_quantity 
FROM order_detail o
JOIN pizzas p
ON p.pizza_id = o.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY category
ORDER BY total_quantity DESC;

-- $ Determine the distribution of orders by hour of the day 
-- (at which time the orders are maximum (for inventory management and resource allocation).
CREATE VIEW Day_Time_Peak_Order AS
SELECT hour(ot.order_time)as Peak_time,
       COUNT(DISTINCT o.order_id) as Count_of_order
FROM order_table ot
JOIN order_detail o
ON ot.order_id = o.order_id
GROUP BY PEAK_time
ORDER BY Count_of_order DESC;

-- $ Find the category-wise distribution of pizzas (to understand customer behaviour).
CREATE VIEW Each_Category_ManyTypes as
SELECT category ,COUNT(DISTINCT pizza_type_id) as No_of_pizza 
FROM pizza_types
GROUP BY category
ORDER BY No_of_pizza  DESC;

-- $ Group the orders by date and calculate the average number of 
-- pizzas ordered per day.
CREATE VIEW Avg_No_of_pizza_day AS
with cte as(
SELECT ot.order_date , SUM(o.quantity) as total
FROM order_detail o
JOIN order_table ot
ON o.order_id = ot.order_id
GROUP BY ot.order_date
)
SELECT FLOOR(AVG(total) )as Average_order_of_day
FROM cte;

-- Alternate approach of subquery
SELECT ROUND(AVG(total),0)as Average_order_of_day
FROM (
     SELECT ot.order_date, SUM(o.quantity)as total
     FROM order_detail o
     JOIN order_table ot
     ON o.order_id = ot.order_id
     GROUP BY ot.order_date
     ) as order_pizza
     
-- $ Determine the top 3 most ordered pizza types based on revenue 
-- (let's see the revenue wise pizza orders to understand from sales 
-- perspective which pizza is the best selling)
CREATE VIEW Top3_most_sale_pizza AS
 SELECT pt.name, SUM(o.quantity * p.price) as total_revenue
 FROM order_detail o
 JOIN pizzas p
 ON p.pizza_id = o.pizza_id
 JOIN pizza_types pt
 ON pt.pizza_type_id = p.pizza_type_id 
 Group by pt.name
 ORDER BY total_revenue DESC
 LIMIT 3;
 

 
Advanced:
-- @ Calculate the percentage contribution of each pizza type to total revenue 
-- (to understand % of contribution of each pizza in the total revenue)
CREATE VIEW Revenue_generated_by_each_category_contribution AS
SELECT category,  
CONCAT(ROUND(SUM(o.quantity * p.price) * 100/
					(SELECT SUM(o.quantity * p.price)
                    FROM order_detail o
			        JOIN pizzas p
					ON p.pizza_id = o.pizza_id),2),'%') as Revenue
FROM pizza_types pt
JOIN pizzas p
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_detail o
ON p.pizza_id = o.pizza_id
GROUP By category;

-- @ Calculate the percentage contribution of each pizza type to total revenue 
-- (to understand % of contribution of each pizza in the total revenue)
CREATE VIEW Revenue_generated_by_each_pizza_contribution AS
SELECT pt.name,           
CONCAT(ROUND(SUM(o.quantity * p.price) * 100/         -- Revenue generated by each  contribution
					(SELECT SUM(o.quantity * p.price)
                    FROM order_detail o
			        JOIN pizzas p
					ON p.pizza_id = o.pizza_id),2),'%') as Revenue
FROM pizza_types pt
JOIN pizzas p
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_detail o
ON p.pizza_id = o.pizza_id
GROUP By pt.name 
ORDER BY Revenue desc;

-- @ Analyze the cumulative revenue generated over time.
CREATE VIEW Cumulative_revenue_over_time AS
WITH cte as(
SELECT ot.order_date as Date, ROUND(SUM(o.quantity * p.price) ,0)as Revenue
FROM order_detail o
JOIN pizzas p
ON p.pizza_id = o.pizza_id
JOIN order_table ot
ON ot.order_id = o.order_id
GROUP BY Date)

SELECT Date, Revenue ,
SUM(Revenue) over(ORDER BY Date) as Cumulative_Revenue
FROM cte;


-- @ Determine the top 3 most ordered pizza types based on 4
-- revenue for each pizza category
-- (In each category which pizza is the most selling)

CREATE VIEW top3_pizzas_each_category AS
WITH cte as(
SELECT category, name, ROUND(SUM(o.quantity * p.price) ,0)as Revenue
FROM order_detail o
JOIN pizzas p
ON p.pizza_id = o.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY category,name
),
cte_2 as (
SELECT 
    category,
    name ,
    Revenue,
    RANK() OVER (PARTITION BY category ORDER BY Revenue DESC) as rnk
FROM cte
)
SELECT category, name ,Revenue

FROM cte_2
WHERE rnk <=3;

