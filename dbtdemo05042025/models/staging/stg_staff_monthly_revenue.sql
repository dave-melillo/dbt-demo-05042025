{{ config(materialized='view', tags=['lab1']) }}

SELECT
  s.staff_id,
  s.first_name,
  s.last_name,
  DATE_TRUNC('month', p.payment_date) AS revenue_month,
  SUM(p.amount) AS total_revenue,
  COUNT(r.rental_id) AS total_rentals
FROM {{ source('pagila', 'payment') }} p
JOIN {{ source('pagila', 'rental') }} r ON p.rental_id = r.rental_id
JOIN {{ source('pagila', 'staff') }} s ON p.staff_id = s.staff_id
GROUP BY 1, 2, 3, 4