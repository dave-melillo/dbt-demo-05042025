{{ config(materialized='view', tags=['pagila']) }}

SELECT
    film_id,
    title,
    release_year,
    rental_rate,
    length,
    rating,
    language_id,
    last_update
FROM {{ source('pagila','film') }}