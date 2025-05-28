# 🧪 Lab 1 — Executive Reporting with dbt + Pagila

**Use case:** Report monthly revenue per staff member in flexible, reusable marts

---

## 💼 Scenario

You’ve been asked to create a dbt-powered reporting pipeline for executives who want **monthly revenue and rental metrics per staff member**. They want to:

* Filter by staff (e.g., Mike or Jon)
* Compare performance over time
* Reuse logic in future dashboards

---

## 🎯 Objective

Build one central staging model, and from it generate specialized marts that:

1. Filter to Mike Hillyer
2. Filter to Jon Stephens
3. Compare both in a single, pivoted table
4. (Extra credit) Include total rentals along with revenue

---

## 🧱 Model Breakdown (with instructions)

---

### ✅ 1. `stg_staff_monthly_revenue.sql`

**Path:** `models/staging/stg_staff_monthly_revenue.sql`

```sql
{{ config(materialized='view', tags=['lab1']) }}

SELECT
  s.staff_id,
  s.first_name,
  s.last_name,
  DATE_TRUNC('month', p.payment_date) AS revenue_month,
  SUM(p.amount) AS total_revenue,
  COUNT(r.rental_id) AS total_rentals
FROM {{ source('pagila', 'payment') }} p
JOIN {{ source('pagila', 'rental') }} r ON p.rental_id = r.rental_id
JOIN {{ source('pagila', 'staff') }} s ON p.staff_id = s.staff_id
GROUP BY 1, 2, 3, 4
```

🛠 **Run it:**

```bash
dbt run --select stg_staff_monthly_revenue
```

---

### ✅ 2. `mart_mike_hillyer_revenue.sql`

**Path:** `models/marts/mart_mike_hillyer_revenue.sql`

```sql
{{ config(materialized='table', tags=['lab1']) }}

SELECT *
FROM {{ ref('stg_staff_monthly_revenue') }}
WHERE staff_id = 1
```

🛠 **Run it:**

```bash
dbt run --select mart_mike_hillyer_revenue
```

---

### ✅ 3. `mart_jon_stephens_revenue.sql`

**Path:** `models/marts/mart_jon_stephens_revenue.sql`

```sql
{{ config(materialized='table', tags=['lab1']) }}

SELECT *
FROM {{ ref('stg_staff_monthly_revenue') }}
WHERE staff_id = 2
```

🛠 **Run it:**

```bash
dbt run --select mart_jon_stephens_revenue
```

---

### ✅ 4. `mart_staff_comparison_pivoted.sql`

**Path:** `models/marts/mart_staff_comparison_pivoted.sql`

```sql
{{ config(materialized='table', tags=['lab1']) }}

WITH base AS (
  SELECT *
  FROM {{ ref('stg_staff_monthly_revenue') }}
  WHERE staff_id IN (1, 2)
)

SELECT
  revenue_month,
  MAX(CASE WHEN staff_id = 1 THEN total_revenue END) AS mike_revenue,
  MAX(CASE WHEN staff_id = 2 THEN total_revenue END) AS jon_revenue,
  MAX(CASE WHEN staff_id = 1 THEN total_rentals END) AS mike_rentals,
  MAX(CASE WHEN staff_id = 2 THEN total_rentals END) AS jon_rentals
FROM base
GROUP BY revenue_month
ORDER BY revenue_month
```

🛠 **Run it:**

```bash
dbt run --select mart_staff_comparison_pivoted
```

---

### 🏷 Run all Lab 1 models together

All models use the `tag: lab1`, so you can run or test them in one command:

```bash
dbt run --select tag:lab1
```

Or for docs/tests:

```bash
dbt build --select tag:lab1
```

---

## 📘 Bonus Tasks

### ✅ Freshness

Add this to your `sources.yml` under `payment`:

```yaml
loaded_at_field: payment_date
freshness:
  warn_after: {count: 12, period: hour}
  error_after: {count: 24, period: hour}
```

Then run:

```bash
dbt source freshness --select source:pagila.payment
```

You’ll see a failure — discuss **why** this matters in real pipelines.

---

### ✅ Docs

Create a file: `models/docs/lab1_docs.md`

```jinja
{% docs fct_staff_comparison_doc %}
This model pivots monthly revenue and rental count by staff member.

Great for comparing performance between Mike and Jon.
{% enddocs %}
```

In `schema.yml`:

```yaml
models:
  - name: mart_staff_comparison_pivoted
    description: "{{ doc('fct_staff_comparison_doc') }}"
```

Then:

```bash
dbt docs generate
dbt docs serve
```

---

## ✅ What to Submit (Student Checklist)

| Task                      | Description                 |
| ------------------------- | --------------------------- |
| ✅ Central staging model   | `stg_staff_monthly_revenue` |
| ✅ Staff #1 mart           | Mike                        |
| ✅ Staff #2 mart           | Jon                         |
| ✅ Pivoted comparison mart | Mike vs Jon                 |
| ✅ `ref()` usage           | In all marts                |
| ✅ Freshness test          | Defined and run             |
| ✅ Docs block              | Added + referenced          |
| ✅ Used tag\:lab1          | Yes                         |

