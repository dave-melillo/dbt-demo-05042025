{{ config(materialized='view', tags=['retail']) }}

WITH src AS (

    SELECT *
    FROM {{ source('retail', 'retail_transactions') }}

)

SELECT
    order_id,
    TO_DATE(order_date)                        AS order_date,
    customer_id,
    INITCAP(TRIM(product_category))            AS product_category,
    product_id,
    quantity::INT                              AS quantity,
    unit_price::NUMBER(10,2)                   AS unit_price,
    COALESCE(discount_pct, 0)::NUMBER(5,2)     AS discount_pct,
    shipping_cost::NUMBER(10,2)                AS shipping_cost,
    UPPER(TRIM(order_status))                  AS order_status,
    country,
    city,
    (quantity * unit_price * (1 - COALESCE(discount_pct,0))) + shipping_cost
                                               AS total_amount
FROM src