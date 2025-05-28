
## 🧠 **Section 2.4: dbt-Specific Uses of Jinja — `adapter`, `target`, `this`, etc.**

### 📚 **Key Concepts First**

These are **context-aware variables** and methods that dbt makes available **only at runtime**, injecting metadata and platform-specific behavior into your SQL.

---

### 1. `target`

This tells you **which profile/environment** is currently running the dbt command.

```jinja
{{ target.name }}
```

Returns strings like `"dev"`, `"prod"`, etc. — it matches the profile/target set in your `profiles.yml`.

✅ **Use Case:** Add row limits or filters in dev, full data in prod.

---

### 2. `this`

Gives you the **fully qualified name** of the current model (`database.schema.identifier`). Super useful for logging/debugging.

```jinja
{{ this }}
-- Might render as SNOWFLAKE.ACCOUNT.MY_MODEL
```

✅ **Use Case:** Log what model is being queried or written.

---

### 3. `adapter` Methods

This is how dbt lets you **write cross-platform SQL** — dbt will resolve the correct version for your warehouse (Snowflake, BigQuery, Redshift, etc.)

Some common ones:

```jinja
{{ adapter.dispatch('my_macro')() }}  -- Platform-specific macro
{{ adapter.get_column_values(ref('payment'), 'payment_method') }}  -- Returns values from a column
```

✅ **Use Case:** Fetch values from a table at compile time, or write logic that runs differently on Snowflake vs BigQuery.

---

## 🔧 **2 Examples of `set`, `for`, `if`, and `macro` — with Pagila Models**

---


## ✅ **Model 1: `models/staging/stg_pagila__recent_payments.sql`**

**Goal:** Use `set` to dynamically control a date filter for recent payments.

```sql
{{ config(
    materialized = 'view',
    tags = ['section_2_tests']
) }}

-- Set max date from the dataset (hardcoded here, ideally you'd extract it via a separate model or snapshot)
{% set max_payment_date = '2007-02-14' %}  -- Replace with dynamically queried value later
{% set recent_days = 30 %}

WITH recent_payments AS (
    SELECT
        payment_id,
        customer_id,
        staff_id,
        amount,
        payment_date
    FROM {{ source('pagila', 'payment') }}
    WHERE payment_date >= DATEADD(DAY, -{{ recent_days }}, TO_DATE('{{ max_payment_date }}'))
)

SELECT * FROM recent_payments

```
---

## ✅ Real Alternatives to Get Column Values

If you want to dynamically get the **max payment date**, you’ll need one of these two approaches:

---

### 🔧 **Option 1: Build an Intermediate Model to Materialize the Max Date**

**Model: `int_pagila__max_payment_date.sql`**

```sql
SELECT MAX(payment_date) AS max_payment_date
FROM {{ source('pagila', 'payment') }}
```

Then **in another model**, use it like:

```sql
SELECT
    payment_id,
    customer_id,
    amount,
    payment_date
FROM {{ source('pagila', 'payment') }}
WHERE payment_date >= (
    SELECT DATEADD(DAY, -30, max_payment_date)
    FROM {{ ref('int_pagila__max_payment_date') }}
)
```

✅ **No adapter magic needed**
✅ Works natively in Snowflake
✅ Transparent for students

---

Here’s the full **lesson plan content** and **model code breakdown** for the two `for` loop examples. This content is suitable for a teaching session on **Jinja loops in dbt models**, especially with Snowflake and the Pagila dataset.

---

## 📘 Lesson Plan: Using `for` Loops in dbt Models

### 🧠 Learning Objectives

By the end of this lesson, students will be able to:

* Understand how to use Jinja `for` loops to dynamically generate SQL in dbt.
* Use list-based iteration to build multi-query UNIONs.
* Control query generation with conditional logic (`loop.last`).
* Implement dynamic filters for parameterized analysis.

---

### 🧪 Example 1: Loop Over Store IDs

#### ✅ Goal

Return all rental records **filtered by a specific set of store IDs** (in this case, stores 1 and 2), materialized as a **view**.

#### 📦 dbt Model Code (`rental_by_store.sql`)

```sql
{{ config(
    materialized = 'view',
    tags = ['section_2_tests']
) }}

{% set store_ids = [1, 2] %}

{% for store in store_ids %}
    SELECT
        {{ store }} AS store_id,
        r.rental_id,
        r.customer_id,
        r.inventory_id,
        r.rental_date
    FROM {{ source('pagila', 'rental') }} AS r
    JOIN {{ source('pagila', 'inventory') }} AS i
        ON r.inventory_id = i.inventory_id
    WHERE i.store_id = {{ store }}
    
    {% if not loop.last %}
    UNION ALL
    {% endif %}
{% endfor %}
```

#### 📚 Explanation

* `store_ids` is a hardcoded list to iterate over.
* For each store ID, a subquery is generated and UNIONed with others.
* `loop.last` prevents a trailing `UNION ALL`.
* Useful pattern for isolating values dynamically without multiple models.

