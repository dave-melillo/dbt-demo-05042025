
## 🧠 **Lesson Plan: Using Jinja in the Context of SQL**

**Goal:** Show students how Jinja dynamically builds SQL statements in dbt. Reinforce the idea that templating is evaluated **before** SQL is executed.

---

### 🔹 Core Concepts + Examples

---

### 1. `set` — Store SQL fragments or table names

```jinja
{% set table_name = 'payment' %}

SELECT * FROM {{ table_name }}
```

**Output SQL:**

```sql
SELECT * FROM payment
```

---

### 2. `for` — Create repeating SQL structures (e.g. UNIONs)

```jinja
{% set tables = ['payment', 'rental', 'customer'] %}

{% for t in tables %}
SELECT '{{ t }}' AS source_table, * FROM {{ t }}
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}
```

**Output SQL:**

```sql
SELECT 'payment' AS source_table, * FROM payment
UNION ALL
SELECT 'rental' AS source_table, * FROM rental
UNION ALL
SELECT 'customer' AS source_table, * FROM customer
```

---

### 3. `if` — Conditional SQL for environments

```jinja
{% if target.name == 'prod' %}
  SELECT * FROM production_table
{% else %}
  SELECT * FROM dev_sample_table
{% endif %}
```

**Output SQL (in dev):**

```sql
SELECT * FROM dev_sample_table
```

---

### 4. `macro` — Reusable SQL logic (e.g. safe math or filters)

**macros/safe\_sum.sql**

```jinja
{% macro safe_sum(column) %}
  COALESCE({{ column }}, 0)
{% endmacro %}
```

**Usage:**

```jinja
SELECT {{ safe_sum('amount') }} AS total_amount FROM payment
```

**Output SQL:**

```sql
SELECT COALESCE(amount, 0) AS total_amount FROM payment
```

---

### 🔹 Teaching Points

* SQL is generated *before* execution
* `target.name`, `this`, `adapter.get_column_values` make SQL dynamic
* Jinja lets you DRY out complex logic (think: filters, conditionals, reusability)

---

## 📽️ **Slide: “Templating Meets SQL — Jinja in Action”**

### 🔹 Slide Layout

**1. `set`**

```jinja
{% set table = 'payment' %}
SELECT * FROM {{ table }}
```

**2. `for`**

```jinja
{% for t in ['payment', 'rental'] %}
SELECT * FROM {{ t }}
{% endfor %}
```

**3. `if`**

```jinja
{% if target.name == 'prod' %} SELECT * FROM prod_table {% endif %}
```

**4. `macro`**

```jinja
{% macro safe_sum(c) %} COALESCE({{ c }}, 0) {% endmacro %}
```

---

### 📌 Pro Tips (Add to Bottom of Slide)

* Macros go in `/macros/` folder, referenced with `{{ my_macro(arg) }}`
* Use `loop.first`, `loop.last` in `for` loops
* Use `target.name` for env-specific logic

