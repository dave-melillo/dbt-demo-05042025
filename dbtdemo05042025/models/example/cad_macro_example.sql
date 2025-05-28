{{ config(
    materialized = 'view',
    tags = ['section_2_tests']
) }}

SELECT
    DATE_TRUNC('month', p.payment_date) AS month,
    SUM(p.amount) AS total_revenue_usd,
    {{ convert_to_cad("SUM(p.amount)") }} AS total_revenue_cad
FROM {{ source('pagila', 'payment') }} AS p
GROUP BY 1
