# Instructor Provisioning Guide (Revised 2025-05-22)

Provision **per-student workspaces** in a single Snowflake database while granting read-only access to the shared raw data (`PUBLIC` schema). Follow these steps for **each** student.

---

## Environment Requirements
| Requirement | Notes |
|-------------|-------|
| Snowflake account | Provided by PluralSight (or Northwest Mutual) |
| Admin-level role | `ACCOUNTADMIN` or `SECURITYADMIN`, or a custom role with **USERADMIN** + **SECURITYADMIN**-level privileges |
| Shared database | Example shown: `DBT_DEMO_05042026` |
| Shared warehouse | Example shown: `COMPUTE_WH` (size XS/S is fine) |

---

## Step-by-Step Provisioning

### 1  Create the student’s role and personal schema

> Replace **`<student>`** with a short, lowercase identifier (e.g. `dave` ⇒ `student_dave_role`, `STUDENT_DAVE`).

```sql
-- 1a. Role
CREATE ROLE IF NOT EXISTS student_<student>_role;

-- 1b. Personal schema inside the training database
CREATE SCHEMA IF NOT EXISTS DBT_DEMO_05042026.STUDENT_<STUDENT>;

-- 1c. Visibility on the database + personal schema
GRANT USAGE ON DATABASE DBT_DEMO_05042026
        TO ROLE student_<student>_role;
GRANT USAGE ON SCHEMA  DBT_DEMO_05042026.STUDENT_<STUDENT>
        TO ROLE student_<student>_role;

-- 1d. Full DDL/DML rights in the personal schema (for dbt models)
GRANT CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT
     ON SCHEMA DBT_DEMO_05042026.STUDENT_<STUDENT>
     TO ROLE student_<student>_role;

GRANT ALL PRIVILEGES
     ON ALL TABLES    IN SCHEMA DBT_DEMO_05042026.STUDENT_<STUDENT>
     TO ROLE student_<student>_role;
GRANT ALL PRIVILEGES
     ON FUTURE TABLES IN SCHEMA DBT_DEMO_05042026.STUDENT_<STUDENT>
     TO ROLE student_<student>_role;
````

### 2  Grant **read-only** access to the shared raw data (`PUBLIC` schema)

```sql
-- 2a. Visibility on PUBLIC
GRANT USAGE ON SCHEMA DBT_DEMO_05042026.PUBLIC
        TO ROLE student_<student>_role;

-- 2b. Read any current or future raw tables
GRANT SELECT ON  ALL TABLES    IN SCHEMA DBT_DEMO_05042026.PUBLIC
        TO ROLE student_<student>_role;
GRANT SELECT ON FUTURE TABLES  IN SCHEMA DBT_DEMO_05042026.PUBLIC
        TO ROLE student_<student>_role;

-- (Optional) If only one table exists and you prefer tight scope:
-- GRANT SELECT ON TABLE DBT_DEMO_05042026.PUBLIC.RETAIL_TRANSACTIONS
--         TO ROLE student_<student>_role;
```

### 3  Create the user and attach the role

```sql
CREATE USER IF NOT EXISTS <student>_user
  PASSWORD       = 'TempPassword!Rotate'   -- force change on first login
  DEFAULT_ROLE   = student_<student>_role
  DEFAULT_WAREHOUSE = COMPUTE_WH
  MUST_CHANGE_PASSWORD = TRUE;             -- optional but recommended

GRANT ROLE student_<student>_role TO USER <student>_user;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE student_<student>_role;
```

### 4  (Verify) Log in as the student role

```sql
-- Switch role and test access
USE ROLE student_<student>_role;

-- Should return a row count (read access works)
SELECT COUNT(*) FROM DBT_DEMO_05042026.PUBLIC.RETAIL_TRANSACTIONS;

-- Should create a table in the student schema (write access works)
CREATE OR REPLACE TABLE DBT_DEMO_05042026.STUDENT_<STUDENT>.connection_test
AS SELECT 'ok' AS status;
SELECT * FROM DBT_DEMO_05042026.STUDENT_<STUDENT>.connection_test;
```

If both queries succeed, provisioning is complete.

---

## Project Access Instructions (share with students)

1. **Clone the course repo**

   ```bash
   git clone https://github.com/your-org/dbt-training.git
   cd dbt-training
   ```

2. **Create / edit** `~/.dbt/profiles.yml`

   ```yaml
   dbtdemo05042025:
     target: dev
     outputs:
       dev:
         type: snowflake
         account: <your_account_locator>
         user: <student>_user
         password: <their_password>
         role: student_<student>_role
         warehouse: COMPUTE_WH
         database: DBT_DEMO_05042026
         schema: STUDENT_<STUDENT>
         threads: 1
   ```

3. **Test and run**

   ```bash
   dbt debug               # connection sanity-check
   dbt build --select tag:retail+ \
              source:retail.retail_transactions   # retail pipeline only
   ```

The profile writes all dbt-generated models to their personal schema
`DBT_DEMO_05042026.STUDENT_<STUDENT>` while reading shared raw data from
`DBT_DEMO_05042026.PUBLIC`.

---

### Troubleshooting Cheat-Sheet

| Symptom                                                           | Likely Cause                                   | Quick Fix                         |
| ----------------------------------------------------------------- | ---------------------------------------------- | --------------------------------- |
| `Schema … does not exist or not authorized` when hitting `PUBLIC` | Missing `USAGE` on schema or `SELECT` on table | Re-run Step 2 grants              |
| Can’t create tables in `STUDENT_<STUDENT>`                        | Missing DDL privileges                         | Re-run Step 1d grants             |
| Warehouse error                                                   | Role lacks `USAGE` on `COMPUTE_WH`             | Re-run `GRANT USAGE ON WAREHOUSE` |

Following this guide ensures every student can **read** the common source data and **write** their own dbt models without stepping on each other’s work.

```

