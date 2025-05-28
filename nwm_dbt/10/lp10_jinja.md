

## 🧠 **Lesson Plan: Intro to Templating Languages (Jinja Context)**

**Goal:** Give learners a conceptual grounding in what templating languages are and why Jinja is useful in the context of dbt and SQL.

### 🔹 Topics to Cover

* **What is a templating language?**

  * Used to dynamically generate code or text by combining logic and content.
  * Common in web dev (HTML templates), infrastructure (Ansible), APIs (Flask), and now… dbt.

* **Where have we already used Jinja?**

  * The `{{ ref('...') }}` function in dbt is *pure Jinja syntax*.
  * `{{ source('...') }}`, `{{ config(...) }}`, and `{{ this }}` are also templated.

* **Why does dbt use Jinja?**

  * Enables **parametrization**, **reusability**, and **environment-awareness** in SQL.
  * Lets you write DRY, context-sensitive code.

### 🔹 Examples to Show

* A basic `{{ ref('model_name') }}` reference.
* A `for` loop that builds a UNION of tables.
* A macro that conditionally applies `LIMIT 100` if not in prod.

### 🔹 Resources to Share

* 🧾 [Jinja2 Template Designer Documentation](https://jinja.palletsprojects.com/en/3.1.x/templates/)
* 🧪 [Jinja2 Cheatsheet (PDF)](https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Jinja2_Cheat_Sheet.pdf)
* 📚 [Jinja2 101 Tutorial (Hackers and Slackers)](https://hackersandslackers.com/jinja2-tutorial-python-html/)

---

## 📽️ **Slide: “Templating 101 — Separating Logic from Content”**

### 🔹 Slide Title

**Templating 101 — Separating Logic from Content**

### 🔹 Main Points

**🧩 What is a Templating Language?**

* A way to generate dynamic content by embedding logic into static files
* Used in HTML, YAML, Markdown, SQL, etc.

**⚙️ Why Jinja in dbt?**

* Reusable, DRY SQL
* Allows for dynamic logic in otherwise static SQL
* Scales models across databases, users, and environments
* Enables parameter injection based on `target`, `adapter`, etc.

**🌍 Real-World Uses**

* In Flask: dynamically generate HTML
* In Ansible: generate config files
* In dbt: generate SQL pipelines with dynamic references

**📌 You’ve Already Used Jinja!**

* `{{ ref('my_model') }}`
* `{{ config(materialized='table') }}`
* `{{ source('pagila', 'payment') }}`

---