---

### 🧪 Example 2: Loop Over Genres for Monthly Revenue

#### ✅ Goal

Aggregate **monthly rental counts and revenue by genre**, restricted to a specific genre list, and materialize it as a **table**.

#### 📦 dbt Model Code (`genre_revenue_monthly.sql`)

```sql
{{ config(
    materialized = 'table',
    tags = ['section_2_tests']
) }}

{% set genres = ['Action', 'Animation', 'Children', 'Classics', 'Comedy', 'Documentary', 'Drama', 'Family', 'Foreign', 'Games'] %}

{% for genre in genres %}

SELECT
    '{{ genre }}' AS genre,
    DATE_TRUNC('month', p.payment_date) AS month,
    COUNT(*) AS rental_count,
    SUM(p.amount) AS total_revenue
FROM {{ source('pagila', 'payment') }} AS p
JOIN {{ source('pagila', 'rental') }} AS r ON p.rental_id = r.rental_id
JOIN {{ source('pagila', 'inventory') }} AS i ON r.inventory_id = i.inventory_id
JOIN {{ source('pagila', 'film') }} AS f ON i.film_id = f.film_id
JOIN {{ source('pagila', 'film_category') }} AS fc ON f.film_id = fc.film_id
JOIN {{ source('pagila', 'category') }} AS c ON fc.category_id = c.category_id
WHERE c.name = '{{ genre }}'
GROUP BY 1, 2

{% if not loop.last %}
UNION ALL
{% endif %}

{% endfor %}
```

#### 📚 Explanation

* `genres` is a list of category names.
* Each loop creates a SQL block for one genre, grouped by month.
* Resulting model is a unified table with genre, month, and metrics.
* Helps with **pivot-ready analysis** or dashboard feeding.

---

### 🛠 Teaching Tips

* Have students modify the `store_ids` or `genres` list to add/exclude values.
* Ask: "How would you do this manually without a `for` loop?" to show efficiency.
* Discuss materialization strategies (e.g., view vs. table for unioned queries).
* Mention Snowflake considerations (e.g., query complexity limits).


---


### 🔁 `if` Statement Example: Filter Rentals by Store Region

#### ✅ Goal

Only include rentals from **Store 1** if the store is considered "East Region."

#### 📦 dbt Model Code (`rental_if_example.sql`)

```sql
{{ config(
    materialized = 'view',
    tags = ['section_2_tests']
) }}

{% set east_region = true %}

SELECT
    r.rental_id,
    r.customer_id,
    i.store_id,
    r.rental_date
FROM {{ source('pagila', 'rental') }} AS r
JOIN {{ source('pagila', 'inventory') }} AS i
    ON r.inventory_id = i.inventory_id
WHERE 1 = 1
{% if east_region %}
    AND i.store_id = 1
{% else %}
    AND i.store_id != 1
{% endif %}
```

#### 📚 Explanation

* The `if` block dynamically alters SQL based on the variable `east_region`.
* This pattern is great for toggling logic in **shared models** or **environment-driven configs**.

---

### 🧰 Macro Example: Dynamic Genre Filter

#### ✅ Goal

Use a macro to filter payments by genre and return monthly revenue.

#### 📦 Macro File (`macros/get_genre_filter.sql`)

```jinja
{% macro get_genre_filter(genre_name) %}
    c.name = '{{ genre_name }}'
{% endmacro %}
```

#### 📦 Model Code (`genre_macro_example.sql`)

```sql
{{ config(
    materialized = 'table',
    tags = ['section_2_tests']
) }}

{% set genre = 'Comedy' %}

SELECT
    '{{ genre }}' AS genre,
    DATE_TRUNC('month', p.payment_date) AS month,
    COUNT(*) AS rental_count,
    SUM(p.amount) AS total_revenue
FROM {{ source('pagila', 'payment') }} AS p
JOIN {{ source('pagila', 'rental') }} AS r ON p.rental_id = r.rental_id
JOIN {{ source('pagila', 'inventory') }} AS i ON r.inventory_id = i.inventory_id
JOIN {{ source('pagila', 'film') }} AS f ON i.film_id = f.film_id
JOIN {{ source('pagila', 'film_category') }} AS fc ON f.film_id = fc.film_id
JOIN {{ source('pagila', 'category') }} AS c ON fc.category_id = c.category_id
WHERE {{ get_genre_filter(genre) }}
GROUP BY 1, 2
```

#### 📚 Explanation

* Macros are reusable Jinja snippets that return SQL strings.
* The `get_genre_filter` macro allows centralized control over how genre filtering is handled.
* Great for consistency and DRY principles across models.

---

### 🛠 Teaching Tips

* Ask students to toggle `east_region` to false and observe the SQL difference.
* Show them how to call macros with different parameters to generate different outputs.
* Optionally, link macro examples to `dbt_utils` or custom macro libraries.


