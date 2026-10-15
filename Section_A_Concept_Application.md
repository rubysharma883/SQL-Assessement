# Section A: Concept Application — Technical Solutions & Explanations

**Program:** Data Analytics  
**Course Module:** Module 4 – SQL for Data Analytics  
**Assessment Code:** M4-A1  
**Database Engine:** MySQL 8.0+  

---

## Scenario S1: Operations Revenue & Order Volume Thresholds

### Scenario Overview
You are a data analyst at a food delivery platform. The operations team needs a report showing which restaurant partners earned more than Rs 1,00,000 in total revenue last month — but only for restaurants that received at least 50 orders.

### Question
> Explain how you would use `GROUP BY` and `HAVING` together to produce this report. Why is `HAVING` more appropriate than `WHERE` for filtering on aggregated values? What would break in your query if you replaced `HAVING` with `WHERE`?

### Technical Explanation & SQL Solution

#### 1. SQL Query Implementation
```sql
SELECT 
    restaurant_id,
    restaurant_name,
    COUNT(order_id) AS total_orders,
    SUM(order_amount) AS total_revenue
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) 
  AND order_date < CURDATE()
  AND order_status = 'Delivered'
GROUP BY restaurant_id, restaurant_name
HAVING SUM(order_amount) > 100000 
   AND COUNT(order_id) >= 50
ORDER BY total_revenue DESC;
```

#### 2. Logical Query Processing Lifecycle: GROUP BY and HAVING in Concert
In relational database systems (RDBMS) like MySQL, SQL statements are not processed in the textual order they are written (`SELECT` first). Instead, the database engine executes clauses in a strict logical lifecycle:
1. `FROM` & `JOIN` (Identify source tables and join datasets)
2. `WHERE` (Filter individual base rows before grouping)
3. `GROUP BY` (Aggregate remaining rows into distinct groups)
4. `HAVING` (Filter aggregated groups based on summary expressions)
5. `SELECT` (Compute projected columns, aliases, and expressions)
6. `ORDER BY` (Sort final output rows)
7. `LIMIT` (Restrain result row count)

To satisfy the business requirement:
- `GROUP BY restaurant_id, restaurant_name` collapses individual order transaction rows into a single aggregated row per restaurant partner.
- `HAVING` evaluates conditions against the summary metrics produced by the aggregation functions (`SUM(order_amount)` and `COUNT(order_id)`). It discards any restaurant group that does not satisfy both business thresholds (`SUM > 100000` AND `COUNT >= 50`).

#### 3. Why HAVING is More Appropriate Than WHERE for Aggregated Values
- **Row-Level Scope (`WHERE`):** The `WHERE` clause evaluates criteria on individual, unprocessed base records *before* rows are grouped. At the time `WHERE` executes, groupings do not yet exist, and the engine cannot calculate what a restaurant's total revenue or total orders will be.
- **Group-Level Scope (`HAVING`):** The `HAVING` clause is specifically designed to filter groups *after* aggregation functions (`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`) have calculated metrics over each partition. Filtering on aggregate values must take place in `HAVING`.

#### 4. What Breaks If You Replace HAVING with WHERE?
If an analyst attempts to place aggregate expressions inside the `WHERE` clause:
```sql
-- INVALID QUERY: THIS WILL FAIL
SELECT restaurant_id, SUM(order_amount) AS total_revenue
FROM orders
WHERE SUM(order_amount) > 100000 AND COUNT(order_id) >= 50  -- SYNTAX / COMPILATION ERROR!
GROUP BY restaurant_id;
```
**The Failure Mode:**  
MySQL's query parser immediately halts compilation and throws:
`ERROR 1111 (HY000): Invalid use of group function`  
Because the query optimizer cannot evaluate group functions during row-level filtering, the query aborts execution entirely without returning any result.

---

## Scenario S2: Customer Insights & Data Preservation via JOINs

