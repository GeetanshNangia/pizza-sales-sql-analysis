-- 🍕 PIZZA SALES ANALYSIS USING SQL
-- Author: Geetansh Nangia

-- =====================================================
-- 1. Retrieve the total number of orders placed
-- =====================================================
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- =====================================================
-- 2. Calculate the total revenue generated from pizza sales
-- =====================================================
SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM order_details
JOIN pizzas 
ON pizzas.pizza_id = order_details.pizza_id;

-- =====================================================
-- 3. Identify the highest-priced pizza
-- =====================================================
SELECT pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- =====================================================
-- 4. Identify the most common pizza size ordered
-- =====================================================
SELECT pizzas.size, COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- =====================================================
-- 5. List the top 5 most ordered pizza types with quantities
-- =====================================================
SELECT pizza_types.name AS pizza_name,
       SUM(order_details.quantity) AS total_quantity
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;

-- =====================================================
-- 6. Total quantity of each pizza category ordered
-- =====================================================
SELECT pizza_types.category,
       SUM(order_details.quantity) AS total_quantity
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

-- =====================================================
-- 7. Distribution of orders by hour of the day
-- =====================================================
SELECT HOUR(order_time) AS order_hour,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

-- =====================================================
-- 8. Category-wise distribution of pizzas
-- =====================================================
SELECT category, COUNT(name) AS total_pizzas
FROM pizza_types
GROUP BY category
ORDER BY total_pizzas DESC;

-- =====================================================
-- 9. Average number of pizzas ordered per day
-- =====================================================
SELECT ROUND(AVG(daily_total), 2) AS avg_pizzas_per_day
FROM (
    SELECT orders.order_date,
           SUM(order_details.quantity) AS daily_total
    FROM orders
    JOIN order_details 
    ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS daily_orders;

-- =====================================================
-- 10. Top 3 pizza types based on revenue
-- =====================================================
SELECT pizza_types.name,
       SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- =====================================================
-- 11. Percentage contribution of each category to total revenue
-- =====================================================
SELECT pizza_types.category,
       ROUND(
           SUM(order_details.quantity * pizzas.price) /
           (SELECT SUM(order_details.quantity * pizzas.price)
            FROM order_details
            JOIN pizzas 
            ON pizzas.pizza_id = order_details.pizza_id) * 100,
       2) AS revenue_percentage
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;

-- =====================================================
-- 12. Cumulative revenue generated over time
-- =====================================================
SELECT order_date,
       SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT orders.order_date,
           SUM(order_details.quantity * pizzas.price) AS daily_revenue
    FROM orders
    JOIN order_details 
    ON orders.order_id = order_details.order_id
    JOIN pizzas 
    ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY orders.order_date
) AS revenue_table;

-- =====================================================
-- 13. Top 3 pizza types by revenue for each category
-- =====================================================
SELECT category, name, revenue
FROM (
    SELECT pizza_types.category,
           pizza_types.name,
           SUM(order_details.quantity * pizzas.price) AS revenue,
           RANK() OVER (PARTITION BY pizza_types.category 
                        ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS rank_num
    FROM pizza_types
    JOIN pizzas 
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details 
    ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
) AS ranked_pizzas
WHERE rank_num <= 3;