{% macro get_genre_filter(genre_name) %}
    c.name = '{{ genre_name }}'
{% endmacro %}
