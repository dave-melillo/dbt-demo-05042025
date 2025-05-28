
---

### 🧾 `dbt_project.yml` Cheat Sheet

| Key              | Purpose                                                                         |
| ---------------- | ------------------------------------------------------------------------------- |
| `name`           | The name of your dbt project. Also used as the schema prefix in some databases. |
| `version`        | Your version of this project (semantic versioning). Optional but good practice. |
| `config-version` | Set to `2` — required by dbt for current features.                              |
| `profile`        | Name of the profile in `~/.dbt/profiles.yml` that contains connection details.  |

---

### 📁 File Path Configs

| Key              | Purpose                                                     |
| ---------------- | ----------------------------------------------------------- |
| `model-paths`    | Where dbt looks for `.sql` models. Default is `["models"]`. |
| `seed-paths`     | Where seed CSV files live.                                  |
| `test-paths`     | Custom data tests if any.                                   |
| `analysis-paths` | `.sql` files for ad-hoc or advanced analysis.               |
| `macro-paths`    | Jinja macros.                                               |
| `snapshot-paths` | Snapshot definitions.                                       |
| `docs-paths`     | Custom documentation markdown files.                        |
| `asset-paths`    | Path for asset files (e.g., images) used in documentation.  |

---

### 🧹 Maintenance & Setup

| Key                     | Purpose                                                                            |
| ----------------------- | ---------------------------------------------------------------------------------- |
| `clean-targets`         | Folders dbt will remove during `dbt clean`. Typically `["target", "dbt_modules"]`. |
| `packages-install-path` | Where packages from `packages.yml` get installed. Defaults to `dbt_packages`.      |
| `require-dbt-version`   | Enforces dbt version compatibility. Use range like `">=1.5.0"`.                    |

---

### ⚙️ Build Behavior

| Key                | Purpose                                                                                       |
| ------------------ | --------------------------------------------------------------------------------------------- |
| `models:`          | Configure materializations, paths, tags, etc. on folders or specific models.                  |
| `seeds:`           | Configure how seed files are materialized (table, incremental, etc).                          |
| `snapshots:`       | Snapshot configs for SCD handling.                                                            |
| `tests:`           | Default behavior for custom data tests.                                                       |
| `sources:`         | Source-level configs like freshness or quoting.                                               |
| `quoting:`         | Control quoting behavior of `database`, `schema`, `identifier`. Useful in Snowflake/BigQuery. |
| `vars:`            | Global variables available in Jinja (`{{ var('my_var') }}` usage).                            |
| `metrics:`         | Configure metrics metadata (for legacy metric layer).                                         |
| `semantic-models:` | Configure new semantic layer models.                                                          |

---

### 🔄 Runtime Hooks

| Key             | Purpose                                                                           |
| --------------- | --------------------------------------------------------------------------------- |
| `on-run-start:` | Run SQL at the start of `dbt run`. Useful for setting session context or logging. |
| `on-run-end:`   | Run SQL at the end of `dbt run`.                                                  |

---

### ☁️ dbt Cloud-Specific

| Key          | Purpose                                                                                                        |
| ------------ | -------------------------------------------------------------------------------------------------------------- |
| `dbt-cloud:` | Add `project-id:` to connect to dbt Cloud project. Use `defer-env-id` to enable deferral between environments. |

---

### 🧠 Extras

| Key                | Purpose                                                       |
| ------------------ | ------------------------------------------------------------- |
| `query-comment:`   | Auto-add a comment to all SQL queries (good for tracing).     |
| `exposures:`       | Enable or disable exposures globally.                         |
| `dispatch:`        | Map macros across namespaces. Useful for overriding packages. |
| `restrict-access:` | Boolean to restrict documentation access (rarely used).       |

---

Yes, it's **fair and accurate** to say that all the parameters and configs available in `dbt_project.yml` are defined across those property/config reference pages. Here's how it breaks down:

---

### ✅ What’s Defined in `dbt_project.yml`?

The `dbt_project.yml` supports:

1. **Project-level settings**
   (like `name`, `version`, `profile`, `model-paths`, etc.)

2. **Resource-level configurations**, scoped under top-level keys:

   * `models:` → [Model properties and configs](https://docs.getdbt.com/reference/model-properties)
   * `sources:` → [Source properties and configs](https://docs.getdbt.com/reference/source-properties)
   * `seeds:` → [Seed properties and configs](https://docs.getdbt.com/reference/seed-properties)
   * `snapshots:` → [Snapshot properties](https://docs.getdbt.com/reference/snapshot-properties)
   * `analyses:` → [Analysis properties](https://docs.getdbt.com/reference/analysis-properties)
   * `macros:` → [Macro properties](https://docs.getdbt.com/reference/macro-properties)
   * `exposures:` → [Exposure properties](https://docs.getdbt.com/reference/exposure-properties)

3. **Other references** like:

   * `metrics:` (legacy and now part of the semantic layer)
   * `semantic-models:` (if using dbt Semantic Layer)

---

