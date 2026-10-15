-- ============================================================================
-- TOPS TECHNOLOGIES - DATA ANALYTICS ASSESSMENT
-- PROGRAM: DATA ANALYTICS
-- ASSESSMENT CODE: M4-A1
-- MODULE 4: SQL FOR DATA ANALYTICS
-- COMPLETE MASTER SOLUTION SCRIPT (MySQL 8.0+)
-- ============================================================================
-- This master file contains the complete, executable database schema, data
-- insertions, and analytical queries for Section B, Section C, and Section D.
-- Run in MySQL Workbench or via the MySQL CLI.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS food_delivery_assessment_db;
USE food_delivery_assessment_db;

-- ############################################################################
-- SECTION B: PRACTICAL CODING TASKS
-- ############################################################################

-- ============================================================================
-- TASK 1: MENU & ORDER EXPLORER
-- ============================================================================
DROP TABLE IF EXISTS food_orders;

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

-- Query 1.1: Orders in 'Mumbai', sorted by price_per_item descending
SELECT 
    order_id, customer_name, restaurant_name, item_ordered, quantity, price_per_item, order_date, city
FROM food_orders
WHERE city = 'Mumbai'
ORDER BY price_per_item DESC;

-- Query 1.2: Distinct restaurant names with at least one order
SELECT DISTINCT 
    restaurant_name
FROM food_orders
ORDER BY restaurant_name ASC;

-- Query 1.3: Top 5 most expensive individual orders (ORDER BY and LIMIT)
SELECT 
    order_id, customer_name, restaurant_name, item_ordered, quantity, price_per_item,
    (quantity * price_per_item) AS total_order_value, city, order_date
FROM food_orders
ORDER BY total_order_value DESC
LIMIT 5;


-- ============================================================================
-- TASK 2: RESTAURANT REVENUE SUMMARY
-- ============================================================================
DROP TABLE IF EXISTS delivery_orders;

CREATE TABLE delivery_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL
);

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

-- Query 2.1, 2.2, 2.3: SUM, COUNT, AVG, HAVING > 5000, CASE WHEN High/Moderate Revenue
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


-- ============================================================================
-- TASK 3: CUSTOMER-ORDER-RESTAURANT JOINED REPORT
-- ============================================================================
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS customers;

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

INSERT INTO customers (customer_id, name, city, phone) VALUES
(1, 'Aarav Patel', 'Mumbai', '9820112233'),
(2, 'Sneha Joshi', 'Mumbai', '9820223344'),
(3, 'Rohan Verma', 'Bengaluru', '9845112233'),
(4, 'Priya Sharma', 'Delhi', '9811112233'),
(5, 'Aditya Rao', 'Bengaluru', '9845223344'),
(6, 'Deepak Kumar', 'Mumbai', '9820334455'),      -- 0 orders
(7, 'Meera Sen', 'Kolkata', '9830112233');          -- 0 orders

INSERT INTO restaurants (restaurant_id, name, cuisine_type, city) VALUES
(10, 'Trishna', 'Seafood', 'Mumbai'),
(20, 'Bukhara', 'North Indian', 'Delhi'),
(30, 'Toit', 'Continental', 'Bengaluru'),
(40, 'Bademiya', 'Mughlai', 'Mumbai'),
(50, 'Karim s', 'Mughlai', 'Delhi'),
(60, 'Meghana Foods', 'Biryani', 'Bengaluru');

INSERT INTO orders (order_id, customer_id, restaurant_id, amount, order_date) VALUES
(1001, 1, 10, 1850.00, '2026-10-01'),
(1002, 1, 40, 950.00,  '2026-10-03'),
(1003, 2, 20, 2100.00, '2026-10-04'),
(1004, 3, 30, 1450.00, '2026-10-05'),
(1005, 4, 20, 3200.00, '2026-10-06'),
(1006, 5, 60, 890.00,  '2026-10-07');

-- Query 3.1: INNER JOIN (Orders with Customer Name & Restaurant Name)
SELECT 
    o.order_id, c.name AS customer_name, r.name AS restaurant_name, o.amount, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN restaurants r ON o.restaurant_id = r.restaurant_id
ORDER BY o.order_id ASC;

-- Query 3.2: LEFT JOIN (All Customers, Showing NULL for Customers without Orders)
SELECT 
    c.customer_id, c.name AS customer_name, c.city AS customer_city, c.phone,
    o.order_id, o.amount AS order_amount, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id ASC, o.order_id ASC;

