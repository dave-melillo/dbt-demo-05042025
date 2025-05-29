SELECT
    payment_id,
    customer_id,
    amount,
    payment_date
FROM {{ source('pagila', 'payment') }}
WHERE payment_date >= (
    SELECT DATEADD(DAY, -30, max_payment_date)
    FROM {{ ref('int_pagila__max_payment_date') }}
)