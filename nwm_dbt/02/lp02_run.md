# Instructor Pack — **“What dbt Is Doing When You Call `dbt run`”**  
*(Retail-Transactions Pipeline)*  

This single file contains **everything** you need: the big-picture diagram, full code snippets, commands, and talking points. Copy it into the course repo (`docs/lesson_dbt_run.md`) or paste directly into your slides.

---

## 0  Prerequisites

| Item | Value |
|------|-------|
| **Raw table** | `DBT_DEMO_05042026.PUBLIC.RETAIL_TRANSACTIONS` |
| **Student target schema** | `DBT_DEMO_05042026.STUDENT_<STUDENT>` |
| **Role grants** | Provisioning guide (rev-2025-05-22) applied |
| **Project root** | `dbtdemo05042025/` |

---

## 1  Mental Model Diagram

> Copy-paste into a slide, or present live in the terminal with `echo`.

```

```
      ┌───────────────┐
      │  parse files  │  (dbt parse)
      └──────┬────────┘
             │
      ┌──────▼────────┐
      │ build DAG &   │
      │   node graph  │
      └──────┬────────┘
             │
      ┌──────▼────────┐
      │ compile Jinja │  (dbt compile)
      │  → raw SQL    │
      └──────┬────────┘
             │
      ┌──────▼────────┐
      │ execute SQL   │  (dbt run)
      │ in DAG order  │
      └──────┬────────┘
             │
      ┌──────▼────────┐
      │ run tests &   │  (dbt test)   *
      │ source checks │  (inside dbt build)
      └──────┬────────┘
             │
      ┌──────▼────────┐
      │ write docs &  │  (dbt docs generate)
      │ JSON artifacts│
      └───────────────┘
```

* dbt **build** = run + test (+ seed/snapshot) for selected nodes

````

---

## 2  Full Code Bundle

> Place these files exactly; commit before class.

### 2.1 `models/sources/source.yml`

```yaml
version: 2

sources:
  - name: retail
    database: DBT_DEMO_05042026
    schema: PUBLIC
    tables:
      - name: retail_transactions
        description: Raw retail CSV upload
        loaded_at_field: order_date
        freshness:
          warn_after:  {count: 24, period: hour}
          error_after: {count: 48, period: hour}
        columns:
          - name: order_id
            tests: [not_null, unique]
          - name: customer_id
            tests: [not_null]
          - name: order_status
            tests: [not_null]
````

### 2.2 `models/staging/stg_transactions.sql`

```sql
{{ config(materialized='table', tags=['retail']) }}

WITH src AS (

    SELECT *
    FROM {{ source('retail', 'retail_transactions') }}

)

SELECT
    order_id,
    TO_DATE(order_date)                                                   AS order_date,
    customer_id,
    INITCAP(TRIM(product_category))                                       AS product_category,
    product_id,
    quantity::INT                                                         AS quantity,
    unit_price::NUMBER(10,2)                                              AS unit_price,
    COALESCE(discount_pct, 0)::NUMBER(5,2)                                AS discount_pct,
    shipping_cost::NUMBER(10,2)                                           AS shipping_cost,
    UPPER(TRIM(order_status))                                             AS order_status,
    country,
    city,
    (quantity * unit_price * (1 - COALESCE(discount_pct,0))) + shipping_cost
                                                                          AS total_amount
FROM src;
```

### 2.3 `models/marts/fct_daily_category_sales.sql`

```sql
{{ config(materialized='table', tags=['retail']) }}

SELECT
    order_date,
    product_category,
    SUM(total_amount) AS total_sales,
    SUM(quantity)     AS total_units
FROM {{ ref('stg_transactions') }}
GROUP BY order_date, product_category;
```

### 2.4 `models/marts/fct_monthly_top_customers.sql`

```sql
{{ config(materialized='table', tags=['retail']) }}

WITH monthly AS (
    SELECT
        TO_CHAR(order_date,'YYYY-MM') AS month,
        customer_id,
        SUM(total_amount)            AS total_spent
    FROM {{ ref('stg_transactions') }}
    GROUP BY 1,2
)

SELECT *
FROM (
    SELECT
        month,
        customer_id,
        total_spent,
        ROW_NUMBER() OVER (PARTITION BY month ORDER BY total_spent DESC) AS rn
    FROM monthly
)
WHERE rn <= 10;
```