-- Query 3.3: WHERE condition (Only orders where Customer and Restaurant share the same city)
SELECT 
    o.order_id, c.name AS customer_name, c.city AS customer_city,
    r.name AS restaurant_name, r.city AS restaurant_city, o.amount, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE c.city = r.city
ORDER BY o.order_id ASC;


-- ============================================================================
-- TASK 4: DELIVERY AGENT PERFORMANCE RANKING
-- ============================================================================
DROP TABLE IF EXISTS deliveries;

CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    agent_name VARCHAR(100) NOT NULL,
    restaurant_name VARCHAR(100) NOT NULL,
    delivery_time_mins INT NOT NULL,
    order_date DATE NOT NULL
);

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

-- Query 4: CTE + RANK() Window Function + Scalar Subquery + CASE WHEN
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


-- ############################################################################
-- SECTION C: MINI CAPSTONE PROJECT (FOOD DELIVERY ANALYTICS BACKEND)
-- ############################################################################

DROP VIEW IF EXISTS vw_daily_order_summary;
DROP TABLE IF EXISTS cap_orders;
DROP TABLE IF EXISTS cap_restaurants;
DROP TABLE IF EXISTS cap_customers;
DROP TABLE IF EXISTS cap_delivery_agents;

CREATE TABLE cap_delivery_agents (
    agent_id INT PRIMARY KEY AUTO_INCREMENT,
    agent_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    city VARCHAR(50) NOT NULL,
    vehicle_type VARCHAR(30) NOT NULL,
    rating DECIMAL(3, 2) NOT NULL CHECK (rating BETWEEN 1.0 AND 5.0)
);

CREATE TABLE cap_customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL
);

CREATE TABLE cap_restaurants (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_name VARCHAR(100) NOT NULL,
    cuisine_type VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    rating DECIMAL(3, 2) NOT NULL CHECK (rating BETWEEN 1.0 AND 5.0)
);

CREATE TABLE cap_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    agent_id INT NOT NULL,
    order_amount DECIMAL(10, 2) NOT NULL CHECK (order_amount > 0),
    order_status VARCHAR(30) NOT NULL,
    delivery_time_mins INT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES cap_customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES cap_restaurants(restaurant_id) ON DELETE CASCADE,
    FOREIGN KEY (agent_id) REFERENCES cap_delivery_agents(agent_id) ON DELETE RESTRICT
);

-- Insert Capstone Delivery Agents (10 rows)
INSERT INTO cap_delivery_agents (agent_id, agent_name, phone, city, vehicle_type, rating) VALUES
(1, 'Ramesh Kumar', '9876543210', 'Mumbai', 'Motorcycle', 4.8),
(2, 'Sunil Yadav', '9876543211', 'Mumbai', 'EV Scooter', 4.6),
(3, 'Amit Verma', '9876543212', 'Delhi', 'Motorcycle', 4.9),
(4, 'Deepak Sharma', '9876543213', 'Delhi', 'Motorcycle', 4.3),
(5, 'Suresh Gowda', '9876543214', 'Bengaluru', 'EV Scooter', 4.7),
(6, 'Manjunath R', '9876543215', 'Bengaluru', 'Motorcycle', 4.5),
(7, 'Vikram Singh', '9876543216', 'Mumbai', 'Motorcycle', 4.4),
(8, 'Rajesh Gupta', '9876543217', 'Delhi', 'EV Scooter', 4.7),
(9, 'Karthik Raja', '9876543218', 'Bengaluru', 'Motorcycle', 4.8),
(10, 'Pradeep Tiwari', '9876543219', 'Mumbai', 'Motorcycle', 4.2);

