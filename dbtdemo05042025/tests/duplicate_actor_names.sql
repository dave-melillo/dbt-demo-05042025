{{ config(
    store_failures = true
) }}

SELECT first_name, last_name, COUNT(*)
FROM {{ ref('actor') }}
GROUP BY 1, 2
HAVING COUNT(*) > 1