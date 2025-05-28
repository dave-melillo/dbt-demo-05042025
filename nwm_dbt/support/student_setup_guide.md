# Student Setup Guide – dbt + Snowflake

## Purpose
Connect your local dbt environment to your assigned Snowflake schema.

---

## Step 1: Clone the Project Repo

```bash
git clone https://github.com/dave-melillo/dbt-demo-05042025
cd dbt-demo-05042025
cd dbtdemo05042025 --this is the actual dbt project folde 
```

---

## Step 2: Set Up Python and dbt

```bash
python3 -m venv venv --optional
source venv/bin/activate --optional
pip install dbt-core dbt-snowflake
```

---

## Step 3: Configure Your dbt Profile

Create/edit the file at `~/.dbt/profiles.yml`:

```yaml
dbtdemo05042025:
  target: dev
  outputs:
    dev:
      account: YYGLPGM-FGC83264
      database: DBT_DEMO_05042026
      password: enzo1234!
      role: student_enzo_role
      schema: STUDENT_ENZO
      threads: 1
      type: snowflake
      user: enzo_user
      warehouse: COMPUTE_WH
```

> Replace `<your_account>` with your actual Snowflake account locator (e.g., `xy12345.us-east-1`)

---

## Step 4: Test Connection

```bash
dbt debug
```

---

## Step 5: Run a Model

```bash
dbt run --select my_first_dbt_model
```

---

## Step 6: Verify in Snowflake

Log into the Snowflake UI and check:
```
DBT_DEMO_05042026 > STUDENT_SCHEMA > Tables
```

You should see the model table (e.g., `my_first_dbt_model`) created by your dbt command.

---