### Scenario Overview
You are building a customer insights report for a food delivery app. The marketing team needs a list of every registered customer and their most recent order details — even for customers who have never placed an order.

### Question
> Which type of JOIN would you use to ensure all customers appear in the result, including those with no orders? Justify your choice by comparing it with `INNER JOIN`, and explain specifically what data would be lost if `INNER JOIN` were used instead.

### Technical Explanation & SQL Solution

#### 1. SQL Query Implementation
```sql
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.phone,
    o.order_id,
    o.order_date,
    o.order_amount,
    o.order_status
FROM customers c
LEFT JOIN (
    -- Subquery / CTE to isolate each customer's most recent order
    SELECT 
        customer_id,
        order_id,
        order_date,
        order_amount,
        order_status,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC) as rn
    FROM orders
) o ON c.customer_id = o.customer_id AND o.rn = 1
ORDER BY c.customer_id ASC;
```

#### 2. Justification: LEFT JOIN vs INNER JOIN
- **`LEFT OUTER JOIN` (or `LEFT JOIN`):**  
  Designates `customers` as the left (preserved) table. The query engine guarantees that every single row from `customers` is emitted into the final result set. For registered customers who have placed orders, matching order details are joined. For registered customers who have never placed an order, MySQL pads all order-related columns with `NULL` values while keeping the customer profile intact.
- **`INNER JOIN`:**  
  Requires an exact matching key in both relations (`c.customer_id = o.customer_id`). Any customer ID in `customers` that does not exist in `orders` fails the predicate check and is discarded completely from the result set.

#### 3. Specific Data Lost If INNER JOIN Were Used
If an `INNER JOIN` were used:
1. **Loss of Inactive / Zero-Order Customers:** Every newly registered user who has not completed their first order, as well as registered accounts that churned before transacting, would be completely removed from the dataset.
2. **Business Impact on Marketing Campaigns:**
   - The marketing team would lose visibility into user onboarding and conversion drop-offs.
   - High-value targeted activation campaigns (such as sending "Welcome! Get 50% off your first order" push notifications or SMS vouchers) would be rendered impossible because inactive customers would be invisible in the report.
   - Conversion funnel metrics (e.g., Conversion Rate = Transacting Users / Total Registered Users) would be distorted.

---

## Scenario S3: Delivery Performance Benchmarking & Subquery Mechanics

### Scenario Overview
You are designing a delivery performance dashboard. The business wants to identify delivery agents whose average delivery time is faster than the overall platform average, without using a temporary table or creating a new view.

### Question
> Describe how you would write a subquery to find these agents. What type of subquery is most appropriate here — scalar, row, or table — and why? What would happen if you tried to place this subquery in the `SELECT` clause instead of the `WHERE` clause?

### Technical Explanation & SQL Solution

#### 1. SQL Query Implementation
```sql
SELECT 
    agent_id,
    agent_name,
    COUNT(delivery_id) AS total_deliveries,
    ROUND(AVG(delivery_time_mins), 2) AS agent_avg_delivery_time
FROM deliveries
WHERE delivery_time_mins IS NOT NULL
GROUP BY agent_id, agent_name
HAVING AVG(delivery_time_mins) < (
    -- Scalar Subquery calculating platform benchmark
    SELECT AVG(delivery_time_mins) 
    FROM deliveries 
    WHERE delivery_time_mins IS NOT NULL
)
ORDER BY agent_avg_delivery_time ASC;
```

#### 2. Most Appropriate Subquery Type: Scalar Subquery
- **Classification:** A **Scalar Subquery** is an independent query enclosed in parentheses that evaluates to exactly **one value** (a single column and a single row, e.g., `28.45`).
- **Why It Is Appropriate:**  
  The overall platform average delivery time is a single aggregated numeric metric across the entire dataset. In SQL, comparison operators (`<`, `<=`, `>`, `=`) require a single scalar operand on either side.
  - A *row subquery* returns multiple columns for a single row (`(col1, col2)`), which cannot be compared with `<`.
  - A *table subquery* returns multiple rows and columns (a tabular relation), which requires set operators (`IN`, `EXISTS`, `ANY`, `ALL`) and cannot be compared directly using a scalar arithmetic operator `<`.
  Therefore, a scalar subquery is mathematically and syntactically the only appropriate construct.

