{{ config(
    materialized='incremental'
) }}

SELECT
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date
FROM {{ source('pagila', 'payment') }}

{% if is_incremental() %}
WHERE payment_date > (SELECT MAX(payment_date) FROM {{ this }})
{% endif %}