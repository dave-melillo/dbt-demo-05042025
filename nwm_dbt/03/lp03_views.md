# Instructor Pack — **dbt Model Configurations: Tables vs Views (Snowflake)**  
*(Focuses only on table vs view materializations using the retail pipeline)*

Copy each **block** into its own Google-Slides page (title + body).  
All code snippets are ready to drop into the project repo.

---

## Slide 1 – Tables vs Views in dbt (Snowflake context)

| Materialization | Creates in Snowflake | When to choose | Trade-offs |
|-----------------|----------------------|----------------|------------|
| **Table** *(default)* | `CREATE OR REPLACE TABLE` | Fact/dim tables queried often; large aggregations that shouldn’t recalc each query | Uses storage, rebuild time on full refresh |
| **View** | `CREATE OR REPLACE VIEW` | Lightweight staging; needs freshest upstream data each time | Each query re-runs underlying SQL; can cascade and slow queries |

> **Snowflake note:** Warehousing cost comes from **query time**, not storage.  
> A long view chain can be **more** expensive than a one-time table build.

---

## Slide 3 – Staging View Example (`models/staging/stg_transactions_v.sql`)

```sql
{{ config(materialized='view', tags=['retail']) }}

WITH src AS (

    SELECT *
    FROM {{ source('retail', 'retail_transactions') }}

)

SELECT
    order_id,
    TO_DATE(order_date)                        AS order_date,
    customer_id,
    INITCAP(TRIM(product_category))            AS product_category,
    product_id,
    quantity::INT                              AS quantity,
    unit_price::NUMBER(10,2)                   AS unit_price,
    COALESCE(discount_pct, 0)::NUMBER(5,2)     AS discount_pct,
    shipping_cost::NUMBER(10,2)                AS shipping_cost,
    UPPER(TRIM(order_status))                  AS order_status,
    country,
    city,
    (quantity * unit_price * (1 - COALESCE(discount_pct,0))) + shipping_cost
                                               AS total_amount
FROM src;
```

*Why view?*
Staging is mostly column cleanup and type-casting. A view avoids extra storage and always reflects the latest raw data.

---


## Slide 6 – Snowflake-Specific Tips

* **Transience for temp tables**

  ```sql
  {{ config(materialized='table', transient=true) }}
  ```

  Frees you from Fail-Safe fees. Use transient tables for staging if disk cost important:

* **Clustering (optional)**

  ```sql
  {{ config(materialized='table', cluster_by=['order_date']) }}
  ```

  Boosts pruning on very large marts.

* **Warehouse usage**
  Views **still** compute; deep chains may cost more credits than tables.

---

## Slide 7 – Live Demo Commands (Instructor)

```bash
# Build staging view only
dbt run --select stg_transactions_v

# Verify view vs table in Snowflake
SHOW VIEWS  LIKE 'STG_TRANSACTIONS'    IN SCHEMA STUDENT_<STUDENT>;
SHOW TABLES LIKE 'FCT_DAILY_CATEGORY_SALES' IN SCHEMA STUDENT_<STUDENT>;

```

---

## Slide 8 – Knowledge Check (ask the class)

1. Why might a long chain of views increase query cost in Snowflake?
2. When would you flip a staging **view** to a **table**?
3. If a mart table is rebuilt nightly, how do you ensure yesterday’s queries still succeed? *(Hint: transient + `create or replace`)*

Use this streamlined set to keep focus strictly on **table vs view** while still giving Snowflake-specific context and runnable code.

```

