-- ============================================================================
-- TOPS TECHNOLOGIES - DATA ANALYTICS ASSESSMENT M4-A1
-- MODULE 4: SQL FOR DATA ANALYTICS
-- SECTION C: MINI CAPSTONE PROJECT (MySQL 8.0+)
-- PROJECT TITLE: FOOD DELIVERY ANALYTICS — SQL BACKEND
-- ============================================================================

CREATE DATABASE IF NOT EXISTS food_delivery_capstone_db;
USE food_delivery_capstone_db;

-- ----------------------------------------------------------------------------
-- 1. SCHEMA DESIGN: MULTI-TABLE RELATIONAL BACKEND WITH PK & FK CONSTRAINTS
-- ----------------------------------------------------------------------------

-- Drop view and tables in reverse dependency order
DROP VIEW IF EXISTS vw_daily_order_summary;
DROP TABLE IF EXISTS cap_orders;
DROP TABLE IF EXISTS cap_restaurants;
DROP TABLE IF EXISTS cap_customers;
DROP TABLE IF EXISTS cap_delivery_agents;

-- Table 1: Delivery Agents
CREATE TABLE cap_delivery_agents (
    agent_id INT PRIMARY KEY AUTO_INCREMENT,
    agent_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    city VARCHAR(50) NOT NULL,
    vehicle_type VARCHAR(30) NOT NULL,
    rating DECIMAL(3, 2) NOT NULL CHECK (rating BETWEEN 1.0 AND 5.0)
);

-- Table 2: Customers
CREATE TABLE cap_customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL
);

-- Table 3: Restaurants
CREATE TABLE cap_restaurants (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_name VARCHAR(100) NOT NULL,
    cuisine_type VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    rating DECIMAL(3, 2) NOT NULL CHECK (rating BETWEEN 1.0 AND 5.0)
);

-- Table 4: Orders (Transactional Fact Table)
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

-- ----------------------------------------------------------------------------
-- 2. DATA INGESTION: REALISTIC SAMPLE DATA (>= 10 ROWS PER TABLE, 3 CITIES)
-- Cities: Mumbai, Delhi, Bengaluru
-- ----------------------------------------------------------------------------

-- Insert Delivery Agents (10 rows)
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

-- Insert Customers (10 rows)
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

-- Insert Restaurants (10 rows)
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

-- Insert Orders (20 rows, including recent orders within last 7 days)
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

-- ----------------------------------------------------------------------------
-- 3. ANALYTICAL QUERY SUITE
-- ----------------------------------------------------------------------------

-- Query C.1: Revenue Report Query (GROUP BY, HAVING COUNT > 3, SUM, COUNT, AVG)
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

-- Query C.2: Customer Segmentation Query (CASE WHEN Platinum, Gold, Standard)
-- Ordered from highest to lowest spender
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

-- Query C.3a: Top 3 Performing Restaurants in Each City (DENSE_RANK Window Function)
WITH restaurant_revenue_cte AS (
    SELECT 
        r.city,
        r.restaurant_id,
        r.restaurant_name,
        SUM(o.order_amount) AS total_revenue
    FROM cap_restaurants r
    JOIN cap_orders o ON r.restaurant_id = o.restaurant_id
    GROUP BY r.city, r.restaurant_id, r.restaurant_name
),
ranked_city_restaurants AS (
    SELECT 
        city,
        restaurant_id,
        restaurant_name,
        total_revenue,
        DENSE_RANK() OVER (PARTITION BY city ORDER BY total_revenue DESC) AS city_rank
    FROM restaurant_revenue_cte
)
SELECT 
    city,
    city_rank,
    restaurant_name,
    total_revenue
FROM ranked_city_restaurants
WHERE city_rank <= 3
ORDER BY city ASC, city_rank ASC;

-- Query C.3b: Customer's Single Most Recent Order (ROW_NUMBER Window Function)
WITH customer_order_recency AS (
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
FROM customer_order_recency
WHERE rn = 1
ORDER BY customer_id ASC;

-- ----------------------------------------------------------------------------
-- 4. SAVED VIEW & VIEW QUERY
-- ----------------------------------------------------------------------------

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

-- Query C.5: Query the view to display only orders placed in the last 7 days
-- In MySQL: Using DATE_SUB(CURDATE(), INTERVAL 7 DAY) or CURDATE() - INTERVAL 7 DAY
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