### 2.5 `models/marts/schema.yml`

```yaml
version: 2

models:
  - name: stg_transactions
    description: Cleaned retail transactions
    columns:
      - name: order_id
        tests: [not_null, unique]
      - name: total_amount
        tests: [not_null]

  - name: fct_daily_category_sales
    description: Daily revenue and units by category

  - name: fct_monthly_top_customers
    description: Top-spending customers per month
```

### 2.6 (Optional) `selectors.yml`

```yaml
selectors:
  - name: retail_pipeline
    definition:
      union:
        - source: retail.retail_transactions
        - tag: retail+
```

---

## 3  Live Command Script (copy to your run-sheet)

```bash
# Sanity check: what will run?
dbt ls --select tag:retail+ source:retail.retail_transactions

# 1. Parse only – build graph, no SQL
dbt parse

# 2. Compile only – render Jinja to static SQL
dbt compile --select tag:retail+

# 3. Build entire retail pipeline (source freshness + tests + models)
dbt build --select tag:retail+ source:retail.retail_transactions

# 4. Inspect Snowflake tables
#    (run these in Snowsight)
SELECT COUNT(*) FROM DBT_DEMO_05042026.STUDENT_<STUDENT>.STG_TRANSACTIONS;
SELECT COUNT(*) FROM DBT_DEMO_05042026.STUDENT_<STUDENT>.FCT_DAILY_CATEGORY_SALES;
SELECT COUNT(*) FROM DBT_DEMO_05042026.STUDENT_<STUDENT>.FCT_MONTHLY_TOP_CUSTOMERS;

# 5. Generate & open docs
dbt docs generate
dbt docs serve  # opens http://localhost:8080
```

---

## 4  Console-to-Concept Call-outs

| Console Phase                          | Verbal Explanation                                                                             |
| -------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `Found X models, Y tests…` (dbt parse) | “dbt just read every file and built a dependency graph in memory.”                             |
| `Writing compiled SQL…` (dbt compile)  | “Jinja resolved: `{{ ref('stg_transactions') }}` became `STUDENT_<STUDENT>.STG_TRANSACTIONS`.” |
| `START sql table model …` lines        | “dbt walks the DAG topologically, no manual ordering required.”                                |
| `START test …` after models            | “Schema tests run automatically; failures fail the build.”                                     |
| Build summary + run\_results.json      | “Artifacts are machine-readable for CI or observability.”                                      |

---

## 5  Juxtaposition Slide (Manual vs dbt)

> Use a two-column layout with the code snippets below.

```
Manual SQL                    | 1-Command dbt
------------------------------|---------------------------------
-- CLEAN ---------------------| dbt build --select tag:retail+
CREATE OR REPLACE TABLE       |
  STG_TRANSACTIONS AS …       |
                              | Source → stg → marts → tests
-- DAILY SALES ---------------|                             
CREATE OR REPLACE TABLE       | Lineage docs auto-generated
  DAILY_CATEGORY_SALES AS …   |
                              | Unique/not_null tests auto-run
-- TOP CUSTOMERS -------------| One schedule instead of Cron x3
CREATE OR REPLACE TABLE …     |
```

---

## 6  Troubleshooting Cheats

| Symptom                               | Fix                                                      |
| ------------------------------------- | -------------------------------------------------------- |
| `Schema … not authorized`             | Re-apply SELECT + USAGE grants on `PUBLIC`.              |
| `Compilation Error: source not found` | Correct database / schema / table names in `source.yml`. |
| Tests FAIL due to duplicates          | Good! Demo value of tests; fix data then re-run.         |

---

## 7  Wrap-Up Talking Points

1. **dbt run** = compile + execute + quality gate, all driven by the DAG.
2. **ref()/source()** decouple SQL from environment, enabling per-student schemas.
3. **Artifacts & docs** make lineage, performance, and CI first-class citizens.
4. **Single command** replaces upload wizard, three SQL scripts, QC queries, lineage diagram, and scheduler wiring.

Deliver this lesson, run the commands live, and your students will **see** and **feel** the lift dbt provides over manual workflows.

