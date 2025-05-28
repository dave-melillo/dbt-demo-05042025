
## 🧪 Adding Tests in dbt: Final Lesson Plan + Precise Execution Guide

---

### 🎯 Goal

Teach students how to add and run tests in dbt, including:

1. **Source-level tests**
2. **Model-level generic tests**
3. **Singular tests**
4. **Custom tests (macros)**
5. ✅ How to run tests **selectively**

---

## 1️⃣ Source-Level Tests ✅

**Use Case**: Ensure `customer_id` is never null or duplicated in the source data.

### 📍 File to edit: `models/sources.yml`

```yaml
version: 2

sources:
  - name: pagila
    database: pagila
    schema: public
    tables:
      - name: customer
        columns:
          - name: customer_id
            tests:
              - not_null
              - unique
```

### ▶️ Run just this source's tests:

```bash
dbt test --select source:pagila.customer
```

---

## 2️⃣ Model-Level Generic Tests

Assuming you later create a model like `customer_summary`.

### 📍 File: `models/customer_summary.sql`

```sql
{{ config(materialized='view') }}

SELECT
  customer_id,
  SUM(amount) AS total_revenue
FROM {{ source('pagila', 'payment') }}
GROUP BY 1
```

### 📍 File: `models/customer_summary.yml`

```yaml
version: 2

models:
  - name: customer_summary
    columns:
      - name: customer_id
        tests:
          - not_null
          - unique
      - name: total_revenue
        tests:
          - not_null
```

### ▶️ Run tests for just this model:

```bash
dbt test --select customer_summary
```

---

## 3️⃣ Singular Tests

**Use Case**: Business rule — no negative revenue.

### 📍 File: `tests/no_negative_revenue.sql`

```sql
SELECT *
FROM {{ ref('customer_summary') }}
WHERE total_revenue < 0
```

### ▶️ Run:

```bash
dbt test --select customer_summary
```

---

## 4️⃣ Custom Generic Tests via Macros

### 📍 File: `macros/not_zero.sql`

```sql
{% test not_zero(model, column_name) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} = 0
{% endtest %}
```

### 📍 In `customer_summary.yml`

```yaml
- name: total_revenue
  tests:
    - not_zero
```

### ▶️ Run just this test:

```bash
dbt test --select customer_summary.total_revenue
```

---

## 🧭 How to Run Just Specific Tests

| Command                                    | What It Does                           |
| ------------------------------------------ | -------------------------------------- |
| `dbt test`                                 | Run **all tests**                      |
| `dbt test --select source:pagila.customer` | Just tests on a **source**             |
| `dbt test --select my_model`               | Tests for one **model**                |
| `dbt test --select model.column_name`      | Just tests for **one column**          |
| `dbt test --select tag:<your_tag>`         | Run all tests on models with a **tag** |

---
