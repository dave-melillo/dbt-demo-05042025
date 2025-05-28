# Lesson Plan — **Using Docs Blocks in dbt (Corrected for Modern Usage)**

This lesson teaches students how to write rich, reusable documentation using `docs` blocks in dbt. It covers where `docs` blocks belong (Markdown `.md` files), how to reference them in your model YAML, and how to render them in the dbt Docs UI.

---

## 🧠 Learning Objectives

By the end of this lesson, students will be able to:

- Create reusable documentation using `{% docs %}` blocks in `.md` files  
- Reference `docs` blocks in model descriptions via `doc()`  
- Generate and view dbt Docs with full Markdown rendering  
- Structure project documentation using centralized `.md` files  
- Understand the difference between `description:` and `doc()` blocks

---

## 🧱 Prerequisites

- Students have a working dbt project and profile  
- They’ve seen `dbt docs generate` and `dbt docs serve` before  
- A model like `fct_revenue_by_film` already exists and is described in `schema.yml`

---

## 🧑‍🏫 Lesson Outline (20–25 minutes)

---

### 1. What Are `docs` Blocks? (3 min)

Explain:  
> `docs` blocks allow you to write **long-form Markdown documentation** and reuse it across your dbt project.

- Better for formatting (headers, bullet lists, links, bold/italic)  
- Keeps descriptions separate from YAML clutter  
- Fully searchable + navigable in dbt Docs

---

### 2. Write a Docs Block in a Markdown File (5 min)

✅ File path: `models/marts/docs/model_docs.md`

```jinja
{% docs fct_revenue_by_film_doc %}
This model calculates **daily revenue per film** by joining:

- `stg_rentals` for rental info
- `pagila.payment` for payment amounts

Used in dashboards and monthly reports.
{% enddocs %}
````

✅ You can include **multiple docs blocks** in one file
✅ Block names must be alphanumeric and start with a letter

---

### 3. Reference the Block in Your YAML (5 min)

File: `models/marts/schema.yml`

```yaml
version: 2

models:
  - name: fct_revenue_by_film
    description: "{{ doc('fct_revenue_by_film_doc') }}"
```

This replaces the plain string with rich Markdown from the `.md` file.

---

### 4. Render It (5 min)

```bash
dbt clean
dbt parse
dbt docs generate
dbt docs serve
```

Open the docs UI:

* Click on `fct_revenue_by_film`
* See the full Markdown-rendered content
* Test search, headers, links, and lists

---

### 5. Best Practices (3–5 min)

* Use docs blocks for anything longer than 2–3 lines
* Group them by folder or model category (`model_docs.md`, `sources_docs.md`)
* Use lists, headers, links to reports/dashboards, and stakeholder info
* Name them clearly (`fct_daily_sales_doc`, `dim_users_doc`, etc.)

---

## 🧪 Optional Student Activity

1. Create a new `.md` file and define 2 `docs` blocks inside it
2. Reference one of them from a model in `schema.yml`
3. Re-run docs build and confirm the formatted output
4. Try adding a bullet list or a header in the doc block

---

## 💬 Wrap-Up Talking Points

* `docs` blocks bring rich, reusable documentation to your models
* Keep logic in SQL, metadata in YAML, and explanations in Markdown
* The result is a **clean, maintainable, searchable** project that scales across teams


