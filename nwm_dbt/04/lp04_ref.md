# Lesson Pack — **Using `ref()` + Pagila to Visualize dbt’s DAG**

Below are **four new models** that chain together, each using `ref()` to point at the previous layer.  
Drop the SQL files into your project, run the commands, and you’ll have a 4-step DAG that proves how dbt orders work automatically and rewires to each student’s schema.

```

pagila\_demo/
└── models/
├── staging/
│   ├── stg\_films.sql
│   ├── stg\_inventory.sql
│   └── stg\_rentals.sql
└── marts/
├── fct\_revenue\_by\_film.sql
└── schema.yml         # basic tests

````

---

## 1  `models/staging/stg_films.sql`  *(view)*

```sql
{{ config(materialized='view', tags=['pagila']) }}

SELECT
    film_id,
    title,
    release_year,
    rental_rate,
    length,
    rating,
    language_id,
    last_update
FROM {{ source('pagila','film') }};
````

---

## 2  `models/staging/stg_inventory.sql`  *(view)*

*Depends on stg\_films*

```sql
{{ config(materialized='view', tags=['pagila']) }}

SELECT
    i.inventory_id,
    i.film_id,
    f.title               AS film_title,
    i.store_id,
    i.last_update
FROM {{ source('pagila','inventory') }}      AS i
JOIN {{ ref('stg_films') }}                  AS f
  ON i.film_id = f.film_id;
```

---

## 3  `models/staging/stg_rentals.sql`  *(view)*

*Depends on stg\_inventory*

```sql
{{ config(materialized='view', tags=['pagila']) }}

SELECT
    r.rental_id,
    r.rental_date,
    r.customer_id,
    inv.store_id,
    inv.film_id,
    inv.film_title,
    r.return_date
FROM {{ source('pagila','rental') }} AS r
JOIN {{ ref('stg_inventory') }}      AS inv
  ON r.inventory_id = inv.inventory_id;
```

---

## 4  `models/marts/fct_revenue_by_film.sql`  *(table)*

*Depends on stg\_rentals and source payment*

```sql
{{ config(materialized='table', tags=['pagila']) }}

WITH rentals AS (

    SELECT *
    FROM {{ ref('stg_rentals') }}

), payments AS (

    SELECT
        p.payment_id,
        p.customer_id,
        p.rental_id,
        p.amount,
        p.payment_date
    FROM {{ source('pagila','payment') }} AS p
)

SELECT
    rentals.film_id,
    rentals.film_title,
    DATE_TRUNC('day', payments.payment_date) AS payment_day,
    SUM(payments.amount)                     AS revenue
FROM rentals
JOIN payments
  ON rentals.rental_id = payments.rental_id
GROUP BY film_id, film_title, payment_day;
```

---

## 6  Instructor Demo Commands

```bash

# compile to reveal schema substitution
dbt compile --select fct_revenue_by_film

# build full 4-layer DAG
dbt build --select tag:pagila+ source:pagila.*    # includes source tests
```

---

## 7  Slide Snippet – What Students Should Notice

| Layer                 | Ref Relationship       | Compiled FQN (for “Dave”)                  |
| --------------------- | ---------------------- | ------------------------------------------ |
| `stg_films`           | source → pagila.film   | `DBT_DEMO_05042026.STUDENT_DAVE.STG_FILMS` |
| `stg_inventory`       | `ref('stg_films')`     | `…STUDENT_DAVE.STG_FILMS`                  |
| `stg_rentals`         | `ref('stg_inventory')` | `…STUDENT_DAVE.STG_INVENTORY`              |
| `fct_revenue_by_film` | `ref('stg_rentals')`   | `…STUDENT_DAVE.STG_RENTALS`                |

The same SQL file, run in prod, would resolve to `…MART_PROD.*` — **no edits required**.

---

### Talking Point

> “Every `ref()` creates an edge in the DAG. dbt reads these edges, sorts them, swaps in the target schema per profile, and guarantees the models build **in the correct order** for every single student sandbox and every deployment environment.”

Drop these four models plus the YAML into your repo, run `dbt build`, and the class will watch a 4-step, pagila-powered DAG materialize in their personal schemas—perfectly illustrating `ref()` in action.

```
