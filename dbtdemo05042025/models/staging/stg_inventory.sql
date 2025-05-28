{{ config(materialized='view', tags=['pagila']) }}

SELECT
    i.inventory_id,
    i.film_id,
    f.title               AS film_title,
    i.store_id,
    i.last_update
FROM {{ source('pagila','inventory') }}      AS i
JOIN {{ ref('stg_films') }}                  AS f
  ON i.film_id = f.film_id