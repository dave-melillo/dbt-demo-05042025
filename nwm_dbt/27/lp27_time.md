## 🪟 **1. How Window Functions Work**

Window functions calculate values **across rows that are related** to the current row, without collapsing them.

### 🧪 Example: Total payments by customer

```sql
SELECT
    customer_id,
    payment_id,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id) AS total_per_customer
FROM {{ source('pagila', 'payment') }}
```

✅ This keeps each payment row but adds the **total** a customer has paid so far.

---

## 🧠 **2. Use Cases for Window Functions**

* Running totals (rolling revenue, balance)
* Row numbering and rankings (leaderboards)
* Lag/lead comparisons (find last purchase date)
* Deduplication (row\_number)
* Rolling averages

---

## 📅 **3. Creating History Tables with Calendar Spines**

To ensure full continuity over time (even on days with no events), we **join your event data to a calendar spine**.

### 🧪 Example: Generate calendar spine (last 7 days)

```sql
WITH calendar AS (
    SELECT DATEADD(day, seq4(), CURRENT_DATE - 6) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 7))
)
SELECT * FROM calendar
```

✅ You can join this to `daily_agg` models to **fill gaps**.

---

## 📈 **4. Using Window Functions for Rolling Aggregates**

### 🧪 Example: 3-day rolling payment sum per customer

```sql
SELECT
    customer_id,
    DATE(payment_date) AS payment_day,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY DATE(payment_date)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3day_sum
FROM {{ source('pagila', 'payment') }}
```

✅ This gives a moving 3-day revenue window **per customer**.

---

## 🔁 **5. Using Window Functions to Find Following or Preceding Values**

### 🧪 Example: Last and next payment per customer

```sql
SELECT
    customer_id,
    payment_id,
    payment_date,
    LAG(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date) AS previous_payment,
    LEAD(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date) AS next_payment
FROM {{ source('pagila', 'payment') }}
```

✅ Useful for churn analysis, behavior prediction, etc.

---

## 🔍 **6. Filtering using `REGEXP` vs `ILIKE`**

### 🧪 `ILIKE`: simple pattern match (case-insensitive)

```sql
SELECT email FROM {{ source('pagila', 'customer') }}
WHERE email ILIKE '%yahoo.com'
```

### 🧪 `REGEXP`: full regex

```sql
SELECT email FROM {{ source('pagila', 'customer') }}
WHERE email ~* '^[a-z0-9._%+-]+@(gmail|yahoo)\.com$'
```

✅ Use `ILIKE` for quick filters, `REGEXP` when you need true pattern matching.

---

## ✅ Summary Table

| Topic                     | Technique                            | Sample Query Highlights                            |
| ------------------------- | ------------------------------------ | -------------------------------------------------- |
| How Window Functions Work | `SUM(...) OVER (PARTITION BY ...)`   | Adds aggregates without collapsing rows            |
| Use Cases                 | Running total, ranking, lag/lead     | Common for churn, finance, quality scoring         |
| Calendar Spines           | `GENERATOR(ROWCOUNT)`                | Generates rows even when no activity happened      |
| Rolling Aggregates        | `ROWS BETWEEN ...`                   | Used in trend analysis, smoothing                  |
| Lag/Lead Values           | `LAG()`, `LEAD()`                    | Detect previous or next events                     |
| Regex vs ILIKE            | `ILIKE` = simple match, `~*` = regex | Case-insensitive search vs full pattern validation |

