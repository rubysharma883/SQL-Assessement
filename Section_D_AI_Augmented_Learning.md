# Section D: AI-Augmented Learning — Evaluation & Debugging Report

**Program:** Data Analytics  
**Course Module:** Module 4 – SQL for Data Analytics  
**Assessment Code:** M4-A1  

---

## 1. The Exact Prompt Given to the AI Tool

```text
Write a MySQL query to find the top 3 delivery agents per city for a food delivery platform, ranked by number of completed orders, using window functions. Include a column showing each agent's average delivery time alongside their rank. Filter the result to include only agents who have completed more than 5 orders in that city. Return the final output sorted by city name alphabetically, then by rank ascending.
```

---

## 2. Comparison: AI's Original Query vs. Human Corrected Query

### A. The AI's Original Query (Flawed)
```sql
WITH agent_ranks AS (
    SELECT 
        da.city,
        da.agent_id,
        da.agent_name,
        COUNT(o.order_id) AS completed_orders,
        AVG(o.delivery_time_mins) AS avg_delivery_time,
        DENSE_RANK() OVER (PARTITION BY da.city ORDER BY COUNT(o.order_id) DESC) AS agent_rank
    FROM cap_delivery_agents da
    LEFT JOIN cap_orders o ON da.agent_id = o.agent_id
    GROUP BY da.city, da.agent_id, da.agent_name
)
SELECT 
    city,
    agent_id,
    agent_name,
    completed_orders,
    ROUND(avg_delivery_time, 2) AS avg_delivery_time,
    agent_rank
FROM agent_ranks
WHERE agent_rank <= 3 AND completed_orders > 5
ORDER BY city ASC, agent_rank ASC;
```

### B. Human Corrected Query (Robust & Production-Ready)
```sql
WITH qualifying_agents AS (
    -- Step 1: Pre-aggregate and filter qualifying agents BEFORE ranking
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
    -- Step 2: Rank ONLY agents who satisfied the > 5 orders threshold
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
-- Step 3: Extract top 3 and sort as required
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
```

---

## 3. Explanatory Note on Changes Made & Why AI's Version Needed It

> **Technical Change Note:**  
> The AI applied the `completed_orders > 5` filter **after** window ranking instead of **before** it, which corrupted the ranking sequence whenever low-volume agents took ranks 1–3 and displaced legitimate high-volume candidates. Furthermore, the AI used an unfiltered `COUNT(o.order_id)` and `AVG()` without checking `order_status = 'Delivered'` or `delivery_time_mins IS NOT NULL`, erroneously counting cancelled deliveries and skewing delivery speed averages. I restructured the query into a two-stage CTE that enforces data hygiene and pre-filters qualifying agents with `HAVING COUNT > 5` before computing `DENSE_RANK()`, while adding a speed tie-breaker (`avg_delivery_time ASC`) to guarantee deterministic results.

---
