
# Lesson Plan: Manual Workflow vs dbt — Retail Transactions Demo

This lesson lets students feel the pain of doing transformations manually in Snowflake, then sets you up to highlight how dbt eliminates that friction.

---

## 1  Demo Dataset

| File | Rows | Purpose |
|------|------|---------|
| **[`retail_transactions.csv`](sandbox:/mnt/data/retail_transactions.csv)** | 1 000 | Messy transaction-level data with mixed casing, null discounts, inconsistent statuses, etc., ideal for cleaning, aggregating, and contrasting manual SQL against dbt models. |

> Upload this file through **Snowsight → Load Data**; Snowflake takes care of staging for you.

---

## 2  Manual Workflow (Snowsight GUI)

### 2.1 Load Raw Data

1. Choose or create database `DBT_DEMO`, schema `RAW`.
2. **Load Data** → **Upload a file** → select `retail_transactions.csv`.
3. Accept column types (or tweak), name the table **`TRANSACTIONS_RAW`**, click **Load**.

> Result: `DBT_DEMO.RAW.TRANSACTIONS_RAW` now holds raw rows.

---

### 2.2 Create Working Schemas

```sql
-- Choose one style — IF NOT EXISTS shown here
CREATE SCHEMA IF NOT EXISTS STG;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;
````

---

### 2.3 Clean & Standardize

```sql
CREATE OR REPLACE TABLE STG.TRANSACTIONS_CLEAN AS
SELECT
    ORDER_ID,
    TO_DATE(ORDER_DATE)                                                   AS ORDER_DATE,
    CUSTOMER_ID,
    INITCAP(TRIM(PRODUCT_CATEGORY))                                       AS PRODUCT_CATEGORY,
    PRODUCT_ID,
    QUANTITY::INT                                                         AS QUANTITY,
    UNIT_PRICE::NUMBER(10,2)                                              AS UNIT_PRICE,
    COALESCE(DISCOUNT_PCT, 0)::NUMBER(5,2)                                AS DISCOUNT_PCT,
    SHIPPING_COST::NUMBER(10,2)                                           AS SHIPPING_COST,
    UPPER(TRIM(ORDER_STATUS))                                             AS ORDER_STATUS,
    COUNTRY,
    CITY,
    (QUANTITY * UNIT_PRICE * (1 - COALESCE(DISCOUNT_PCT,0))) + SHIPPING_COST
                                                                          AS TOTAL_AMOUNT
FROM RAW.TRANSACTIONS_RAW;
```

---

### 2.4 Daily Sales by Category

```sql
CREATE OR REPLACE TABLE ANALYTICS.DAILY_CATEGORY_SALES AS
SELECT
    ORDER_DATE,
    PRODUCT_CATEGORY,
    SUM(TOTAL_AMOUNT) AS TOTAL_SALES,
    SUM(QUANTITY)     AS TOTAL_UNITS
FROM STG.TRANSACTIONS_CLEAN
GROUP BY ORDER_DATE, PRODUCT_CATEGORY;
```

---

### 2.5 Monthly Top-10 Customers

```sql
CREATE OR REPLACE TABLE ANALYTICS.MONTHLY_TOP_CUSTOMERS AS
WITH MONTHLY AS (
    SELECT
        TO_CHAR(ORDER_DATE,'YYYY-MM') AS MONTH,
        CUSTOMER_ID,
        SUM(TOTAL_AMOUNT)            AS TOTAL_SPENT
    FROM STG.TRANSACTIONS_CLEAN
    GROUP BY 1,2
)
SELECT *
FROM (
    SELECT
        MONTH,
        CUSTOMER_ID,
        TOTAL_SPENT,
        ROW_NUMBER() OVER (PARTITION BY MONTH ORDER BY TOTAL_SPENT DESC) AS RN
    FROM MONTHLY
)
WHERE RN <= 10;
```

---

## 3  Pain Points of the Manual Approach

| Step              | Manual Reality                   | Pain                                   |
| ----------------- | -------------------------------- | -------------------------------------- |
| **Data load**     | GUI upload wizard daily          | Click-heavy, easy to mis-label columns |
| **Transforms**    | Paste/run each script in order   | Miss dependencies, no retry logic      |
| **Orchestration** | Cron, Airflow, or “click-to-run” | Extra infra or human time              |
| **Lineage**       | Draw diagrams by hand            | Quickly outdated                       |
| **Docs**          | Confluence/Google Docs           | Rarely maintained                      |
| **Testing**       | Ad-hoc SQL checks                | Often skipped                          |
| **Logging**       | Manual inserts or rely on UI     | Limited audit trail                    |

---

## 4  Slide Deck Outline

| # | Slide Title          | Key Talking Points                                                                                       |
| - | -------------------- | -------------------------------------------------------------------------------------------------------- |
| 1 | Manual Data Load     | Snowsight wizard, RAW table created                                                                      |
| 2 | Cleanup & Enrichment | `TRANSACTIONS_CLEAN` — casting, standardization                                                          |
| 3 | Aggregations         | Daily sales, monthly top customers; quick SELECT demo                                                    |
| 4 | Pain Points → dbt    | Table above; segue to “`dbt seed && dbt run` gives you docs, tests, lineage, CI, scheduling in one shot” |

---

## 5  Bridge to dbt (talking points)

* **Seeds** — drop the CSV in `data/`, run `dbt seed`; same everywhere, no GUI clicks.
* **Dependencies** — `{{ ref('transactions_clean') }}` builds the DAG automatically.
* **Tests** — add `unique`, `not_null` in `schema.yml`; failures surface immediately.
* **Docs & lineage** — `dbt docs generate` → interactive website in seconds.
* **Orchestration** — schedule one job in dbt Cloud; artifacts, logging, CI handled.

Use this manual walk-through first, let students feel the toil, then show the dbt version for contrast.

---