-- Insert Capstone Customers (10 rows)
INSERT INTO cap_customers (customer_id, customer_name, email, phone, city, registration_date) VALUES
(1, 'Aarav Patel', 'aarav.patel@gmail.com', '9820011111', 'Mumbai', '2026-01-15'),
(2, 'Priya Sharma', 'priya.s@yahoo.com', '9811022222', 'Delhi', '2026-02-20'),
(3, 'Rohan Verma', 'rohan.v@outlook.com', '9845033333', 'Bengaluru', '2026-03-10'),
(4, 'Sneha Joshi', 'sneha.j@gmail.com', '9820044444', 'Mumbai', '2026-03-25'),
(5, 'Vikram Mehta', 'vikram.m@gmail.com', '9811055555', 'Delhi', '2026-04-12'),
(6, 'Ananya Iyer', 'ananya.i@gmail.com', '9845066666', 'Bengaluru', '2026-05-01'),
(7, 'Karan Malhotra', 'karan.m@rediffmail.com', '9820077777', 'Mumbai', '2026-05-18'),
(8, 'Neha Gupta', 'neha.g@gmail.com', '9811088888', 'Delhi', '2026-06-04'),
(9, 'Aditya Rao', 'aditya.r@gmail.com', '9845099999', 'Bengaluru', '2026-07-22'),
(10, 'Pooja Nair', 'pooja.n@gmail.com', '9820000001', 'Mumbai', '2026-08-30');

-- Insert Capstone Restaurants (10 rows)
INSERT INTO cap_restaurants (restaurant_id, restaurant_name, cuisine_type, city, rating) VALUES
(1, 'Trishna Seafood', 'Coastal', 'Mumbai', 4.7),
(2, 'Bademiya Kababs', 'Mughlai', 'Mumbai', 4.3),
(3, 'Bukhara Grand', 'North Indian', 'Delhi', 4.9),
(4, 'Karim s Historic', 'Mughlai', 'Delhi', 4.6),
(5, 'Toit Brewpub', 'Continental', 'Bengaluru', 4.8),
(6, 'Meghana Foods', 'Andhra Biryani', 'Bengaluru', 4.7),
(7, 'Gajalee Coastal', 'Maharashtrian', 'Mumbai', 4.5),
(8, 'Saravana Bhavan', 'South Indian', 'Delhi', 4.4),
(9, 'Vidyarthi Bhavan', 'South Indian', 'Bengaluru', 4.6),
(10, 'Khyber Afghan', 'North Indian', 'Mumbai', 4.6);

-- Insert Capstone Orders (20 rows)
INSERT INTO cap_orders (order_id, customer_id, restaurant_id, agent_id, order_amount, order_status, delivery_time_mins, order_date) VALUES
(101, 1, 1, 1, 2400.00, 'Delivered', 26, '2026-10-08'),
(102, 1, 1, 2, 1850.00, 'Delivered', 24, '2026-10-09'),
(103, 1, 2, 1, 1200.00, 'Delivered', 30, '2026-10-10'),
(104, 1, 1, 7, 3100.00, 'Delivered', 28, '2026-10-12'),
(105, 2, 3, 3, 3500.00, 'Delivered', 35, '2026-10-07'),
(106, 2, 4, 3, 2200.00, 'Delivered', 32, '2026-10-09'),
(107, 3, 5, 5, 1400.00, 'Delivered', 25, '2026-10-08'),
(108, 3, 6, 6, 1800.00, 'Delivered', 29, '2026-10-11'),
(109, 4, 1, 1, 2900.00, 'Delivered', 27, '2026-10-10'),
(110, 4, 7, 2, 1600.00, 'Delivered', 22, '2026-10-12'),
(111, 5, 3, 3, 1100.00, 'Delivered', 38, '2026-10-08'),
(112, 6, 5, 5, 850.00,  'Delivered', 20, '2026-10-09'),
(113, 7, 2, 7, 1950.00, 'Delivered', 41, '2026-10-07'),
(114, 7, 10, 1, 2800.00, 'Delivered', 33, '2026-10-11'),
(115, 8, 4, 4, 1500.00, 'Delivered', 45, '2026-10-08'),
(116, 8, 8, 8, 700.00,  'Delivered', 23, '2026-10-10'),
(117, 9, 6, 6, 2600.00, 'Delivered', 28, '2026-10-09'),
(118, 9, 6, 9, 3200.00, 'Delivered', 30, '2026-10-11'),
(119, 9, 5, 5, 1750.00, 'Delivered', 24, '2026-10-12'),
(120, 1, 1, 1, 1500.00, 'Delivered', 25, '2026-10-13');

-- Query C.1: Revenue report (Filtered for restaurants with > 3 orders)
SELECT 
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS total_revenue,
    ROUND(AVG(o.order_amount), 2) AS avg_order_value
FROM cap_restaurants r
JOIN cap_orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city
HAVING COUNT(o.order_id) > 3
ORDER BY total_revenue DESC;

