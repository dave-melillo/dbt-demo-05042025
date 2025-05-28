

## 🎓 LESSON PLAN: Writing a Custom Schema Test

### **Objective**

Students will learn how to:

* Add schema-level tests to a dbt model
* Create and register **custom tests**
* Use `severity: warn` to surface issues without failing pipelines

---

### **Model Under Test: `customer_summary`**

**File: `models/marts/customer_summary.sql`**

```sql
{{ config(materialized='view') }}

SELECT
  p.customer_id,
  c.email, 
  SUM(p.amount) AS total_revenue
FROM {{ source('pagila', 'payment') }} as p
LEFT JOIN {{ source('pagila', 'customer') }}  as c 
  ON p.customer_id = c.customer_id 
GROUP BY 1,2
```

---

### **Custom Tests Created**

**1. `customer_id_positive.sql`**

```sql
{% test customer_id_positive(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} <= 0
{% endtest %}
```

**2. `email_format_check.sql`**

```sql
{% test email_format_check(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} NOT LIKE '%@%.%'
{% endtest %}
```

**3. `revenue_not_negative.sql`**

```sql
{% test revenue_not_negative(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} < 0
{% endtest %}
```

Place all three in `macros/tests/`.

---

### **Schema Configuration**

**File: `models/marts/customer_summary/schema.yml`**

```yaml
version: 2

models:
  - name: customer_summary
    columns:
      - name: customer_id
        tests:
          - not_null
          - unique
          - customer_id_positive:
              severity: warn
      - name: total_revenue
        tests:
          - not_null
          - not_zero
          - revenue_not_negative:
              severity: warn
      - name: email
        tests:
          - email_format_check:
              severity: warn
```

---

### **How to Run These Tests**

From your terminal:

```bash
# Run all tests for the model
dbt test --select customer_summary
```

---

### **Why We Use `severity: warn`**

* Prevents the test from failing the pipeline
* Useful for **data quality alerts** that don’t need to block builds
* Encourages safe exploration in dev environments

---

### **Optional Extension**

Once more columns are added (e.g., `discount_percent`, `first_name`, etc.), tests can easily be extended without modifying the existing ones.

