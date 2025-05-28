## 🧪 Lab: Snapshots and Seeds in Jaffle Shop

---

### ✅ 1. **City Enrichment with Seed File**

**Goal**: Use a seed to enrich `stg_locations` with city-level demographics.

---

#### 🗂️ Seed File: `city_demographics.csv`

```csv
city,population,avg_median_income,avg_age
Philadelphia,1584200,52150,34.1
Brooklyn,2559900,58700,35.9
Chicago,2746388,61200,33.8
San Francisco,883305,99600,38.5
New Orleans,391006,48900,36.0
Los Angeles,3980400,62000,35.0
```

Place this in the `data/` directory.

---

#### 🛠️ Model: `models/staging/stg_locations_enriched.sql`

```sql
select
    l.*,
    d.population,
    d.avg_median_income,
    d.avg_age
from {{ ref('stg_locations') }} l
left join {{ ref('city_demographics') }} d
  on l.location_name = d.city
```

> 💡 Run:

```bash
dbt seed --select city_demographics  
dbt run --select stg_locations_enriched
```

---

### ✅ 2. **Filtering Customers by VIPs (Seed Join)**

**Goal**: Use a seed file to filter `customers` to only VIPs via an inner join.

---

#### 🗂️ Seed File: `vip_customers.csv`

```csv
customer_id
dc634429-12c2-417d-b460-f3ed4903d539
2bdeb3b7-a894-4fcf-8218-e41167bc557e
84f816bd-12e2-4633-a419-fc80705977e6
0bb6fcf3-0741-4179-af46-d26c45b77171
827eed18-8ab1-4e5d-ab00-5d8ac9bb168b
9db0e79f-fdea-4290-ba7b-114141f33d1f
2a2c365a-ac9d-4106-a494-678e09ae412c
```

---

#### 🛠️ Model: `models/staging/stg_customers_vip.sql`

```sql
select
    c.*
from {{ ref('customers') }} c
inner join {{ ref('vip_customers') }} v
    on c.customer_id = v.customer_id
```

> 💡 Run:

```bash
dbt seed --select vip_customers  
dbt run --select stg_customers_vip
```

---

### ✅ 3. **New Online Orders + Snapshot**

**Goal**: Load online orders from seed, create a model + snapshot based on `status`, then mutate the data and re-run snapshot.

---

#### 🗂️ Seed File: `online_orders.csv`

```csv
order_number,customer,item,timestamp_of_purchase,status
1001,dc634429-12c2-417d-b460-f3ed4903d539,"Toaster",2024-01-01 08:00:00,processing
1002,2bdeb3b7-a894-4fcf-8218-e41167bc557e,"Blender",2024-01-01 09:00:00,processing
1003,84f816bd-12e2-4633-a419-fc80705977e6,"Microwave",2024-01-01 09:30:00,shipped
1004,0bb6fcf3-0741-4179-af46-d26c45b77171,"Coffee Maker",2024-01-01 10:00:00,processing
1005,827eed18-8ab1-4e5d-ab00-5d8ac9bb168b,"Slow Cooker",2024-01-01 10:30:00,processing
1006,9db0e79f-fdea-4290-ba7b-114141f33d1f,"Toaster Oven",2024-01-01 11:00:00,shipped
1007,2a2c365a-ac9d-4106-a494-678e09ae412c,"Air Fryer",2024-01-01 11:30:00,processing
1008,dc634429-12c2-417d-b460-f3ed4903d539,"Juicer",2024-01-01 12:00:00,processing
1009,84f816bd-12e2-4633-a419-fc80705977e6,"Food Processor",2024-01-01 12:30:00,processing
1010,827eed18-8ab1-4e5d-ab00-5d8ac9bb168b,"Rice Cooker",2024-01-01 13:00:00,processing
```

---

#### 🛠️ Model: `models/staging/stg_online_orders.sql`

```sql
select
    order_number,
    customer,
    item,
    timestamp_of_purchase,
    status
from {{ ref('online_orders') }}
```

---

#### 📸 Snapshot: `snapshots/online_orders_snapshot.yml`

```yaml
snapshots:
  - name: online_orders_snapshot
    config:
      strategy: check
      unique_key: order_number
      check_cols: ["status"]
      target_schema: snapshots
    relation: ref('stg_online_orders')
```

> 💡 Run:

```bash
dbt seed --select online_orders
dbt run --select stg_online_orders
dbt snapshot
```

---

### 🔁 Then Edit `online_orders.csv`

Change a few `status` values from `"processing"` to `"shipped"`, save, then:

```bash
dbt seed --select online_orders
dbt snapshot
```

Query the snapshot to see the new versioned rows.

---

### 🌟 Extra Credit

Add this snapshot using the `timestamp` strategy instead:

```yaml
snapshots:
  - name: online_orders_snapshot_ts
    config:
      strategy: timestamp
      unique_key: order_number
      updated_at: timestamp_of_purchase
      target_schema: snapshots
    relation: ref('stg_online_orders')
```

Compare behavior of check vs. timestamp strategy.

---
