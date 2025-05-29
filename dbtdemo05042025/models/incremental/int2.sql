{{ config(
    materialized='incremental',
    unique_key='payment_id'
) }}

SELECT
    payment_id,
    customer_id,
    amount,
    payment_date
FROM {{ source('pagila', 'payment') }}
{% if is_incremental() %}
WHERE payment_date > (SELECT MAX(payment_date) FROM {{ this }})
{% endif %}