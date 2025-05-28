{{ config(materialized='table', tags=['lab1']) }}

SELECT *
FROM {{ ref('stg_staff_monthly_revenue') }}
WHERE staff_id = 2