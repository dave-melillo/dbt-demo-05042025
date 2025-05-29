

## 📘 Lesson Plan: Using `dbt_utils` in Your Project

### 🎯 Goal

Teach students how to:

* Import a dbt package using `packages.yml`
* Use the `generate_surrogate_key` macro from `dbt_utils`
* Build and materialize a model that summarizes customer revenue

---

### 🧱 Step 1: Add `dbt_utils` to `packages.yml`

In the root of your project:

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.0
```

Then run:

```bash
dbt deps
```

This downloads the package into `dbt_packages/`.

---

### 🧪 Step 2: Build the Model

Create a file at `models/customer_revenue_summary.sql`:

```sql
{{ config(materialized='view') }}

with base as (

    select 
        customer_id,
        sum(amount) as total_revenue
    from {{ source('pagila', 'payment') }}
    group by customer_id

),

final as (

    select 
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
        customer_id,
        total_revenue
    from base

)

select * from final
```

🧠 **Why this is useful**: `generate_surrogate_key` hashes one or more columns into a stable unique key — perfect for joins, snapshotting, and partitioning.

---

### ⚙️ Step 3: Run the Model

In your project folder:

```bash
dbt run --select customer_revenue_summary
```

Then verify the results:

```sql
SELECT * FROM DBT_DEMO_05042026.STUDENT_<name>.customer_revenue_summary;
```

---

### 📌 Instructor Notes

* Confirm students have `pagila` source data set up correctly and that `sources.yml` is declared.
* Review how `dbt_utils` macros are just Jinja that expands into SQL.
* Encourage experimentation: try using multiple columns in the surrogate key (e.g., `['customer_id', 'total_revenue']`).