#### 3. What Happens If the Subquery Is Placed in SELECT Instead of WHERE / HAVING?
- **Behavior in `SELECT`:**  
  Placing the scalar subquery in the `SELECT` list:
  ```sql
  SELECT 
      agent_name, 
      AVG(delivery_time_mins) AS agent_avg,
      (SELECT AVG(delivery_time_mins) FROM deliveries) AS platform_avg
  FROM deliveries
  GROUP BY agent_name;
  ```
  This merely evaluates the scalar subquery as a constant benchmark projection column alongside each agent's metrics. It displays the benchmark value on every row for reporting or visualization purposes.
- **Why It Fails to Solve the Problem:**  
  Placing it in `SELECT` **does not filter any rows**. Slow agents who perform worse than the platform average will still be returned in the output. To restrict the result set strictly to agents who beat the average, the subquery must be placed in the filtering clause (`HAVING` or outer `WHERE`).

---

## Scenario S4: Revenue Ranking & Window Function Tie-Breaking

### Scenario Overview
You are analysing order data for a food delivery company. The product team wants to rank the top 3 highest-revenue restaurants within each city. Two restaurants in Surat have the exact same revenue figure and you must decide how to number them.

### Question
> Compare `RANK()` and `DENSE_RANK()` window functions for this use case. Which would you choose and why? Provide a brief example showing how each function would number three restaurants where two share the same revenue, and explain the practical impact of that difference on the product team's report.

### Technical Explanation & SQL Solution

#### 1. Comparison of RANK() vs DENSE_RANK()
Both `RANK()` and `DENSE_RANK()` are SQL window functions that evaluate partitioned datasets and assign rankings based on an `ORDER BY` specification:
- **Tied Values:** Both functions assign the exact same rank to duplicate values.
- **Subsequent Values:**
  - `RANK()` leaves gaps (skips numbers) in the ranking sequence. If two rows share rank 1, the next distinct row receives rank 3 (`1, 1, 3, 4`). The rank equals $1 + (	ext{count of strictly preceding rows})$.
  - `DENSE_RANK()` does **not** leave gaps. If two rows share rank 1, the next distinct row receives rank 2 (`1, 1, 2, 3`).

#### 2. Concrete Example (Surat City)
Consider four restaurants in Surat with their respective revenues:
- Restaurant A: ₹ 1,50,000
- Restaurant B: ₹ 1,50,000 (Tied with A)
- Restaurant C: ₹ 1,20,000
- Restaurant D: ₹ 90,000

| Restaurant | Revenue | `RANK()` | `DENSE_RANK()` | `ROW_NUMBER()` (Arbitrary) |
| :--- | :--- | :---: | :---: | :---: |
| Restaurant A | ₹ 1,50,000 | **1** | **1** | 1 |
| Restaurant B | ₹ 1,50,000 | **1** | **1** | 2 |
| Restaurant C | ₹ 1,20,000 | **3** | **2** | 3 |
| Restaurant D | ₹ 90,000 | **4** | **3** | 4 |

#### 3. Practical Impact on the Product Team's Report & Business Choice
Suppose the business query filters for `WHERE ranking_col <= 3`:
- **Impact of `RANK()`:**
  - Filtering `WHERE rnk <= 3` returns Restaurant A (1), Restaurant B (1), and Restaurant C (3).
  - Exactly 3 restaurants are returned, but rank 2 is completely missing from the report, which can confuse non-technical business stakeholders. Furthermore, if the tie occurred at rank 3 (e.g., C and D tied at ₹ 1,20,000), `WHERE rnk <= 3` would return 4 restaurants.
