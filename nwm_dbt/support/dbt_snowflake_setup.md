
# 🧊 DBT Core + Snowflake Setup Guide (VS Code + Snowflake GUI)

This guide walks you through setting up a **DBT Core project with Snowflake**, using the terminal or VS Code for setup and the **Snowflake GUI** for executing queries and verifying results.

---

## ✅ Step 1: Snowflake Account Setup

If you don’t already have a Snowflake account:

- Sign up for a free trial: https://signup.snowflake.com/

### 🛠️ Important Notes for New Accounts

If you're **not connecting to an existing Snowflake instance**, you may need to:

- Create a **user** (if one isn't provided)
- Create a **warehouse**
- Create a **database**
- Create a **schema**

You can do this in the **Snowflake UI (Snowsight)** using the SQL Worksheet. Example:

```sql
CREATE WAREHOUSE COMPUTE_WH;
CREATE DATABASE DBT_DEMO;
CREATE SCHEMA PUBLIC;
````

Once you're done, you'll need the following info to configure DBT.

### 🔑 Required Snowflake Info for DBT

| Setting     | Example                      |
| ----------- | ---------------------------- |
| `account`   | `xy12345.us-east-1`          |
| `user`      | `your_email@domain.com`      |
| `password`  | `your_snowflake_password`    |
| `role`      | `ACCOUNTADMIN` or `SYSADMIN` |
| `warehouse` | `COMPUTE_WH`                 |
| `database`  | `DBT_DEMO`                   |
| `schema`    | `PUBLIC`                     |

---

## ✅ Step 2: Create & Clone a GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository (e.g., `dbt_demo`)
2. Clone the repo to your local machine:

```bash
git clone https://github.com/<your-username>/dbt_demo.git
cd dbt_demo
```

---

## ✅ Step 3: Install DBT Core Locally

Install DBT and the Snowflake adapter:

```bash
pip install dbt-core dbt-snowflake
```

(Optional but recommended: set up a Python virtual environment.)

---

## ✅ Step 4: Initialize the DBT Project

From inside your cloned GitHub repo:

```bash
dbt init dbt_demo
```

### During setup, select:

* **snowflake** as the adapter
* Provide the account info from Step 1 when prompted

This will create a DBT project with a structure like:

```
dbt_demo/
├── dbt_project.yml
├── models/
├── macros/
└── ...
```

---

### 🛠 Edit `profiles.yml` to Configure Snowflake

Your DBT **profile file** is located in a hidden directory:

```
/Users/<your_username>/.dbt/profiles.yml
```

> ℹ️ On macOS, the `.dbt` folder is hidden. Use `Cmd+Shift+.` in Finder to view hidden files, or open it directly in VS Code.

Update the file to match your Snowflake settings:

```yaml
dbt_demo:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_account>
      user: <your_user>
      password: <your_password>
      role: <your_role>
      database: <your_database>
      schema: <your_schema>
      warehouse: <your_warehouse>
      threads: 1
```

---

### ✅ Test the Connection

In the project root directory:

```bash
dbt debug
```

You should see a ✅ success message confirming your Snowflake connection is valid.

---

## ✅ Step 5: Run Example Models

Use DBT's built-in example models:

```bash
dbt run
```

---

### 🔎 View Tables in Snowflake GUI

1. Log in to your Snowflake account
2. Navigate to the **database** and **schema** you specified in your profile
3. Use the Worksheet or Explorer to run:

```sql
SELECT * FROM my_first_dbt_model;
```

This confirms that DBT created the table successfully.

---

## ✅ Step 6: Commit Your DBT Project to GitHub

From inside your project folder:

```bash
git add .
git commit -m "My First Commit"
git push
```

Then go to GitHub in your browser to confirm the update.

---

🎉 You’ve now set up a complete DBT + Snowflake workflow!
You’re ready to build models, seed CSVs, and run queries using DBT and the Snowflake UI.

Next up: create custom models, seed external data, and learn how to document and test your work.