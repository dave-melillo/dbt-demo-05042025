SELECT *
FROM {{ ref('customer_summary') }}
WHERE total_revenue < 0