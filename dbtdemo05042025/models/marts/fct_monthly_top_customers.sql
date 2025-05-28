{{ config(materialized='table',tags=['retail']) }}

WITH monthly AS (
    SELECT
        TO_CHAR(order_date,'YYYY-MM') AS month,
        customer_id,
        SUM(total_amount)            AS total_spent
    FROM {{ ref('stg_transactions') }}
    GROUP BY 1,2
)

SELECT *
FROM (
    SELECT
        month,
        customer_id,
        total_spent,
        ROW_NUMBER() OVER (PARTITION BY month ORDER BY total_spent DESC) AS rn
    FROM monthly
)
WHERE rn <= 10;
