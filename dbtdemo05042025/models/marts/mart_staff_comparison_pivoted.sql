{{ config(materialized='table', tags=['lab1']) }}

WITH base AS (
  SELECT *
  FROM {{ ref('stg_staff_monthly_revenue') }}
  WHERE staff_id IN (1, 2)
)

SELECT
  revenue_month,
  MAX(CASE WHEN staff_id = 1 THEN total_revenue END) AS mike_revenue,
  MAX(CASE WHEN staff_id = 2 THEN total_revenue END) AS jon_revenue,
  MAX(CASE WHEN staff_id = 1 THEN total_rentals END) AS mike_rentals,
  MAX(CASE WHEN staff_id = 2 THEN total_rentals END) AS jon_rentals
FROM base
GROUP BY revenue_month
ORDER BY revenue_month