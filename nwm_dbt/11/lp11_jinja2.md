
## 🧠 **Lesson Plan: `set`, `for`, `if`, `macro` in Jinja (Non-SQL Context)**

**Goal:** Build foundational understanding of Jinja’s control structures **before** applying them to SQL. Emphasize the templating aspect and its roots in Python/HTML contexts.

### 🔹 Concepts to Teach with Generic Examples

---

### 1. `set` — Store values

```jinja
{% set greeting = "Hello" %}
{{ greeting }}, world!
```

**Rendered Output:**

```
Hello, world!
```

---

### 2. `for` — Looping through a list

```jinja
{% for name in ["Alice", "Bob", "Charlie"] %}
Hello, {{ name }}!
{% endfor %}
```

**Rendered Output:**

```
Hello, Alice!
Hello, Bob!
Hello, Charlie!
```

---

### 3. `if` — Conditional logic

```jinja
{% set user = "admin" %}
{% if user == "admin" %}
Access granted.
{% else %}
Access denied.
{% endif %}
```

**Rendered Output:**

```
Access granted.
```

---

### 4. `macro` — Define reusable blocks

```jinja
{% macro shout(text) %}
  {{ text | upper }}!!!
{% endmacro %}

{{ shout("jinja is cool") }}
```

**Rendered Output:**

```
JINJA IS COOL!!!
```

---

### 🔹 Teaching Notes

* Mention Jinja’s origins (Flask, Ansible, static site generators)
* Reinforce that this logic is rendered before the code is executed (preprocessing)
* Encourage experimentation in a [Jinja Playground](https://j2live.ttl255.com/) or local template engine

---

## 📽️ **Slide: “Anatomy of Jinja — Logic in Templating”**

### 🔹 Slide Layout: Four Quadrants (1 per feature)

**🔧 `set`**

* Syntax: `{% set x = "value" %}`
* Purpose: Define a variable
* Example: `{{ x }}` ➝ `value`

---

**🔁 `for`**

* Syntax: `{% for item in list %}`
* Purpose: Iterate over items
* Example: `Hello, {{ item }}!`

---

**❓ `if`**

* Syntax: `{% if condition %} ... {% endif %}`
* Purpose: Add branching logic
* Example: Display “Admin Access” if user is admin

---

**🔂 `macro`**

* Syntax: `{% macro name(args) %} ... {% endmacro %}`
* Purpose: Reusable logic/function
* Example: `{{ shout("hi") }}` ➝ `HI!!!`

---

### 🧪 Resources to Include

* 🧾 [Jinja Control Structures Docs](https://jinja.palletsprojects.com/en/3.1.x/templates/#list-of-control-structures)
* 🧪 [Live Playground (j2live)](https://j2live.ttl255.com/)
* 🎓 [RealPython Tutorial](https://realpython.com/primer-on-jinja-templating/)
* 📄 [Cheat Sheet (PDF)](https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Jinja2_Cheat_Sheet.pdf)


