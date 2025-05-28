{{ config(
    materialized = 'table',
    tags = ['section_2_tests']
) }}

{% set genres = ['Action', 'Animation', 'Children', 'Classics', 'Comedy', 'Documentary', 'Drama', 'Family', 'Foreign', 'Games'] %}

{% for genre in genres %}

SELECT
    '{{ genre }}' AS genre,
    DATE_TRUNC('month', p.payment_date) AS month,
    COUNT(*) AS rental_count,
    SUM(p.amount) AS total_revenue
FROM {{ source('pagila', 'payment') }} AS p
JOIN {{ source('pagila', 'rental') }} AS r ON p.rental_id = r.rental_id
JOIN {{ source('pagila', 'inventory') }} AS i ON r.inventory_id = i.inventory_id
JOIN {{ source('pagila', 'film') }} AS f ON i.film_id = f.film_id
JOIN {{ source('pagila', 'film_category') }} AS fc ON f.film_id = fc.film_id
JOIN {{ source('pagila', 'category') }} AS c ON fc.category_id = c.category_id
WHERE c.name = '{{ genre }}'
GROUP BY 1, 2

{% if not loop.last %}
UNION ALL
{% endif %}

{% endfor %}
