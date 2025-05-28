Below is a **ready-to-paste appendix** for your existing `models/sources.yml` (or whatever file you keep sources in).
It introduces a new `pagila` source that points at the dataset you loaded to **`DBT_DEMO_05042026.PAGILA`** and enumerates the core tables your lessons will join across (actor → film → inventory → rental → payment → customer, plus supporting look-ups such as language and store).

```yaml
version: 2                      # keep the same file-level version

sources:
  # ─── existing retail source stays unchanged ───────────────────────────────────
  - name: retail
    database: DBT_DEMO_05042026
    schema: PUBLIC
    tables:
      - name: retail_transactions
        description: |
          Raw CSV upload containing messy retail transactions used for lesson demos.
        loaded_at_field: order_date
        columns:
          - name: order_id
            tests: [not_null, unique]
          - name: customer_id
            tests: [not_null]
          - name: order_status
            tests: [not_null]

  # ─── NEW pagila source ─────────────────────────────────────────────────────────
  - name: pagila                  # you’ll reference this via source('pagila', ...)
    database: DBT_DEMO_05042026
    schema: PAGILA
    freshness:
      warn_after: {count: 12, period: hour}   # optional: tweak or remove
      error_after: {count: 24, period: hour}

    tables:
      # dimension tables
      - name: actor
        description: Master list of actors in the Pagila movie rental universe. :contentReference[oaicite:1]{index=1}
        columns:
          - name: actor_id
            tests: [not_null, unique]
      - name: category
        description: Film genres / categories. :contentReference[oaicite:3]{index=3}
        columns:
          - name: category_id
            tests: [not_null, unique]
      - name: customer
        description: Customers who rent films. :contentReference[oaicite:5]{index=5}
        loaded_at_field: last_update
        columns:
          - name: customer_id
            tests: [not_null, unique]
          - name: address_id
            tests:
              - relationships:
                  to: source('pagila','address')
                  field: address_id
      - name: address
        description: Physical addresses for customers, stores and staff. :contentReference[oaicite:7]{index=7}
      - name: city
        description: Cities referenced by addresses. :contentReference[oaicite:9]{index=9}
      - name: country
        description: Countries referenced by cities. :contentReference[oaicite:11]{index=11}
      - name: language
        description: Spoken language of a film (original and dubbed). :contentReference[oaicite:13]{index=13}
      - name: store
        description: Physical rental stores. :contentReference[oaicite:15]{index=15}
      - name: staff
        description: Staff working in stores (useful for staff → rental joins). :contentReference[oaicite:17]{index=17}

      # fact / bridge tables
      - name: film
        description: Core film catalogue with pricing and length metadata. :contentReference[oaicite:19]{index=19}
        loaded_at_field: last_update
        columns:
          - name: film_id
            tests: [not_null, unique]
          - name: language_id
            tests:
              - relationships:
                  to: source('pagila','language')
                  field: language_id
      - name: film_actor
        description: Bridge table mapping films to actors (many-to-many). :contentReference[oaicite:21]{index=21}
      - name: film_category
        description: Bridge table mapping films to genres. :contentReference[oaicite:23]{index=23}
      - name: inventory
        description: Physical copies of each film held at a store. :contentReference[oaicite:25]{index=25}
        columns:
          - name: film_id
            tests:
              - relationships:
                  to: source('pagila','film')
                  field: film_id
          - name: store_id
            tests:
              - relationships:
                  to: source('pagila','store')
                  field: store_id
      - name: rental
        description: Each time a customer rents an inventory item. :contentReference[oaicite:27]{index=27}
        loaded_at_field: rental_date
        columns:
          - name: rental_id
            tests: [not_null, unique]
          - name: inventory_id
            tests:
              - relationships:
                  to: source('pagila','inventory')
                  field: inventory_id
          - name: customer_id
            tests:
              - relationships:
                  to: source('pagila','customer')
                  field: customer_id
      - name: payment
        description: Payments associated with a rental. :contentReference[oaicite:29]{index=29}
        loaded_at_field: payment_date
        columns:
          - name: payment_id
            tests: [not_null, unique]
          - name: rental_id
            tests:
              - relationships:
                  to: source('pagila','rental')
                  field: rental_id
```

### Why these tables?

* **actor → film\_actor → film → inventory → rental → payment → customer** forms a natural 4-to-6-table chain that shows off `ref()` and incremental model layering.
* Support dimensions (`store`, `category`, `language`, `address / city / country`) let you demonstrate star-style joins, surrogate keys and type-2 slowly-changing-dimension snapshots later if you wish.
* Only core transactional and dimension tables are listed; Pagila also ships with a handful of reporting views (e.g. `sales_by_film_category`) but those aren’t needed as raw sources—you’ll build your own marts from the base data instead.

You can of course prune or add tables depending on your lesson scope—just keep everything under the single `pagila` source so students can reference it uniformly:

```sql
select *
from {{ source('pagila', 'rental') }}
```

Happy modelling!