- **Impact of `DENSE_RANK()`:**
  - Filtering `WHERE dense_rnk <= 3` returns Restaurant A (1), Restaurant B (1), Restaurant C (2), and Restaurant D (3).
  - 4 restaurants are returned because the filter captures the top 3 **distinct performance tiers** (Top 3 revenue levels).
- **Recommendation:**
  - If the product team's requirement is **"Recognize all partners reaching the top 3 revenue performance brackets"**, choose **`DENSE_RANK()`**.
  - If the requirement is a **strict UI slot limitation** (e.g., an app homepage banner with room for exactly 3 restaurant cards), neither `RANK()` nor `DENSE_RANK()` is safe. In that case, use **`ROW_NUMBER()`** with an explicit secondary deterministic tie-breaker (e.g., `ORDER BY revenue DESC, rating DESC, total_orders DESC`).

---

## Scenario S5: CRM Tiering & Short-Circuit CASE WHEN Logic

### Scenario Overview
You are writing a CRM query for a food delivery startup. The customer success team wants each customer labelled as 'Platinum', 'Gold', or 'Standard' based on total lifetime spend — above Rs 5,000, between Rs 2,000 and Rs 5,000, and below Rs 2,000 respectively — directly in the query output without creating a new table.

### Question
> Explain how you would use `CASE WHEN` to generate this classification column. If a customer's total spend is exactly Rs 5,000, which tier will they fall into, and how does the order of your `WHEN` conditions control that outcome?

### Technical Explanation & SQL Solution

#### 1. SQL Query Implementation
```sql
SELECT 
    c.customer_id,
    c.customer_name,
    COALESCE(SUM(o.order_amount), 0) AS total_lifetime_spend,
    CASE 
        WHEN SUM(o.order_amount) > 5000 THEN 'Platinum'
        WHEN SUM(o.order_amount) >= 2000 THEN 'Gold'
        ELSE 'Standard'
    END AS customer_tier
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_lifetime_spend DESC;
```

#### 2. Tier Assignment for Spend of Exactly Rs 5,000
- **Business Definition:**
  - 'Platinum': Spend strictly *above* Rs 5,000 (`spend > 5000`)
  - 'Gold': Spend *between* Rs 2,000 and Rs 5,000 inclusive (`2000 <= spend <= 5000`)
  - 'Standard': Spend strictly *below* Rs 2,000 (`spend < 2000`)
- **Evaluation for ₹ 5,000:**
  1. Condition 1: `WHEN SUM(order_amount) > 5000` is evaluated. Because `5000 > 5000` is **FALSE**, execution advances to the next branch.
  2. Condition 2: `WHEN SUM(order_amount) >= 2000` is evaluated. Because `5000 >= 2000` is **TRUE**, the expression returns **'Gold'**.
  Therefore, a customer with exactly Rs 5,000 spend falls into the **'Gold'** tier.

#### 3. How the Order of WHEN Conditions Controls the Outcome
SQL's `CASE` expression implements **short-circuit sequential evaluation**:
- Conditions are tested top-to-bottom in the order specified.
- The engine halts evaluation at the **first** condition that evaluates to `TRUE` and immediately returns its `THEN` result, skipping all subsequent branches.
- **Consequence of Incorrect Ordering:**  
  If an analyst inadvertently orders conditions from lowest to highest:
  ```sql
  -- INCORRECT ORDER: LOGICAL BUG!
  CASE 
      WHEN total_spend >= 2000 THEN 'Gold'
      WHEN total_spend > 5000 THEN 'Platinum'  -- DEAD CODE! NEVER REACHED!
      ELSE 'Standard'
  END
  ```
  For a high-roller customer who spent ₹ 25,000, `25000 >= 2000` evaluates to `TRUE` in the very first branch. The customer is incorrectly assigned to 'Gold', and the 'Platinum' branch is never reached!  
  Hence, conditions must always be structured from the most restrictive criteria to the least restrictive criteria.

