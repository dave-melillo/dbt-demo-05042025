# Student Setup Guide – dbt + Snowflake

## Purpose
Connect your local dbt environment to your assigned Snowflake schema.

---

## Step 1: Clone the Project Repo

```bash
git clone https://github.com/your-org/dbt-training.git
cd dbt-training
```

---

## Step 2: Set Up Python and dbt

```bash
python3 -m venv venv
source venv/bin/activate
pip install dbt-core dbt-snowflake
```

---

## Step 3: Configure Your dbt Profile

Create/edit the file at `~/.dbt/profiles.yml`:

```yaml
dbt_training:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_account>
      user: dave_user
      password: StrongPassword123!
      role: student_dave_role
      database: DBT_DEMO_05042026
      schema: STUDENT_DAVE
      warehouse: COMPUTE_WH
      threads: 1
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
DBT_DEMO_05042026 > STUDENT_DAVE > Tables
```

You should see the model table (e.g., `my_first_dbt_model`) created by your dbt command.

---
