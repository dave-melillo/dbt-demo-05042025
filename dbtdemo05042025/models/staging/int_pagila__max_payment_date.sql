SELECT MAX(payment_date) AS max_payment_date
FROM {{ source('pagila', 'payment') }}