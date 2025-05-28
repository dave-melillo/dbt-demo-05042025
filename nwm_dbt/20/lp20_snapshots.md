

## 📸 Lesson Plan: How to Set Up Snapshots (Marvel Edition)

### 🧠 Learning Objective

Students will learn how to use **dbt snapshots** to track changes to source data over time. We'll use a fictional dataset of Marvel characters to detect heroes and villains switching sides.

---

### 📦 Dataset

Seed file: `marvel_short.csv`
Columns:

* `name` (character name)
* `ID` (identity type)
* `ALIGN` (alignment — good, bad, or neutral)

---

## 🧱 Step-by-Step Instructions

---

### 1. **Add the CSV to Your Project**

Place `marvel_short.csv` into the `data/` folder of your dbt project.

---

### 2. **Load the Seed**

```bash
dbt seed --select marvel_short
```

This loads the CSV as a table (e.g., `marvel_short`) into your target schema (e.g., `STUDENT_DAVE`).


---

### 4. **Create a Staging Model**

Create `models/example/stg_marvel_short.sql`:

```sql
select
  name,
  id,
  align
from {{ ref('marvel_short') }}
where name is not null
```

Run it:

```bash
dbt run --select stg_marvel_short
```

---

### 5. **Create the Snapshot File**

Create `snapshots/marvel_short_snapshot.yml`:

```yaml
snapshots:
  - name: marvel_short_snapshot
    description: "Tracks alignment changes (hero ↔ villain)"
    config:
      strategy: check
      unique_key: name
      check_cols: ["align"]
      target_schema: snapshots
    relation: ref('stg_marvel_short')
```

---

### 6. **Run the Snapshot**

```bash
dbt snapshot
```

This builds a historical version of the characters’ alignment. Each row includes:

* `dbt_valid_from`
* `dbt_valid_to`
* `align` at that point in time

---

### 7. **Simulate a Change**

Open `data/marvel_short.csv`, and edit one character:

> Change `"Iron Man"` from `"Good Characters"` → `"Bad Characters"`

Save the file.

---

### 8. **Re-run the Seed**

```bash
dbt seed --select marvel_short
```

---

### 9. **Re-run the Snapshot**

```bash
dbt snapshot
```

dbt detects that Iron Man’s alignment has changed and adds a new versioned row to the snapshot.

---

### 10. **View the History**

```sql
select *
from snapshots.marvel_short_snapshot
where name = 'Iron Man (Anthony "Tony" Stark")'
order by dbt_valid_from;
```

You’ll now see a row for each version of Iron Man's alignment over time.

---

## 🧠 Teaching Notes

* Emphasize that snapshots allow **versioning** of mutable data.
* The `check` strategy is great for fields like `align`, where we want to track changes explicitly.
* Tie it to real business use cases: tracking customer tier changes, order status changes, etc.
* Bonus: Add `hard_deletes: new_record` and teach deletes.
