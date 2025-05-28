Here's a full **lab** for the **"Jinja, Schema Tests, and Custom Tests"** section of your course, based on the Pagila dataset. It’s designed to *complement*, not repeat, previous exercises.

---

# 🧪 Lab: Jinja, Schema Tests, and Custom Tests in dbt

## 🧭 Overview

In this lab, you will:

1. Create new models based on Pagila tables.
2. Add basic schema tests (e.g. `not_null`) to key columns.
3. Write and apply a custom **schema test**.
4. Write and apply a **custom data test**.

Estimated time: 45–60 minutes

---

## 🧱 Prerequisites

Ensure your project is already connected to the Pagila dataset and your `sources.yml` includes:

* `actor`, `category`, `customer`, `inventory`, `language`, `payment`, and `store`.

---

## 🔨 Part 1: Add Schema Tests to Primary Keys

### 🧭 Instructions

1. Create a `models/core/` directory if it doesn't exist.
2. Create the following simple passthrough models:

```sql
-- models/core/actor.sql
{{ config(materialized='view') }}

SELECT * FROM {{ source('pagila', 'actor') }}
```

```sql
-- models/core/language.sql
{{ config(materialized='view') }}

SELECT * FROM {{ source('pagila', 'language') }}
```

```sql
-- models/core/store.sql
{{ config(materialized='view') }}

SELECT * FROM {{ source('pagila', 'store') }}
```

3. In `models/core/schema.yml`, define schema tests for each model’s **primary key** column:

```yaml
version: 2

models:
  - name: actor
    columns:
      - name: actor_id
        tests:
          - not_null
          - unique

  - name: language
    columns:
      - name: language_id
        tests:
          - not_null
          - unique

  - name: store
    columns:
      - name: store_id
        tests:
          - not_null
          - unique
```

4. Run and validate:

```bash
dbt build --select path:models/core
```

---

## 🧪 Part 2: Write a Custom Schema Test

Create a test that ensures store IDs are either 1 or 2 (no rogue stores!).

### 🧭 Instructions

1. Add this macro to `macros/tests/store_id_range.sql`:

```sql
{% test store_id_range(model, column_name) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} NOT IN (1, 2)
{% endtest %}
```

2. Modify your `store` model test section in `schema.yml`:

```yaml
      - name: store_id
        tests:
          - store_id_range:
              severity: warn
```

3. Re-run:

```bash
dbt test --select store
```

---

## 🧪 Part 3: Write a Custom Data Test

Let’s ensure no actors share the same first and last name combination.

### 🧭 Instructions

1. Add this test to `tests/duplicate_actor_names.sql`:

```sql
SELECT first_name, last_name, COUNT(*)
FROM {{ ref('actor') }}
GROUP BY 1, 2
HAVING COUNT(*) > 1
```

2. Run:

```bash
dbt test --select actor
```

Note: This model won’t persist anything but will show how `adapter.create_schema` is invoked conditionally.

---

## ✅ Wrap-Up: Checkpoints

* ✅ Added `not_null` and `unique` tests to keys in core models.
* ✅ Created a **custom schema test** (`store_id_range`).
* ✅ Wrote a **custom data test** for duplicate actor names.

Let me know if you’d like this exported into files or presented as slides.
