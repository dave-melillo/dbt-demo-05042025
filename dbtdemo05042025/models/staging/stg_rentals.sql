{{ config(materialized='view', tags=['pagila']) }}

SELECT
    r.rental_id,
    r.rental_date,
    r.customer_id,
    inv.store_id,
    inv.film_id,
    inv.film_title,
    r.return_date
FROM {{ source('pagila','rental') }} AS r
JOIN {{ ref('stg_inventory') }}      AS inv
  ON r.inventory_id = inv.inventory_id