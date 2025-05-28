
## 🧠 Lesson Plan: Focusing on Code Readability in dbt

---

### 🎯 Why Focusing on Code Readability Matters (and how dbt enforces it)

#### 🧠 Conceptual Explanation

In traditional SQL development, **readability is often sacrificed** for brevity or perceived performance. But in dbt, **readability is a feature** — not a bonus.

dbt enforces a clean, modular SQL style through the use of **CTEs (Common Table Expressions)**. This reflects software engineering principles like:

* **Separation of concerns**
* **Modular architecture**
* **Named, testable functions**

This approach was first codified by Fishtown Analytics (creators of dbt), who promote the principle:

> “Each CTE should represent a single transformation step.”

---

### 🏗️ How dbt Leverages CTEs for Readability

#### 🔹 dbt model structure ≈ modular CTE pipeline

A well-written dbt model might look like this:

```sql
WITH payment AS (
  SELECT *
  FROM {{ ref('stg_payment') }}
),

customer AS (
  SELECT *
  FROM {{ ref('stg_customer') }}
),

payment_totals AS (
  SELECT 
    customer_id,
    SUM(amount) AS total_revenue
  FROM payment
  GROUP BY customer_id
),

customer_details AS (
  SELECT 
    customer_id,
    first_name,
    last_name
  FROM customer
),

final AS (
  SELECT 
    cd.customer_id,
    cd.first_name,
    cd.last_name,
    pt.total_revenue
  FROM customer_details cd
  LEFT JOIN payment_totals pt 
    ON cd.customer_id = pt.customer_id
)

SELECT * FROM final;
```

---

### ✅ Best Practices Reflected in the Model

| Principle                    | Applied How?                                                            |
| ---------------------------- | ----------------------------------------------------------------------- |
| One CTE = One transformation | `payment_totals`, `customer_details` clearly separate logic steps       |
| Named layers                 | `payment`, `customer` CTEs mirror dbt model names for clarity           |
| Final output block           | `final` CTE holds the SELECT logic, making it easy to test in isolation |
| dbt structure integration    | Uses `{{ ref() }}` and `snake_case` per style guides                    |

---

### 💡 Why This Matters for Students

* 🔍 **Debuggable**: You can test `payment_totals` independently if results look off.
* 📚 **Understandable**: Anyone reading it for the first time will know what each step is doing.
* ♻️ **Reusable**: This logic could be broken into **ephemeral models** or reused downstream.
* 📈 **Scalable**: Encourages good hygiene that translates well to production-grade pipelines.

---

### 🧪 Optional Follow-up Activities

* Convert `payment_totals` and `customer_details` into separate **ephemeral models**
* Introduce a filter (e.g., customers with >\$100 in total revenue) to demonstrate testable logic
* Compare runtime and compilation of the nested version vs. the modular version using `dbt compile` or `dbt run --debug`

---
