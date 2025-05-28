{{ config(materialized='table',tags=['retail']) }}

SELECT
    order_date,
    product_category,
    SUM(total_amount) AS total_sales,
    SUM(quantity)     AS total_units
FROM {{ ref('stg_transactions') }}
GROUP BY order_date, product_category
