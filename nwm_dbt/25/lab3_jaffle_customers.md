

# 🧪 Lab 3: CTEs vs Subqueries and Refactoring with Ephemeral Models

**Project**: Helping Jaffle Inc. build a reliable `customer_metrics` table for business reporting.
**Theme**: Improve query readability and modularity using CTEs and dbt features.

---

## 🧩 Background

Jaffle Inc. is trying to better understand their customers. They've asked you to create a model that answers:

* How many orders has each customer placed?
* When was their first and most recent order?
* How many distinct products have they ever purchased?

You’ll help the analytics team move from a naive subquery-based implementation to something production-grade using **CTEs** and **ephemeral models**.

---

## 🧪 Part 1: Refactor Subqueries to CTEs

**🧠 Goal**: Rewrite a model that uses **subqueries** into one that uses **named CTEs** for clarity and performance.

---

### ❓ QUESTION

You are given a `customer_metrics` model that answers key questions using subqueries. Refactor it using **CTEs**.

---

### 📄 Before — Subquery-Based Model

**File**: `customer_metrics_before_lab3.sql`

```sql
select
  c.customer_id,
  c.customer_name, 
  (
    select count(*) 
    from {{ ref('stg_orders') }} o
    where o.customer_id = c.customer_id
  ) as total_orders,
  (
    select min(ordered_at) 
    from {{ ref('stg_orders') }} o
    where o.customer_id = c.customer_id
  ) as first_order_date,
  (
    select max(ordered_at) 
    from {{ ref('stg_orders') }} o
    where o.customer_id = c.customer_id
  ) as most_recent_order_date,
  (
    select count(distinct i.product_id)
    from {{ ref('stg_orders') }} o
    join {{ ref('stg_order_items') }} i on o.order_id = i.order_id
    where o.customer_id = c.customer_id
  ) as unique_products_purchased
from {{ ref('stg_customers') }} c
```

---

### ✅ ANSWER — Refactored with CTEs

**File**: `customer_metrics_after_lab3.sql`

```sql
with order_metrics as (
  select
    customer_id,
    count(*) as total_orders,
    min(ordered_at) as first_order_date,
    max(ordered_at) as most_recent_order_date
  from {{ ref('stg_orders') }}
  group by customer_id
),

product_counts as (
  select
    o.customer_id,
    count(distinct i.product_id) as unique_products_purchased
  from {{ ref('stg_orders') }} o
  join {{ ref('stg_order_items') }} i on o.order_id = i.order_id
  group by o.customer_id
)

select
  c.customer_id,
  c.customer_name,
  o.total_orders,
  o.first_order_date,
  o.most_recent_order_date,
  p.unique_products_purchased
from {{ ref('stg_customers') }} c
left join order_metrics o on c.customer_id = o.customer_id
left join product_counts p on c.customer_id = p.customer_id
```

---

## 🧪 Part 2: Break Monolithic CTE into Ephemeral Models

**🧠 Goal**: Refactor a long CTE-based model by **extracting each CTE** into its own **ephemeral model**.

---

### ❓ QUESTION

You are given a single `customer_monolith` model that uses two CTEs to answer the same business questions. Refactor it by:

1. Creating two **ephemeral models**:

   * `order_metrics_lab3`
   * `product_metrics_lab3`
2. Refactoring `customer_monolith` to use those.

---

### 📄 Before — Monolith with Inline CTEs

**File**: `customer_monolith_before_lab3.sql`

```sql
with order_metrics as (
  select
    customer_id,
    count(*) as total_orders,
    min(ordered_at) as first_order_date,
    max(ordered_at) as most_recent_order_date
  from {{ ref('stg_orders') }}
  group by customer_id
),

product_metrics as (
  select
    o.customer_id,
    count(distinct i.product_id) as unique_products_purchased
  from {{ ref('stg_orders') }} o
  join {{ ref('stg_order_items') }} i on o.order_id = i.order_id
  group by o.customer_id
)

select
  c.customer_id,
  c.customer_name, 
  o.total_orders,
  o.first_order_date,
  o.most_recent_order_date,
  p.unique_products_purchased
from {{ ref('stg_customers') }} c
left join order_metrics o on c.customer_id = o.customer_id
left join product_metrics p on c.customer_id = p.customer_id
```

---

### ✅ ANSWER — Split into Ephemeral Models

---

**1. `order_metrics_lab3.sql`**

```sql
{{ config(
    materialized = 'ephemeral',
    tags = ['lab3']
) }}

select
  customer_id,
  count(*) as total_orders,
  min(ordered_at) as first_order_date,
  max(ordered_at) as most_recent_order_date
from {{ ref('stg_orders') }}
group by customer_id
```

---

**2. `product_metrics_lab3.sql`**

```sql
{{ config(
    materialized = 'ephemeral',
    tags = ['lab3']
) }}

select
  o.customer_id,
  count(distinct i.product_id) as unique_products_purchased
from {{ ref('stg_orders') }} o
join {{ ref('stg_order_items') }} i on o.order_id = i.order_id
group by o.customer_id
```

---

**3. Final Model: `customer_monolith_after_lab3.sql`**

```sql
{{ config(
    materialized = 'view',
    tags = ['lab3']
) }}

select
  c.customer_id,
  c.customer_name, 
  o.total_orders,
  o.first_order_date,
  o.most_recent_order_date,
  p.unique_products_purchased
from {{ ref('stg_customers') }} c
left join {{ ref('order_metrics_lab3') }} o on c.customer_id = o.customer_id
left join {{ ref('product_metrics_lab3') }} p on c.customer_id = p.customer_id
```

---

### 🧠 What Students Learn

| Concept            | Skill Gained                             |
| ------------------ | ---------------------------------------- |
| CTEs vs Subqueries | Refactor for clarity and better planning |
| Ephemeral Models   | dbt modularity without persistence       |
| Reusability        | Share metrics logic across models        |
| Readability        | Easier review and testing for analytics  |

