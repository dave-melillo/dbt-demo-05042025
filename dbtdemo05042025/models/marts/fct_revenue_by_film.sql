{{ config(materialized='table', tags=['pagila']) }}

WITH rentals AS (

    SELECT *
    FROM {{ ref('stg_rentals') }}

), payments AS (

    SELECT
        p.payment_id,
        p.customer_id,
        p.rental_id,
        p.amount,
        p.payment_date
    FROM {{ source('pagila','payment') }} AS p
)

SELECT
    rentals.film_id,
    rentals.film_title,
    DATE_TRUNC('day', payments.payment_date) AS payment_day,
    SUM(payments.amount)                     AS revenue
FROM rentals
JOIN payments
  ON rentals.rental_id = payments.rental_id
GROUP BY film_id, film_title, payment_day