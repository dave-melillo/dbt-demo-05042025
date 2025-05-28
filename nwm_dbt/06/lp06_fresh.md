# Lesson Plan — **Source Freshness in dbt**

This lesson introduces students to **source freshness testing**: how to declare freshness expectations in `sources.yml`, how dbt evaluates them, and how this connects to data SLAs and pipeline reliability.

---

## 🧠 Learning Objectives

By the end of this lesson, students will be able to:

- Understand what source freshness is and why it matters  
- Add a `loaded_at_field` and `freshness` block to a source in `sources.yml`  
- Run a freshness test using `dbt source freshness`  
- Interpret WARN / ERROR output  
- Know when and where to apply freshness tests in real-world data pipelines

---

## 🧱 Prerequisites

- Students have already defined at least one source (e.g. `pagila.film`, `pagila.payment`)  
- Students can run `dbt debug` and connect to Snowflake  
- `last_update` or `payment_date` fields exist in the source table

---

## ✏️ Step-by-Step Lesson Outline (15–20 min)

---

### 1. What is Source Freshness? (3 min)

Explain:  
> Source freshness is dbt’s way of checking **how recent** a table’s latest data is.  
> It’s used to detect **pipeline delays**, **ingestion failures**, or **stale data** before models run.

---

### 2. Add Freshness to a Source Definition (5 min)

Update the existing source definition in `models/sources/source.yml`.  
Use `pagila.payment` as a good example.

#### Before:
```yaml
- name: payment
  loaded_at_field: payment_date
````

#### After:

```yaml
- name: payment
  loaded_at_field: payment_date
  freshness:
    warn_after: {count: 12, period: hour}
    error_after: {count: 24, period: hour}
```

✅ `loaded_at_field` must be a column with the latest ingestion timestamp
✅ dbt will calculate `MAX(payment_date)` and compare it to `now()`

---

### 3. Run the Freshness Test (5 min)

```bash
dbt source freshness --select source:pagila.payment
```

Sample output:

```
source freshness: pagila.payment
max_loaded_at: 2025-05-21 09:00:00
snapshotted_at: 2025-05-21 15:00:00
age: 6 hours
status: PASS
```

---

### 4. When Freshness Fails (3 min)

* **WARN** = still acceptable, but behind SLA
* **ERROR** = stale — consider halting downstream models
* dbt Cloud can fail jobs automatically on freshness failure

---

### 5. Real-World Context (3 min)

* Use for **daily ingest tables** (e.g. Salesforce, payments, logs)
* Supports **data SLAs** — “we guarantee this table is < 24 hrs old”
* Run in CI or as a separate freshness job on a schedule

---

## 🧪 Optional Student Activity

* Add a `freshness:` block to another source (e.g. `rental`)
* Run `dbt source freshness` on multiple sources
* Modify a `warn_after` to 1 hour to simulate a warning

---

## 💬 Wrap-Up Talking Points

* Source freshness is a **safety check** on your upstream data
* It helps you **fail fast** before wasting compute on stale pipelines
* Easy to adopt—just one YAML block and a CLI command

---

