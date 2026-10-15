-- ============================================================================
-- TOPS TECHNOLOGIES - DATA ANALYTICS ASSESSMENT M4-A1
-- MODULE 4: SQL FOR DATA ANALYTICS
-- SECTION B: PRACTICAL CODING TASKS (MySQL 8.0+)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS food_delivery_assessment_db;
USE food_delivery_assessment_db;

-- ----------------------------------------------------------------------------
-- TASK 1: MENU & ORDER EXPLORER
-- ----------------------------------------------------------------------------

-- Drop existing table if exists
DROP TABLE IF EXISTS food_orders;

-- 1. Create table food_orders
CREATE TABLE food_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    restaurant_name VARCHAR(100) NOT NULL,
    item_ordered VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    price_per_item DECIMAL(10, 2) NOT NULL,
    order_date DATE NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- Insert sample data (10 rows spanning 3 cities: Mumbai, Delhi, Bengaluru)
INSERT INTO food_orders (order_id, customer_name, restaurant_name, item_ordered, quantity, price_per_item, order_date, city) VALUES
(101, 'Aarav Patel', 'Trishna', 'Butter Garlic Crab', 2, 1250.00, '2026-10-01', 'Mumbai'),
(102, 'Priya Sharma', 'Bukhara', 'Dal Bukhara', 1, 850.00, '2026-10-02', 'Delhi'),
(103, 'Rohan Verma', 'Toit', 'Craft Beer & Pizza', 3, 620.00, '2026-10-03', 'Bengaluru'),
(104, 'Sneha Joshi', 'Trishna', 'Prawn Koliwada', 1, 950.00, '2026-10-04', 'Mumbai'),
(105, 'Vikram Mehta', 'Karim s', 'Mutton Korma', 2, 540.00, '2026-10-05', 'Delhi'),
(106, 'Ananya Iyer', 'Vidyarthi Bhavan', 'Masala Dosa Platter', 4, 120.00, '2026-10-06', 'Bengaluru'),
(107, 'Karan Malhotra', 'Bademiya', 'Chicken Baida Roti', 2, 380.00, '2026-10-07', 'Mumbai'),
(108, 'Neha Gupta', 'Trishna', 'Surmai Fish Curry', 1, 890.00, '2026-10-08', 'Mumbai'),
(109, 'Aditya Rao', 'Meghana Foods', 'Special Chicken Biryani', 3, 390.00, '2026-10-09', 'Bengaluru'),
(110, 'Pooja Nair', 'Saravana Bhavan', 'Filter Coffee & Vada Combo', 2, 160.00, '2026-10-10', 'Delhi');

-- Query 1.1: Retrieve all orders placed in 'Mumbai', sorted by price_per_item in descending order
SELECT 
    order_id,
    customer_name,
    restaurant_name,
    item_ordered,
    quantity,
    price_per_item,
    order_date,
    city
FROM food_orders
WHERE city = 'Mumbai'
ORDER BY price_per_item DESC;

-- Query 1.2: Return all distinct restaurant names that have received at least one order
SELECT DISTINCT 
    restaurant_name
FROM food_orders
ORDER BY restaurant_name ASC;

-- Query 1.3: List the top 5 most expensive individual orders using ORDER BY and LIMIT
-- (Displaying both price_per_item and computed total order value quantity * price_per_item)
SELECT 
    order_id,
    customer_name,
    restaurant_name,
    item_ordered,
    quantity,
    price_per_item,
    (quantity * price_per_item) AS total_order_value,
    city,
    order_date
FROM food_orders
ORDER BY total_order_value DESC
LIMIT 5;


-- ----------------------------------------------------------------------------
-- TASK 2: RESTAURANT REVENUE SUMMARY
-- ----------------------------------------------------------------------------

-- Drop existing table if exists
DROP TABLE IF EXISTS delivery_orders;

-- 1. Create table delivery_orders
CREATE TABLE delivery_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL
);

