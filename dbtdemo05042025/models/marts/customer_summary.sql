{{ config(materialized='view') }}

SELECT
  p.customer_id,
  c.email, 
  SUM(p.amount) AS total_revenue
FROM {{ source('pagila', 'payment') }} as p
LEFT JOIN {{ source('pagila', 'customer') }}  as c on p.customer_id = c.customer_id 
GROUP BY 1,2
