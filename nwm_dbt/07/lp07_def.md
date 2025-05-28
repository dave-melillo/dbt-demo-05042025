# Lesson Plan — **How to Add Descriptions to Models and Sources in dbt**

This lesson teaches students how to write and organize **documentation** directly inside dbt—covering both **models** and **sources**—so the lineage graph and documentation site are clear, searchable, and self-explanatory.

---

## 🧠 Learning Objectives

By the end of this lesson, students will be able to:

- Add human-readable descriptions to dbt models, columns, and sources  
- Understand where dbt stores these descriptions (`schema.yml`, `sources.yml`)  
- Generate and view documentation via `dbt docs generate` and `dbt docs serve`  
- Appreciate the role of documentation in **team onboarding**, **data discovery**, and **self-serve analytics**

---

## 🧱 Prerequisites

- dbt project initialized and working  
- At least one model and one source already defined (e.g., `stg_films`, `pagila.film`)  
- `schema.yml` and `sources.yml` already exist (or are created during class)

---

## 🧑‍🏫 Lesson Outline (20–25 min)

---

### 1. Why dbt Docs Matter (3 min)

Explain:  
> dbt auto-generates a **documentation website** from YAML + model SQL.  
> Descriptions help your future self, your teammates, and non-engineering stakeholders find meaning in your models.

---

### 2. Describe a Model in `schema.yml` (5 min)

Example:
```yaml
version: 2

models:
  - name: stg_films
    description: Cleaned film data from the raw pagila.film source.
    columns:
      - name: film_id
        description: Unique identifier for each film.
      - name: title
        description: The film’s title.
````

✅ Go line-by-line:

* `description:` is free text
* dbt shows this in the docs site under **Models → stg\_films**
* Same syntax works for any model or column

---

### 3. Describe a Source in `sources.yml` (5 min)

Example:

```yaml
sources:
  - name: pagila
    schema: PAGILA
    tables:
      - name: film
        description: The raw film table in Snowflake.
        columns:
          - name: film_id
            description: Unique film ID in the source system.
```

✅ Columns in raw sources can be just as richly documented as transformed models.

---

### 4. Generate and Serve Docs (5 min)

```bash
dbt docs generate
dbt docs serve
```

* Live website with:

  * Lineage DAG
  * Searchable model/source descriptions
  * Column-level info
  * Test status and tags

✅ Show live: click a model → see descriptions + schema tests

---

### 5. Good Documentation Practices (3 min)

* Write from the perspective of someone *new* to the data
* Keep descriptions **clear, short, and business-readable**
* Avoid repeating table/column names ("This is the film\_id" = 🚫)
* Tag your models if helpful for grouping

---

## 🧪 Optional Student Activity

1. Pick a model or source from the `pagila` pipeline
2. Add descriptions to 2–3 columns
3. Regenerate docs and verify changes show up in the UI

---

## 💬 Wrap-Up Talking Points

* dbt Docs turn your project into a living data catalog
* Descriptions = discoverability
* Combine with tests + tags for robust model governance
* It’s the **simplest way** to improve team trust in your warehouse

---