-- Insert sample data (12 rows across 4 restaurants: Spice Hub, Pizza Paradise, Royal Biryani, Burger King)
INSERT INTO delivery_orders (order_id, restaurant_name, city, total_amount, order_status, order_date) VALUES
(201, 'Spice Hub', 'Mumbai', 1850.00, 'Delivered', '2026-10-01'),
(202, 'Pizza Paradise', 'Delhi', 1200.00, 'Delivered', '2026-10-02'),
(203, 'Royal Biryani', 'Bengaluru', 3200.00, 'Delivered', '2026-10-03'),
(204, 'Spice Hub', 'Mumbai', 2400.00, 'Delivered', '2026-10-04'),
(205, 'Burger King', 'Delhi', 750.00, 'Delivered', '2026-10-05'),
(206, 'Royal Biryani', 'Bengaluru', 4100.00, 'Delivered', '2026-10-06'),
(207, 'Pizza Paradise', 'Delhi', 1950.00, 'Delivered', '2026-10-07'),
(208, 'Spice Hub', 'Mumbai', 3100.00, 'Delivered', '2026-10-08'),
(209, 'Burger King', 'Delhi', 890.00, 'Cancelled', '2026-10-09'),
(210, 'Royal Biryani', 'Bengaluru', 3800.00, 'Delivered', '2026-10-10'),
(211, 'Spice Hub', 'Mumbai', 4200.00, 'Delivered', '2026-10-11'),
(212, 'Pizza Paradise', 'Delhi', 1400.00, 'Delivered', '2026-10-12');

-- Query 2.1: Use SUM, COUNT, and AVG to calculate total revenue, total orders, and average order value per restaurant
SELECT 
    restaurant_name,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM delivery_orders
GROUP BY restaurant_name
ORDER BY total_revenue DESC;

-- Query 2.2 & 2.3: Add HAVING (> 5,000) and extend SELECT with CASE WHEN ('High Revenue' vs 'Moderate Revenue')
SELECT 
    restaurant_name,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    CASE 
        WHEN SUM(total_amount) > 10000 THEN 'High Revenue'
        ELSE 'Moderate Revenue'
    END AS revenue_category
FROM delivery_orders
GROUP BY restaurant_name
HAVING SUM(total_amount) > 5000
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- TASK 3: CUSTOMER-ORDER-RESTAURANT JOINED REPORT
-- ----------------------------------------------------------------------------

-- Drop existing tables if they exist (in foreign key dependency order)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS customers;

-- 1. Create related tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    cuisine_type VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Insert sample data: 7 customers (with customers 6 and 7 having 0 orders), 6 restaurants, 6 orders
INSERT INTO customers (customer_id, name, city, phone) VALUES
(1, 'Aarav Patel', 'Mumbai', '9820112233'),
(2, 'Sneha Joshi', 'Mumbai', '9820223344'),
(3, 'Rohan Verma', 'Bengaluru', '9845112233'),
(4, 'Priya Sharma', 'Delhi', '9811112233'),
(5, 'Aditya Rao', 'Bengaluru', '9845223344'),
(6, 'Deepak Kumar', 'Mumbai', '9820334455'),      -- Intentionally no orders
(7, 'Meera Sen', 'Kolkata', '9830112233');          -- Intentionally no orders

INSERT INTO restaurants (restaurant_id, name, cuisine_type, city) VALUES
(10, 'Trishna', 'Seafood', 'Mumbai'),
(20, 'Bukhara', 'North Indian', 'Delhi'),
(30, 'Toit', 'Continental', 'Bengaluru'),
(40, 'Bademiya', 'Mughlai', 'Mumbai'),
(50, 'Karim s', 'Mughlai', 'Delhi'),
(60, 'Meghana Foods', 'Biryani', 'Bengaluru');

