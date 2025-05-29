

## 🔁 **Example 1: Append-Only Incremental Model**

**Use case**: Payments are immutable — we just want to add new ones.

### `models/incremental/incr1_append_only.sql`

```sql
{{ config(
    materialized='incremental'
) }}

SELECT
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date
FROM {{ source('pagila', 'payment') }}

{% if is_incremental() %}
WHERE payment_date > (SELECT MAX(payment_date) FROM {{ this }})
{% endif %}
```

**🧪 Test it:**

```sql
-- Initial data
INSERT INTO pagila.payment VALUES 
(1, 101, 1, 1001, 3.99, '2024-12-01'),
(2, 102, 1, 1002, 4.99, '2024-12-02');

-- Then run:
dbt run --select incr1_append_only

-- Add new rows
INSERT INTO pagila.payment VALUES 
(3, 103, 2, 1003, 6.99, '2024-12-03');

dbt run --select incr1_append_only
```

---

## 🔁 **Example 2: Deduplicate via Unique Key (New + Updated Rows)**

**Use case**: Payments can be corrected/updated — dedup by `payment_id`.

### `models/incremental/incr2_upserts.sql`

```sql
{{ config(
    materialized='incremental',
    unique_key='payment_id'
) }}

SELECT
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date
FROM {{ source('pagila', 'payment') }}

{% if is_incremental() %}
WHERE payment_date >= (
    SELECT COALESCE(MAX(payment_date), '1900-01-01') FROM {{ this }}
)
{% endif %}
```

**🧪 Test it:**

```sql
-- Initial
INSERT INTO pagila.payment VALUES (10, 200, 2, 4000, 7.99, '2024-12-01');
dbt run --select incr2_upserts

-- Simulate an update to same payment_id
DELETE FROM pagila.payment WHERE payment_id = 10;
INSERT INTO pagila.payment VALUES (10, 200, 2, 4000, 9.99, '2024-12-02');

dbt run --select incr2_upserts
```

---

## 🔁 **Example 3: Windowed Daily Aggregate with `unique_key`**

**Use case**: Daily rollup of revenue — refresh any days with new/late data.

### `models/incremental/incr3_daily_agg.sql`

```sql
{{ config(
    materialized='incremental',
    unique_key='payment_day'
) }}

SELECT
    DATE_TRUNC('day', payment_date) AS payment_day,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_revenue
FROM {{ source('pagila', 'payment') }}

{% if is_incremental() %}
WHERE payment_date >= (
    SELECT COALESCE(MAX(payment_day), '1900-01-01') FROM {{ this }}
)
{% endif %}

GROUP BY 1
```

**🧪 Test it:**

```sql
-- Initial
INSERT INTO pagila.payment VALUES (20, 300, 1, 5000, 5.00, '2024-12-01');
dbt run --select incr3_daily_agg

-- New same-day row
INSERT INTO pagila.payment VALUES (21, 301, 1, 5001, 6.00, '2024-12-01');
dbt run --select incr3_daily_agg  -- will reprocess 2024-12-01
```

---

## ✅ Summary of Use Cases

| Model Name          | Use Case                               | Logic Style               | Key Feature             |
| ------------------- | -------------------------------------- | ------------------------- | ----------------------- |
| `incr1_append_only` | Append-only immutable data             | Basic filter by timestamp | Fastest, no deduping    |
| `incr2_upserts`     | Insert/update records with stable keys | Dedup using `unique_key`  | Supports corrections    |
| `incr3_daily_agg`   | Aggregates that change with late data  | Recompute by day          | Avoid duplicate rollups |

