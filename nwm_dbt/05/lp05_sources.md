
# Lesson Plan — **How to Define and Use Sources in dbt**

This lesson introduces students to `sources` in dbt: how they’re defined in YAML, how they reference real Snowflake tables, and how they differ from `ref()`.

---

## 🧠 Learning Objectives

By the end of this lesson, students will be able to:

- Understand what a `source` is in dbt and why it’s needed  
- Define a `source` block in `sources.yml`  
- Use `{{ source(...) }}` in a model and explain what it compiles to  
- Explain the difference between `source()` and `ref()`  
- Map a `source` definition to a real table in Snowflake

---

## 🧱 Prerequisites

- Student has access to the dbt project and a working `profiles.yml`
- The `DBT_DEMO_05042026.PAGILA` schema is visible and readable
- At least one model already uses `source()` (e.g., `stg_films.sql`)

---

## 🧑‍🏫 Lesson Outline (25–30 min)

### 1. Introduce the Concept of `source` (5 min)

- Explain: `source` is how dbt refers to **external tables** dbt didn’t build.
- Examples: raw data from Snowflake UI uploads, ingestion pipelines, Fivetran, etc.
- Why it matters: allows **lineage, testing, and documentation** of inputs.

---

### 2. Walk Through the YAML Definition (8 min)

Use the snippet from `models/sources/source.yml`:

```yaml
sources:
  - name: pagila
    database: DBT_DEMO_05042026
    schema: PAGILA
    tables:
      - name: film
        identifier: FILM
        loaded_at_field: last_update
        columns:
          - name: film_id
            tests: [not_null, unique]
````

* Point to each field and map it to Snowflake:

  * `database`, `schema` → where the raw table lives
  * `name` → how we refer to it in dbt
  * `identifier` → actual table name in Snowflake if it doesn’t match `name`
  * `columns` → place to attach **tests** to external data

✅ Bonus: Run `SHOW TABLES IN SCHEMA DBT_DEMO_05042026.PAGILA;` in Snowsight to connect YAML to real tables

---

### 3. Show `source()` in a Model (5 min)

Use `models/staging/stg_films.sql`:

```sql
SELECT *
FROM {{ source('pagila', 'film') }}
```

Compile and show what this becomes:

```sql
SELECT *
FROM DBT_DEMO_05042026.PAGILA.FILM
```

> Emphasize that `source()` resolves to the actual raw table.
> Contrast this with `ref()` which resolves to a dbt-managed object in the student’s schema.

---

### 4. Contrast `ref()` vs `source()` (5 min)

| Concept         | `source()`           | `ref()`                     |
| --------------- | -------------------- | --------------------------- |
| Used for        | Raw/external tables  | dbt-built models            |
| Triggers build? | No                   | Yes                         |
| Compiles to     | Source table         | Schema-qualified model name |
| Part of DAG?    | Only the entry point | Yes, full dependency node   |

✅ Example:

* `{{ source('pagila','film') }}` → `DBT_DEMO_05042026.PAGILA.FILM`
* `{{ ref('stg_films') }}` → `DBT_DEMO_05042026.STUDENT_DAVE.STG_FILMS`

---

### 5. Bonus (optional): Freshness Test (2–3 min)

If defined in YAML:

```yaml
        loaded_at_field: last_update
        freshness:
          warn_after: {count: 24, period: hour}
          error_after: {count: 48, period: hour}
```

Then run:

```bash
dbt source freshness --select source:pagila.film
```

---

## 🧪 Student Activity (Optional)

Ask students to:

1. Locate a different raw table in `PAGILA` (e.g., `customer`)
2. Add it to the `sources.yml` file with column tests
3. Create a simple model using `source('pagila', 'customer')` and run `dbt compile`
4. Verify the compiled SQL points at the real source table

---

## 💬 Wrap-up Talking Points

* `source()` is how dbt connects to real-world, raw data
* It lets you add **tests**, **freshness checks**, and **lineage**
* `ref()` connects you to your own dbt models—`source()` points to data someone else (or something else) created
* This distinction keeps raw data and modeling logic separate

---

Let me know if you'd like this wrapped into a downloadable `.md` file or integrated into your course guide!