INSERT INTO orders (order_id, customer_id, restaurant_id, amount, order_date) VALUES
(1001, 1, 10, 1850.00, '2026-10-01'), -- Mumbai customer, Mumbai restaurant
(1002, 1, 40, 950.00,  '2026-10-03'), -- Mumbai customer, Mumbai restaurant
(1003, 2, 20, 2100.00, '2026-10-04'), -- Mumbai customer, Delhi restaurant (cross-city order/gift)
(1004, 3, 30, 1450.00, '2026-10-05'), -- Bengaluru customer, Bengaluru restaurant
(1005, 4, 20, 3200.00, '2026-10-06'), -- Delhi customer, Delhi restaurant
(1006, 5, 60, 890.00,  '2026-10-07'); -- Bengaluru customer, Bengaluru restaurant

-- Query 3.1: INNER JOIN query to list each order alongside customer name and fulfilling restaurant name
SELECT 
    o.order_id,
    c.name AS customer_name,
    r.name AS restaurant_name,
    o.amount,
    o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN restaurants r ON o.restaurant_id = r.restaurant_id
ORDER BY o.order_id ASC;

-- Query 3.2: LEFT JOIN query to list all customers (including those with no orders, with NULL in order columns)
SELECT 
    c.customer_id,
    c.name AS customer_name,
    c.city AS customer_city,
    c.phone,
    o.order_id,
    o.amount AS order_amount,
    o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id ASC, o.order_id ASC;

-- Query 3.3: WHERE condition to show only orders where both customer and restaurant belong to the same city
SELECT 
    o.order_id,
    c.name AS customer_name,
    c.city AS customer_city,
    r.name AS restaurant_name,
    r.city AS restaurant_city,
    o.amount,
    o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE c.city = r.city
ORDER BY o.order_id ASC;


-- ----------------------------------------------------------------------------
-- TASK 4: DELIVERY AGENT PERFORMANCE RANKING
-- ----------------------------------------------------------------------------

-- Drop existing table if exists
DROP TABLE IF EXISTS deliveries;

-- 1. Create table deliveries
CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    agent_name VARCHAR(100) NOT NULL,
    restaurant_name VARCHAR(100) NOT NULL,
    delivery_time_mins INT NOT NULL,
    order_date DATE NOT NULL
);

-- Insert sample data (12 rows across 4 agents with varied delivery times)
INSERT INTO deliveries (delivery_id, agent_name, restaurant_name, delivery_time_mins, order_date) VALUES
(1, 'Ramesh Kumar', 'Trishna', 22, '2026-10-01'),
(2, 'Suresh Singh', 'Bukhara', 35, '2026-10-01'),
(3, 'Amit Sharma', 'Toit', 28, '2026-10-02'),
(4, 'Deepak Patel', 'Bademiya', 42, '2026-10-02'),
(5, 'Ramesh Kumar', 'Spice Hub', 24, '2026-10-03'),
(6, 'Suresh Singh', 'Karim s', 38, '2026-10-03'),
(7, 'Amit Sharma', 'Meghana Foods', 26, '2026-10-04'),
(8, 'Deepak Patel', 'Burger King', 45, '2026-10-04'),
(9, 'Ramesh Kumar', 'Pizza Paradise', 25, '2026-10-05'),
(10, 'Suresh Singh', 'Bukhara', 32, '2026-10-05'),
(11, 'Amit Sharma', 'Toit', 27, '2026-10-06'),
(12, 'Deepak Patel', 'Trishna', 40, '2026-10-06');

-- Query 4: CTE (agent_stats) + RANK() Window Function + Scalar Subquery + CASE WHEN
WITH agent_stats AS (
    SELECT 
        agent_name,
        COUNT(delivery_id) AS total_deliveries,
        ROUND(AVG(delivery_time_mins), 2) AS avg_delivery_time
    FROM deliveries
    GROUP BY agent_name
)
SELECT 
    agent_name,
    total_deliveries,
    avg_delivery_time,
    RANK() OVER (ORDER BY avg_delivery_time ASC) AS speed_rank,
    ROUND((SELECT AVG(delivery_time_mins) FROM deliveries), 2) AS platform_avg_time,
    CASE 
        WHEN avg_delivery_time <= (SELECT AVG(delivery_time_mins) FROM deliveries) THEN 'On Track'
        ELSE 'Needs Improvement'
    END AS performance_status
FROM agent_stats
ORDER BY speed_rank ASC;
