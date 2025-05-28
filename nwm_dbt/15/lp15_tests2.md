

### 🧪 Lesson Plan: How Tests in dbt Work

**🎯 Learning Objectives**

* Understand how dbt executes tests internally
* Differentiate how `dbt test`, `dbt run`, and `dbt build` interact with tests
* Learn how to control and target tests during development

---

### 1. **What Happens When You Run `dbt test`**

* **dbt test** compiles test configurations defined in `.yml` or custom SQL/macros
* Each test is translated into a SQL query:

  * **Generic tests** become queries with assertions (e.g., `SELECT * FROM ... WHERE field IS NULL`)
  * **Singular tests** are `.sql` files that return rows when the test fails
* dbt runs each query and checks if **zero rows** are returned (zero rows = test passed)

---

### 2. **How Tests Work with `dbt build`**

* `dbt build` runs:

  1. **`run`**: builds models
  2. **`test`**: runs all tests associated with the built models
* Only tests tied to models selected for build will run (e.g., via `--select`)

---

### 3. **How Tests Work with `dbt run`**

* `dbt run` **does not run tests**
* It just builds models – useful for faster iterations without testing
* Tests must be triggered separately (`dbt test` or `dbt build`)

---

### 4. **How to Target Tests**

* To run **specific tests**:
  `dbt test --select model_name`
  `dbt test --select tag:section_2_tests`
  `dbt test --select +customer_summary` (tests for `customer_summary` and upstream models)

* You can also **run specific test types**:
  `dbt test --data` → only data (SQL-based) tests
  `dbt test --schema` → only schema (YAML-based) tests

---

### 5. **When to Use Each Command**

| Command             | Purpose                               | Runs Tests? |
| ------------------- | ------------------------------------- | ----------- |
| `dbt run`           | Build models                          | ❌ No        |
| `dbt test`          | Only run tests                        | ✅ Yes       |
| `dbt build`         | Build models *and* run tests          | ✅ Yes       |
| `dbt run-operation` | Run macros (e.g., custom test macros) | ❌ No        |

---
