{{ config(
    materialized = 'view',
    tags = ['section_2_tests']
) }}

{% set east_region = true %}

SELECT
    r.rental_id,
    r.customer_id,
    i.store_id,
    r.rental_date
FROM {{ source('pagila', 'rental') }} AS r
JOIN {{ source('pagila', 'inventory') }} AS i
    ON r.inventory_id = i.inventory_id
WHERE 1 = 1
{% if east_region %}
    AND i.store_id = 1
{% else %}
    AND i.store_id != 1
{% endif %}
