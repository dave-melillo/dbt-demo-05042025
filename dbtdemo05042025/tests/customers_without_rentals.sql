{{ config(
    store_failures = true,
    severity = 'error',
    fail_calc = 'count(*)'
) }}

-- This test fails if any customers exist that have no rental records
SELECT
  c.customer_id,
  c.email
FROM {{ source('pagila', 'customer') }} c
LEFT JOIN {{ source('pagila', 'rental') }} r 
  ON c.customer_id = r.customer_id
WHERE r.rental_id IS NULL