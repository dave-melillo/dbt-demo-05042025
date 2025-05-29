{{ config(
    materialized = 'view',
    tags = ['section_2_tests']
) }}

{% set store_ids = [1, 2] %}

{% for store in store_ids %}
    SELECT
        {{ store }} AS store_id,
        r.rental_id,
        r.customer_id,
        r.inventory_id,
        r.rental_date
    FROM {{ source('pagila', 'rental') }} AS r
    JOIN {{ source('pagila', 'inventory') }} AS i
        ON r.inventory_id = i.inventory_id
    WHERE i.store_id = {{ store }}
    
    {% if not loop.last %}
    UNION ALL
    {% endif %}
{% endfor %}