---

## Scenario S6: Database Engine Internals, Indexing & Workload Trade-offs

### Scenario Overview
You are optimising a slow-running analytics query for a food delivery platform. The query joins four large tables and applies a `GROUP BY` across 10 million rows, taking over 30 seconds. A colleague suggests adding an index on the `JOIN` column used most frequently.

### Question
> Explain what a database index does at the engine level and why it would speed up this specific query. Are there scenarios where adding an index could actually hurt performance? What trade-off must you evaluate before indexing every column in a large table?

### Technical Explanation & Engine Mechanics

#### 1. What a Database Index Does at the Engine Level
In MySQL (specifically the InnoDB storage engine):
- **Clustered Index vs Secondary Index:** InnoDB tables are organized as B+ Trees clustered around the Primary Key. Secondary indexes are separate B+ Tree structures whose leaf nodes store the indexed key values and the corresponding primary key pointer.
- **Without an Index (Full Table Scan):**  
  To perform joins across unindexed columns, MySQL must execute a Full Table Scan (`ALL` in `EXPLAIN`). The engine reads every 16KB data page from disk into the InnoDB Buffer Pool, evaluating all 10 million rows. For 4 joined tables, MySQL falls back to Hash Joins or Block Nested Loop (BNL) joins, requiring vast memory allocations, temporary disk spillover, and millions of CPU comparisons ($O(N)$ scanning complexity).
- **With a B+ Tree Index (Index Lookup):**  
  A B+ Tree keeps key values sorted in a balanced tree hierarchy. Searching for matching keys requires traversing root and intermediate pages down to leaf pages with $O(\log N)$ logarithmic complexity (typically 3 to 4 logical I/O page reads for 10 million rows). Join evaluation transforms from `ALL` to `eq_ref` or `ref`, allowing the query engine to seek directly to the matching row IDs and bypassing millions of irrelevant records. This reduces query runtime from 30+ seconds down to milliseconds.

#### 2. Scenarios Where Adding an Index Could Hurt Performance
1. **Low Cardinality (Low Selectivity) Columns:**  
   If an index is created on a column with few distinct values (e.g., `order_status` with values 'Delivered' vs 'Cancelled', or `gender`), where a single value matches 50% or 80% of 10 million rows, using an index requires random I/O leaf reads followed by clustered index lookups (Bookmark Lookups). The optimizer often finds that a sequential Full Table Scan is significantly faster than bouncing through random secondary index pointers.
2. **Write-Heavy OLTP Workloads:**  
   Indexes accelerate reads (`SELECT`), but they impose an immediate write penalty on every `INSERT`, `UPDATE`, and `DELETE`. Each write requires the engine to locate, update, and rebalance multiple B+ Trees, perform node splits, and log extra redo/undo entries.
3. **Query Optimizer Degradation:**  
   An overabundance of indexes forces the Cost-Based Optimizer (CBO) to analyze hundreds of execution plan permutations, increasing compilation overhead and occasionally choosing sub-optimal execution paths.

#### 3. Key Trade-Offs to Evaluate Before Indexing Every Column
1. **Storage Footprint vs Memory Budget:**  
   Secondary index B+ Trees consume substantial disk space. In tables with tens of millions of rows, secondary indexes frequently exceed the raw table size itself. More critically, index pages compete for space in the finite **InnoDB Buffer Pool** (RAM), evicting cached table pages and degrading overall server throughput.
2. **DML Latency vs Query Latency:**  
   Balancing high-throughput data ingestion (e.g., thousands of food orders per minute) against analytical reporting needs.
3. **Covering Index Optimization:**  
   Instead of blindly indexing individual columns, build composite or covering indexes (e.g., `INDEX idx_city_status_rev (city, order_status, order_amount)`) that allow the query engine to satisfy joins, filters, and aggregations directly out of the index tree without touching the base table clustered index (Index-Only Scans).

---
