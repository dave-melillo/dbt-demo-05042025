{{ config(
    materialized = 'view',
    tags = ['section_2_tests']
) }}

-- Set max date from the dataset (hardcoded here, ideally you'd extract it via a separate model or snapshot)
{% set max_payment_date = '2007-02-14' %}  -- Replace with dynamically queried value later
{% set recent_days = 30 %}

WITH recent_payments AS (
    SELECT
        payment_id,
        customer_id,
        staff_id,
        amount,
        payment_date
    FROM {{ source('pagila', 'payment') }}
    WHERE payment_date >= DATEADD(DAY, -{{ recent_days }}, TO_DATE('{{ max_payment_date }}'))
)

SELECT * FROM recent_payments