-- Query C.2: Customer segmentation by spend
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    SUM(o.order_amount) AS total_spend,
    COUNT(o.order_id) AS total_orders,
    CASE 
        WHEN SUM(o.order_amount) > 5000 THEN 'Platinum'
        WHEN SUM(o.order_amount) >= 2000 THEN 'Gold'
        ELSE 'Standard'
    END AS customer_tier
FROM cap_customers c
JOIN cap_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY total_spend DESC;

-- Query C.3a: Top 3 performing restaurants in each city using DENSE_RANK()
WITH city_rev AS (
    SELECT 
        r.city,
        r.restaurant_name,
        SUM(o.order_amount) AS total_revenue
    FROM cap_restaurants r
    JOIN cap_orders o ON r.restaurant_id = o.restaurant_id
    GROUP BY r.city, r.restaurant_name
),
ranked_rev AS (
    SELECT 
        city,
        restaurant_name,
        total_revenue,
        DENSE_RANK() OVER (PARTITION BY city ORDER BY total_revenue DESC) AS city_rank
    FROM city_rev
)
SELECT city, city_rank, restaurant_name, total_revenue
FROM ranked_rev
WHERE city_rank <= 3
ORDER BY city ASC, city_rank ASC;

-- Query C.3b: Customer's single most recent order using ROW_NUMBER()
WITH recent_orders AS (
    SELECT 
        o.order_id,
        c.customer_id,
        c.customer_name,
        r.restaurant_name,
        o.order_amount,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id 
            ORDER BY o.order_date DESC, o.order_id DESC
        ) AS rn
    FROM cap_orders o
    JOIN cap_customers c ON o.customer_id = c.customer_id
    JOIN cap_restaurants r ON o.restaurant_id = r.restaurant_id
)
SELECT 
    customer_id,
    customer_name,
    order_id AS most_recent_order_id,
    restaurant_name,
    order_amount,
    order_date
FROM recent_orders
WHERE rn = 1
ORDER BY customer_id ASC;

-- Query C.4: Create SQL VIEW vw_daily_order_summary joining all four tables
CREATE OR REPLACE VIEW vw_daily_order_summary AS
SELECT 
    o.order_date,
    c.customer_name,
    r.restaurant_name,
    da.agent_name,
    o.order_amount,
    o.delivery_time_mins
FROM cap_orders o
JOIN cap_customers c ON o.customer_id = c.customer_id
JOIN cap_restaurants r ON o.restaurant_id = r.restaurant_id
JOIN cap_delivery_agents da ON o.agent_id = da.agent_id;

-- Query C.5: Query view for orders in the last 7 days
SELECT 
    order_date,
    customer_name,
    restaurant_name,
    agent_name,
    order_amount,
    delivery_time_mins
FROM vw_daily_order_summary
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY order_date DESC, order_amount DESC;


-- ############################################################################
-- SECTION D: AI-AUGMENTED LEARNING (HUMAN DEBUGGED VERSION)
-- ############################################################################

WITH qualifying_agents AS (
    SELECT 
        da.city,
        da.agent_id,
        da.agent_name,
        COUNT(o.order_id) AS completed_orders,
        ROUND(AVG(o.delivery_time_mins), 2) AS avg_delivery_time
    FROM cap_delivery_agents da
    INNER JOIN cap_orders o ON da.agent_id = o.agent_id
    WHERE o.order_status = 'Delivered' 
      AND o.delivery_time_mins IS NOT NULL
    GROUP BY da.city, da.agent_id, da.agent_name
    HAVING COUNT(o.order_id) > 5
),
ranked_qualifying_agents AS (
    SELECT 
        city,
        agent_id,
        agent_name,
        completed_orders,
        avg_delivery_time,
        DENSE_RANK() OVER (
            PARTITION BY city 
            ORDER BY completed_orders DESC, avg_delivery_time ASC
        ) AS agent_rank
    FROM qualifying_agents
)
SELECT 
    city,
    agent_id,
    agent_name,
    completed_orders,
    avg_delivery_time,
    agent_rank
FROM ranked_qualifying_agents
WHERE agent_rank <= 3
ORDER BY city ASC, agent_rank ASC;

-- ============================================================================
-- END OF ASSESSMENT SCRIPT
-- ============================================================================
